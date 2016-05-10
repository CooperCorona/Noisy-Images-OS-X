//
//  GradientViewController.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 4/8/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import OmniSwiftX

class GradientViewController: NSViewController, NSMultiSliderDelegate {

    // MARK: - Properties
    
    static let GradientChangedNotification = "Gradient Changed Notification"
    
    @IBOutlet weak var gradientTableView: NSTableView!
    let delegate = GradientTableViewDelegate()
//    private(set) lazy var gradient:Gradient = self.delegate.gradientObjects.last!
    
    @IBOutlet weak var gradientView: ColorGradientView!
    @IBOutlet weak var overlayView: NSView!
    @IBOutlet weak var redSlider: ColorTrackSlider!
    @IBOutlet weak var greenSlider: ColorTrackSlider!
    @IBOutlet weak var blueSlider: ColorTrackSlider!
    @IBOutlet weak var alphaSlider: ColorTrackSlider!
    @IBOutlet weak var overlayBlueSlider: ColorTrackSlider!
    @IBOutlet weak var overlayRedSlider: ColorTrackSlider!
    @IBOutlet weak var overlayGreenSlider: ColorTrackSlider!
    @IBOutlet weak var overlayAlphaSlider: ColorTrackSlider!
    private(set) lazy var colorSliderContainer:ColorSliderContainer = ColorSliderContainer(red: self.redSlider, green: self.greenSlider, blue: self.blueSlider, alpha: self.alphaSlider)
    private(set) lazy var overlayColorSliderContainer:ColorSliderContainer = ColorSliderContainer(red: self.overlayRedSlider, green: self.overlayGreenSlider, blue: self.overlayBlueSlider, alpha: self.overlayAlphaSlider)
    @IBOutlet weak var colorBar: ColorControl!
    @IBOutlet weak var overlayColorBar: ColorControl!
    
    var currentThumbIndex:Int? = nil
    var colors:[NSColor] = []
    
    var gradientContainer = GradientContainer()
    
    @IBOutlet weak var smoothButton: NSButton!
    @IBOutlet weak var trackSlider: NSMultiSlider!
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gradientTableView.setDelegate(self.delegate)
        self.gradientTableView.setDataSource(self.delegate)
        self.gradientTableView.registerNib(NSNib(nibNamed: "GradientTableCellView", bundle: NSBundle.mainBundle()), forIdentifier: "GradientCell")
        self.gradientTableView.reloadData()
        self.gradientView.gradient = ColorGradient1D.grayscaleGradient

        self.overlayView.wantsLayer = true
        self.overlayView.layer = CALayer()
        self.overlayView.layer?.backgroundColor = NSColor.clearColor().CGColor
        
        self.delegate.gradientSelectedHandler = { [unowned self] in
            let grad = $0.gradient
            self.gradientView.gradient = grad
            self.setupTrackSliderFor(grad)
            self.setupOverlaySlidersFor($0.overlayColor!)
            self.gradientContainer.gradient = grad
            self.gradientContainer.uuid = $0.universalId!
            if let overlay = $0.overlayColor {
                self.gradientContainer.overlay = overlay
            }
        }
        self.delegate.gradientStoreChangedHandler = { [unowned self] _ in
            self.gradientTableView.reloadData()
        }
        
        self.trackSlider.outlineStyle = .Outline(NSColor.blackColor(), NSColor.whiteColor())
        self.trackSlider.delegate = self
        if let grad = self.gradientView.gradient {
            self.setupTrackSliderFor(grad)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, name: AppDelegate.SaveGradientItemClickedNotification, selector: #selector(saveGradient))
        NSNotificationCenter.defaultCenter().addObserver(self, name: AppDelegate.SaveNewGradientItemClickedNotification, selector: #selector(saveNewGradient))
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.selectCurrentGradientWithHandler(true)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupTrackSliderFor(gradient:ColorGradient1D) {
        self.colors = gradient.anchors.map() { NSColor(vector4: $0.0) }
        self.trackSlider.thumbCount = gradient.anchors.count
        for (i, anchor) in gradient.anchors.enumerate() {
            self.trackSlider[i] = anchor.weight
        }
        self.trackSlider.colorsNeedDisplay()
        self.smoothButton.boolValue = gradient.isSmoothed
    }
    
    func setupOverlaySlidersFor(overlay:NSColor) {
        self.overlayColorSliderContainer.color = overlay
        self.overlayView.layer?.backgroundColor = overlay.CGColor
    }
    
    func selectCurrentGradientWithHandler(invokeHandler:Bool) {
        
        if let index = self.delegate.gradientObjects.indexOf({ $0.universalId == self.gradientContainer.uuid }) {
            self.gradientTableView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
            if invokeHandler {
                self.delegate.gradientSelectedHandler?(self.delegate.gradientObjects[index])
            }
        }
        
    }
    
    // MARK: - Logic
    
    func calculateGradient(setGradient:Bool = true) {
        var anchors:ColorGradient1D.ColorArray = []
        for (i, thumb) in self.trackSlider.thumbs.enumerate().sort({ $0.1 < $1.1 }) {
            anchors.append((color: self.colors[i].getVector4(), weight: thumb))
        }
        let grad = ColorGradient1D(colorsAndWeights: anchors, smoothed: self.smoothButton.boolValue)
        self.gradientView?.gradient = grad
        if setGradient {
            self.gradientContainer.gradient = grad
        }
    }
    
    @IBAction func colorSliderChanged(sender: AnyObject) {
        guard let thumbIndex = self.currentThumbIndex else {
            return
        }
        self.colors[thumbIndex] = self.colorSliderContainer.color
        self.trackSlider.colorsNeedDisplay([thumbIndex])
        self.calculateGradient()
    }
    
    @IBAction func overlayColorSliderChanged(sender: AnyObject) {
        let color = self.overlayColorSliderContainer.color
        self.overlayView.layer?.backgroundColor = color.CGColor
        self.gradientContainer.overlay = color
    }
    
    @IBAction func screenClicked(sender: NSClickGestureRecognizer) {
        let location = sender.locationInView(self.view)
        guard self.gradientView.frame.contains(location) else {
            return
        }
        let value = self.trackSlider.convertWindowCoordinatesToSliderValue(location)
        self.colors.append(NSColor(vector4: self.gradientView.gradient![value]))
        self.trackSlider.addThumbAt(value)
        
        self.trackSlider.setNeedsDisplay()
    }
    
    @IBAction func colorBarClicked(sender: NSClickGestureRecognizer) {
        guard let color = self.colorBar.handleClick(sender.locationInView(self.view)) else {
            return
        }
        self.colorSliderContainer.color = color
        if let index = self.currentThumbIndex {
            self.colors[index] = color
            self.trackSlider.colorsNeedDisplay()
            self.calculateGradient()
        }
    }
    
    @IBAction func overlayColorBarClicked(sender: NSClickGestureRecognizer) {
        guard let color = self.overlayColorBar.handleClick(sender.locationInView(self.view)) else {
            return
        }
        let alpha       = self.gradientContainer.overlay.getComponents()[3]
        let realColor   = color.colorWithAlphaComponent(alpha)
        self.overlayColorSliderContainer.color  = realColor
        self.overlayView.layer?.backgroundColor = realColor.CGColor
        self.gradientContainer.overlay          = realColor
    }
    
    @IBAction func normalizeButtonPressed(sender: AnyObject) {
        var j = 0
        for (i, _) in self.trackSlider.thumbs.enumerate().sort({ $0.1 < $1.1 }) {
            self.trackSlider[i] = self.trackSlider.length * CGFloat(j) / CGFloat(self.trackSlider.thumbs.count - 1) + self.trackSlider.minValue
            j += 1
        }
        self.trackSlider.setNeedsDisplay()
        self.calculateGradient()
    }
    
    @IBAction func smoothButtonChanged(sender: AnyObject) {
        self.calculateGradient()
    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        guard self.trackSlider.thumbCount > 2 else {
            return
        }
        guard let index = self.trackSlider.selectedIndex else {
            return
        }
        self.colors.removeAtIndex(index)
        self.trackSlider.removeThumbAtIndex(index)
        self.calculateGradient()
    }
    
    func saveGradient(sender:NSNotification) {
        self.delegate.saveGradient(self.gradientContainer)
        self.gradientTableView.reloadData()
        self.selectCurrentGradientWithHandler(false)
    }
    
    func saveNewGradient(sender:NSNotification) {
        self.delegate.addGradient(self.gradientContainer)
        self.gradientTableView.reloadData()
    }
    
    @IBAction func rightClickedOnGradientTable(sender: NSClickGestureRecognizer) {
        
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewController(self)
        self.delegate.saveGradient(self.gradientContainer)
    }
    
    // MARK: - NSMultiSliderDelegate
    
    func colorOfThumbAtIndex(index: Int) -> NSColor {
        return self.colors[index]
    }
    
    func thumbSlider(slider: NSMultiSlider, selectedThumbAt thumbIndex: Int) {
        self.currentThumbIndex = thumbIndex
        self.colorSliderContainer.color = self.colors[thumbIndex]
    }
    
    func thumbSlider(slider: NSMultiSlider, movedThumbAt thumbIndex: Int, to value: CGFloat) {
        self.calculateGradient(false)
    }
    
    func thumbSlider(slider:NSMultiSlider, stoppedMovingThumbAt thumbIndex:Int) {
        self.gradientContainer.gradient = self.gradientView.gradient!
    }
    
    func postGradientChangedNotification(gradient:Gradient) {
        NSNotificationCenter.defaultCenter().postNotificationName(GradientViewController.GradientChangedNotification, object: self, userInfo: ["Gradient":gradient])
    }
    
}
