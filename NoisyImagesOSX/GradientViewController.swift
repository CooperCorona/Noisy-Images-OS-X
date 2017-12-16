//
//  GradientViewController.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 4/8/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import CoronaConvenience
import CoronaStructures
import CoronaGL

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
    fileprivate(set) lazy var colorSliderContainer:ColorSliderContainer = ColorSliderContainer(red: self.redSlider, green: self.greenSlider, blue: self.blueSlider, alpha: self.alphaSlider)
    fileprivate(set) lazy var overlayColorSliderContainer:ColorSliderContainer = ColorSliderContainer(red: self.overlayRedSlider, green: self.overlayGreenSlider, blue: self.overlayBlueSlider, alpha: self.overlayAlphaSlider)
    @IBOutlet weak var colorBar: ColorControl!
    @IBOutlet weak var overlayColorBar: ColorControl!
    
    var currentThumbIndex:Int? = nil
    var colors:[NSColor] = []
    fileprivate var undoColors:[NSColor] = []
    fileprivate var lastSliderValue:CGFloat = 0.0
    var undoingEnabled = true
    
    var gradientContainer = GradientContainer()
    
    @IBOutlet weak var smoothButton: NSButton!
    @IBOutlet weak var trackSlider: NSMultiSlider!
    
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gradientTableView.delegate = self.delegate
        self.gradientTableView.dataSource = self.delegate
        self.gradientTableView.register(NSNib(nibNamed: NSNib.Name(rawValue: "GradientTableCellView"), bundle: Bundle.main), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "GradientCell"))
        self.gradientTableView.reloadData()
        self.gradientView.gradient = ColorGradient1D.grayscaleGradient

        self.overlayView.wantsLayer = true
        self.overlayView.layer = CALayer()
        self.overlayView.layer?.backgroundColor = NSColor.clear.cgColor
        
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
        
        self.trackSlider.outlineStyle = .outline(NSColor.black, NSColor.white)
        self.trackSlider.delegate = self
        if let grad = self.gradientView.gradient {
            self.setupTrackSliderFor(grad)
        }
        
        let mouseDownHandler:(ColorTrackSlider) -> Void = { [unowned self] slider in
            guard let thumbIndex = self.currentThumbIndex else {
                return
            }
            self.changeColor(self.colorSliderContainer.color, atThumbIndex: thumbIndex, registerUndo: true)
        }
        self.redSlider.mouseDownExecutedHandler     = mouseDownHandler
        self.greenSlider.mouseDownExecutedHandler   = mouseDownHandler
        self.blueSlider.mouseDownExecutedHandler    = mouseDownHandler
        self.alphaSlider.mouseDownExecutedHandler   = mouseDownHandler
        
        NotificationCenter.default.addObserver(self, name: AppDelegate.SaveGradientItemClickedNotification, selector: #selector(saveGradient))
        NotificationCenter.default.addObserver(self, name: AppDelegate.SaveNewGradientItemClickedNotification, selector: #selector(saveNewGradient))
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.selectCurrentGradientWithHandler(true)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupTrackSliderFor(_ gradient:ColorGradient1D) {
        self.colors = gradient.anchors.map() { NSColor(vector4: $0.0) }
        self.undoColors = self.colors
        self.trackSlider.thumbCount = gradient.anchors.count
        for (i, anchor) in gradient.anchors.enumerated() {
            self.trackSlider[i] = anchor.weight
        }
        self.trackSlider.colorsNeedDisplay()
        self.smoothButton.boolValue = gradient.isSmoothed
    }
    
    func setupOverlaySlidersFor(_ overlay:NSColor) {
        self.overlayColorSliderContainer.color = overlay
        self.overlayView.layer?.backgroundColor = overlay.cgColor
    }
    
    func selectCurrentGradientWithHandler(_ invokeHandler:Bool) {
        
        if let index = self.delegate.gradientObjects.index(where: { $0.universalId == self.gradientContainer.uuid }) {
            self.gradientTableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
            if invokeHandler {
                self.delegate.gradientSelectedHandler?(self.delegate.gradientObjects[index])
            }
        }
        
    }
    
    // MARK: - Logic
    
    func calculateGradient(_ setGradient:Bool = true) {
        var anchors:ColorGradient1D.ColorArray = []
        for (i, thumb) in self.trackSlider.thumbs.enumerated().sorted(by: { $0.1 < $1.1 }) {
            anchors.append((color: self.colors[i].getVector4(), weight: thumb))
        }
        let grad = ColorGradient1D(colorsAndWeights: anchors, smoothed: self.smoothButton.boolValue)
        self.gradientView?.gradient = grad
        if setGradient {
            self.gradientContainer.gradient = grad
        }
    }
    
    @IBAction func colorSliderChanged(_ sender: ColorTrackSlider) {
        guard let thumbIndex = self.currentThumbIndex else {
            return
        }
        
        self.changeColor(self.colorSliderContainer.color, atThumbIndex: thumbIndex, registerUndo: false)
    }
    
    func changeColor(_ color:NSColor, atThumbIndex thumbIndex:Int, registerUndo:Bool = true) {
        if registerUndo {
            self.registerUndo() { [value = self.undoColors[thumbIndex]] target in
                target.changeColor(value, atThumbIndex: thumbIndex)
            }
            self.undoColors[thumbIndex] = color
        }
        self.colors[thumbIndex] = color
        self.trackSlider.colorsNeedDisplay([thumbIndex])
        self.calculateGradient()
    }
    
    @IBAction func overlayColorSliderChanged(_ sender: AnyObject) {
        self.changeOverlayColor(self.overlayColorSliderContainer.color)
    }
    
    func changeOverlayColor(_ color:NSColor) {
        self.registerUndo() { [value = self.gradientContainer.overlay] target in
            target.changeOverlayColor(value)
        }
        let color = self.overlayColorSliderContainer.color
        self.overlayView.layer?.backgroundColor = color.cgColor
        self.gradientContainer.overlay = color
    }
    
    @IBAction func screenClicked(_ sender: NSClickGestureRecognizer) {
        let location = sender.location(in: self.view)
        guard self.gradientView.frame.contains(location) else {
            return
        }
        let value = self.trackSlider.convertWindowCoordinatesToSliderValue(location)
        self.addThumbAt(value)
    }
    
    func addThumbAt(_ value:CGFloat) {
        self.registerUndo() { [index = self.trackSlider.thumbs.count] target in
            target.deleteThumbAtIndex(index)
        }
        self.colors.append(NSColor(vector4: self.gradientView.gradient![value]))
        self.undoColors = self.colors
        self.trackSlider.addThumbAt(value)
        
        self.trackSlider.setNeedsDisplay()
    }
    
    @IBAction func colorBarClicked(_ sender: NSClickGestureRecognizer) {
        guard let color = self.colorBar.handleClick(sender.location(in: self.view)) else {
            return
        }
        self.colorSliderContainer.color = color
        guard let index = self.currentThumbIndex else {
            return
        }
        self.changeColor(color, atThumbIndex: index)
//            self.colors[index] = color
//            self.trackSlider.colorsNeedDisplay()
//            self.calculateGradient()
    }
    
    @IBAction func overlayColorBarClicked(_ sender: NSClickGestureRecognizer) {
        guard let color = self.overlayColorBar.handleClick(sender.location(in: self.view)) else {
            return
        }
        let alpha       = self.gradientContainer.overlay.getComponents()[3]
        let realColor   = color.withAlphaComponent(alpha)
        self.overlayColorSliderContainer.color  = realColor
        self.overlayView.layer?.backgroundColor = realColor.cgColor
        self.gradientContainer.overlay          = realColor
    }
    
    @IBAction func normalizeButtonPressed(_ sender: AnyObject) {
        self.registerUndo() { [values = self.trackSlider.thumbs] target in
            for (i, value) in values.enumerated() {
                target.trackSlider.setThumb(value, atIndex: i)
            }
            target.trackSlider.setNeedsDisplay()
            target.calculateGradient()
            target.registerUndo() { subTarget in
                subTarget.normalizeButtonPressed(sender)
            }
        }
        var j = 0
        for (i, _) in self.trackSlider.thumbs.enumerated().sorted(by: { $0.1 < $1.1 }) {
            self.trackSlider[i] = self.trackSlider.length * CGFloat(j) / CGFloat(self.trackSlider.thumbs.count - 1) + self.trackSlider.minValue
            j += 1
        }
        self.trackSlider.setNeedsDisplay()
        self.calculateGradient()
    }
    
    @IBAction func smoothButtonChanged(_ sender: AnyObject) {
        self.registerUndo() { target in
            target.smoothButton.boolValue.flip()
            target.smoothButtonChanged(sender)
        }
        self.calculateGradient()
    }
    
    @IBAction func deleteButtonPressed(_ sender: AnyObject) {
        guard let index = self.trackSlider.selectedIndex else {
            return
        }
        self.deleteThumbAtIndex(index)
    }
    
    func deleteThumbAtIndex(_ index:Int) {
        guard self.trackSlider.thumbCount > 2 else {
            return
        }
        
        self.registerUndo() { [value = self.trackSlider.thumbs[index]] target in
            target.addThumbAt(value)
        }
        
        self.colors.remove(at: index)
        self.undoColors.remove(at: index)
        self.trackSlider.removeThumbAtIndex(index)
        self.calculateGradient()
    }
    
    @objc func saveGradient(_ sender:Notification) {
        self.delegate.saveGradient(self.gradientContainer)
        self.gradientTableView.reloadData()
        self.selectCurrentGradientWithHandler(false)
    }
    
    @objc func saveNewGradient(_ sender:Notification) {
        self.delegate.addGradient(self.gradientContainer)
        self.gradientTableView.reloadData()
    }
    
    @IBAction func rightClickedOnGradientTable(_ sender: NSClickGestureRecognizer) {
        
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        self.presenting?.dismissViewController(self)
        self.delegate.saveGradient(self.gradientContainer)
    }
    
    // MARK: - NSMultiSliderDelegate
    
    func colorOfThumbAtIndex(_ index: Int) -> NSColor {
        return self.colors[index]
    }
    
    func thumbSlider(_ slider: NSMultiSlider, selectedThumbAt thumbIndex: Int) {
        self.currentThumbIndex = thumbIndex
        self.colorSliderContainer.color = self.colors[thumbIndex]
        self.lastSliderValue = slider.thumbs[thumbIndex]
    }
    
    func thumbSlider(_ slider: NSMultiSlider, movedThumbAt thumbIndex: Int, to value: CGFloat) {
        self.calculateGradient(false)
    }
    
    func thumbSlider(_ slider:NSMultiSlider, stoppedMovingThumbAt thumbIndex:Int) {
        self.gradientContainer.gradient = self.gradientView.gradient!
        self.moveThumbAtIndex(thumbIndex, to: self.lastSliderValue, undoing: false)
    }
    
    func moveThumbAtIndex(_ thumbIndex:Int, to value:CGFloat, undoing:Bool) {
        let newValue = (undoing ? self.trackSlider.thumbs[thumbIndex] : value)
        self.registerUndo() { target in
            self.moveThumbAtIndex(thumbIndex, to: newValue, undoing: true)
        }
        if undoing {
            self.trackSlider.setThumb(value, atIndex: thumbIndex)
            self.calculateGradient(false)
            self.trackSlider.setNeedsDisplay()
        }
    }
    
    func postGradientChangedNotification(_ gradient:Gradient) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: GradientViewController.GradientChangedNotification), object: self, userInfo: ["Gradient":gradient])
    }
    
    // MARK: - Undo
    
    func registerUndo(_ closure:@escaping (GradientViewController) -> Void) {
        guard self.undoingEnabled else {
            return
        }
        guard let undoManager = self.undoManager else {
            return
        }
        undoManager.registerUndo(withTarget: self, handler: closure)
    }
    
    func undo(_ sender:AnyObject) {
        self.undoManager?.undo()
    }
    
    func redo(_ sender:AnyObject) {
        self.undoManager?.redo()
    }
    
}
