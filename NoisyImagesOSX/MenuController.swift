//
//  MenuController.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 4/3/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import OmniSwiftX
import GLKit

extension NSControl {
    
    public var CGFloatValue:CGFloat {
        get { return CGFloat(self.doubleValue) }
        set { self.doubleValue = Double(newValue) }
    }
    
    public var boolValue:Bool {
        get { return self.intValue != 0 }
        set {
            self.intValue = newValue ? 1 : 0
        }
    }
    
}

protocol MenuControllerDelegate: class {
    
    func widthChanged(width:CGFloat)
    func heightChanged(height:CGFloat)
    func noiseWidthChanged(noiseWidth:CGFloat)
    func noiseHeightChanged(noiseHeight:CGFloat)
    func xOffsetChanged(xOffset:CGFloat)
    func yOffsetChanged(yOffset:CGFloat)
    func zOffsetChanged(zOffset:CGFloat)
    func noiseTypeChanged(noiseType:GLSPerlinNoiseSprite.NoiseType)
    func seedChanged(seed:UInt32)
    func noiseDivisorChanged(noiseDivisor:CGFloat)
    func isTiledChanged(isTiled:Bool)
    func noiseAngleChanged(noiseAngle:CGFloat)
    func gradientChanged(gradient:ColorGradient1D)
    
    func textureChanged(texture:CCTexture, withData data:NSData?)
    
    func stateChanged(state:NoiseState)
    
}

class MenuController: NSViewController, NSTextFieldDelegate, GradientContainerDelegate {

    // MARK: - Properties
    
    private static let minDivisor:CGFloat = 0.35
    private static let maxDivisor:CGFloat = 1.05
    
    let integerFormatter = NSNumberFormatter()
    let floatFormatter = NSNumberFormatter()
    
    @IBOutlet weak var widthTextField: NSTextField!
    @IBOutlet weak var heightTextField: NSTextField!
    @IBOutlet weak var noiseWidthTextField: NSTextField!
    @IBOutlet weak var noiseHeightTextField: NSTextField!
    @IBOutlet weak var xOffsetTextField: NSTextField!
    @IBOutlet weak var yOffsetTextField: NSTextField!
    @IBOutlet weak var zOffsetTextField: NSTextField!
    @IBOutlet weak var noiseWidthStepper: NSStepper!
    @IBOutlet weak var noiseHeightStepper: NSStepper!
    @IBOutlet weak var xOffsetStepper: NSStepper!
    @IBOutlet weak var yOffsetStepper: NSStepper!
    @IBOutlet weak var zOffsetStepper: NSStepper!
    @IBOutlet weak var noiseTypePopUp: NSPopUpButton!
    @IBOutlet weak var seedTextField: NSTextField!
    @IBOutlet weak var noiseDivisorSlider: NSSlider!
    @IBOutlet weak var isTiledCheckBox: NSButton!
    @IBOutlet weak var gradientView: ColorGradientView!
    
    // MARK: - Computed Properties
    
    private var internalWidth:CGFloat       = 256.0
    private var internalHeight:CGFloat      = 256.0
    private var internalNoiseWidth:CGFloat  = 4.0
    private var internalNoiseHeight:CGFloat = 4.0
    private var internalXOffset:CGFloat     = 0.0
    private var internalYOffset:CGFloat     = 0.0
    private var internalZOffset:CGFloat     = 0.0
    private var internalNoiseType           = GLSPerlinNoiseSprite.NoiseType.Default
    private var internalSeed:UInt32         = 0
    private var internalNoiseDivisor:CGFloat = 0.7
    private var internalIsTiled             = false
    private var internalNoiseAngle:CGFloat  = 0.0
    
    var width:CGFloat {
        get { return self.internalWidth }
        set {
            guard self.width != newValue else {
                return
            }
            self.registerUndo() { [value = self.width] target in
                target.width = value
                target.delegate?.widthChanged(value)
            }
            self.internalWidth = newValue
            self.widthTextField.CGFloatValue = newValue
        }
    }
    var height:CGFloat {
        get { return self.internalHeight }
        set {
            guard self.height != newValue else {
                return
            }
            self.registerUndo() { [value = self.height] target in
                target.height = value
                target.delegate?.heightChanged(value)
            }
            self.internalHeight = newValue
            self.heightTextField.CGFloatValue = newValue
        }
    }
    var noiseWidth:CGFloat {
        get { return self.internalNoiseWidth }
        set {
            guard self.noiseWidth != newValue else {
                return
            }
            let value = self.noiseWidth
            self.registerUndo() { target in
                target.noiseWidth = value
                target.delegate?.noiseWidthChanged(value)
            }
            self.internalNoiseWidth = newValue
            self.noiseWidthTextField.CGFloatValue = newValue
            self.noiseWidthStepper.CGFloatValue = newValue
        }
    }
    var noiseHeight:CGFloat {
        get { return self.internalNoiseHeight }
        set {
            guard self.noiseHeight != newValue else {
                return
            }
            self.registerUndo() { [value = self.noiseHeight] target in
                target.noiseHeight = value
                target.delegate?.noiseHeightChanged(value)
            }
            
            self.internalNoiseHeight = newValue
            self.noiseHeightTextField.CGFloatValue = newValue
            self.noiseHeightStepper.CGFloatValue = newValue
        }
    }
    var xOffset:CGFloat {
        get { return self.internalXOffset }
        set {
            guard self.xOffset != newValue else {
                return
            }
            self.registerUndo() { [value = self.xOffset] target in
                target.xOffset = value
                target.delegate?.xOffsetChanged(value)
            }
            self.internalXOffset = newValue
            self.xOffsetTextField.CGFloatValue = newValue
            self.xOffsetStepper.CGFloatValue = newValue
        }
    }
    var yOffset:CGFloat {
        get { return self.internalYOffset }
        set {
            guard self.yOffset != newValue else {
                return
            }
            self.registerUndo() { [value = self.yOffset] target in
                target.yOffset = value
                target.delegate?.yOffsetChanged(value)
            }
            self.internalYOffset = newValue
            self.yOffsetTextField.CGFloatValue = newValue
            self.yOffsetStepper.CGFloatValue = newValue
        }
    }
    var zOffset:CGFloat {
        get { return self.internalZOffset }
        set {
            guard self.zOffset != newValue else {
                return
            }
            self.registerUndo() { [value = self.zOffset] target in
                target.zOffset = value
                target.delegate?.zOffsetChanged(value)
            }
            self.internalZOffset = newValue
            self.zOffsetTextField.CGFloatValue = newValue
            self.zOffsetStepper.CGFloatValue = newValue
        }
    }
    var noiseType:GLSPerlinNoiseSprite.NoiseType {
        get { return self.internalNoiseType }
        set {
            guard self.noiseType != newValue else {
                return
            }
            self.registerUndo() { [value = self.noiseType] target in
                target.noiseType = value
                target.delegate?.noiseTypeChanged(value)
            }
            
            self.internalNoiseType = newValue
            switch self.internalNoiseType {
            case .Default:
                self.noiseTypePopUp.selectItemAtIndex(0)
            case .Fractal:
                self.noiseTypePopUp.selectItemAtIndex(1)
            case .Abs:
                self.noiseTypePopUp.selectItemAtIndex(2)
            case .Sin:
                self.noiseTypePopUp.selectItemAtIndex(3)
            }
        }
    }
    var seed:UInt32 {
        get { return self.internalSeed }
        set {
            guard self.seed != newValue else {
                return
            }
            self.registerUndo() { [value = self.seed] target in
                target.seed = value
                target.delegate?.seedChanged(value)
            }
            
            self.internalSeed = newValue
            self.seedTextField.stringValue = "\(newValue)"
        }
    }
    var noiseDivisor:CGFloat {
        get { return self.internalNoiseDivisor }
        set {
            guard self.noiseDivisor != newValue else {
                return
            }
            self.registerUndo() { [value = self.noiseDivisor] target in
                target.noiseDivisor = value
                target.delegate?.noiseDivisorChanged(value)
            }
            self.internalNoiseDivisor = newValue
            self.noiseDivisorSlider.CGFloatValue = MenuController.convertDivisorToSlider(newValue)
        }
    }
    var isTiled:Bool {
        get { return self.internalIsTiled }
        set {
            guard self.isTiled != newValue else {
                return
            }
            self.registerUndo() { [value = self.isTiled] target in
                target.isTiled = value
                target.delegate?.isTiledChanged(value)
            }
            self.internalIsTiled = newValue
            self.isTiledCheckBox.intValue = newValue ? 1 : 0
        }
    }
    var noiseAngle:CGFloat {
        get { return self.internalNoiseAngle }
        set {
            guard self.noiseAngle != newValue else {
                return
            }
            self.registerUndo() { [value = self.noiseAngle] target in
                target.noiseAngle = value
                target.delegate?.noiseAngleChanged(value)
            }
            self.internalNoiseAngle = newValue
        }
    }
    var state:NoiseState {
        get {
            return NoiseState(width: self.width, height: self.height, noiseWidth: self.noiseWidth, noiseHeight: self.noiseHeight, xOffset: self.xOffset, yOffset: self.yOffset, zOffset: self.zOffset, seed: self.seed, noiseDivisor: self.noiseDivisor, noiseType: self.noiseType, isTiled: self.isTiled, noiseAngle: self.noiseAngle, gradient: self.gradientContainer.gradient)
        }
        set {
            self.width          = newValue.width
            self.height         = newValue.height
            self.noiseWidth     = newValue.noiseWidth
            self.noiseHeight    = newValue.noiseHeight
            self.xOffset        = newValue.xOffset
            self.yOffset        = newValue.yOffset
            self.zOffset        = newValue.zOffset
            self.seed           = newValue.seed
            self.noiseDivisor   = newValue.noiseDivisor
            self.noiseType      = newValue.noiseType
            self.noiseAngle     = newValue.noiseAngle
            self.gradientContainer.gradient = newValue.gradient
        }
    }
    
    weak var delegate:MenuControllerDelegate? = nil
    var undoingEnabled = true
    
    var gradientContainer = GradientContainer()
    
    var imageURL:NSURL?     = nil
    var textureData:NSData? = nil
    var texture:CCTexture?  = nil
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.integerFormatter.allowsFloats  = false
        self.integerFormatter.minimum       = 8.0
        self.integerFormatter.maximum       = 1024.0
        self.floatFormatter.allowsFloats    = true
        self.floatFormatter.minimum         = 0.0
        self.floatFormatter.maximum         = 1024.0
        self.floatFormatter.minimumFractionDigits = 0
        self.floatFormatter.maximumFractionDigits = 4
        
        self.widthTextField.formatter       = self.integerFormatter.copy() as! NSNumberFormatter
        self.heightTextField.formatter      = self.integerFormatter.copy() as! NSNumberFormatter
        self.noiseWidthTextField.formatter  = self.floatFormatter.copy() as! NSNumberFormatter
        self.noiseHeightTextField.formatter = self.floatFormatter.copy() as! NSNumberFormatter
        self.xOffsetTextField.formatter     = self.floatFormatter.copy() as! NSNumberFormatter
        self.yOffsetTextField.formatter     = self.floatFormatter.copy() as! NSNumberFormatter
        self.zOffsetTextField.formatter     = self.floatFormatter.copy() as! NSNumberFormatter
        
        self.noiseTypePopUp.addItemsWithTitles(["Default", "Fractal", "Abs", "Sin"])
        self.gradientView.gradient = ColorGradient1D.grayscaleGradient
        
        self.gradientContainer.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(widthTextFieldChanged), name: NSControlTextDidEndEditingNotification, object: self.widthTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(heightTextFieldChanged), name: NSControlTextDidEndEditingNotification, object: self.heightTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(noiseWidthTextFieldChanged), name: NSControlTextDidEndEditingNotification, object: self.noiseWidthTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(noiseHeightTextFieldChanged), name: NSControlTextDidEndEditingNotification, object: self.noiseHeightTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(xOffsetTextFieldChanged), name: NSControlTextDidEndEditingNotification, object: self.xOffsetTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(yOffsetTextFieldChanged), name: NSControlTextDidEndEditingNotification, object: self.yOffsetTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(zOffsetTextFieldChanged), name: NSControlTextDidEndEditingNotification, object: self.zOffsetTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(seedTextFieldChanged), name: NSControlTextDidEndEditingNotification, object: self.seedTextField)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Logic
    
    class func convertSliderToDivisor(slider:CGFloat) -> CGFloat {
        return linearlyInterpolate(slider, left: self.minDivisor, right: self.maxDivisor)
    }
    
    class func convertDivisorToSlider(divisor:CGFloat) -> CGFloat {
        return (divisor - MenuController.minDivisor) / (MenuController.maxDivisor - MenuController.minDivisor)
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        self.noiseWidthTextFieldChanged(obj)
    }
    
    func widthTextFieldChanged(sender: AnyObject) {
        self.width = self.widthTextField.CGFloatValue
        self.widthTextField.window?.makeFirstResponder(nil)
        
        /*
         *  Currently, pdfs do not scale at all, so reloading
         *  the image on a size change is pointless.
        if let url = self.imageURL {
            self.loadTextureFromURL(url)
        }
         */
        self.delegate?.widthChanged(self.width)
    }
    
    func heightTextFieldChanged(sender: AnyObject) {
        self.height = self.heightTextField.CGFloatValue
        
        /*
         *  Currently, pdfs do not scale at all, so reloading
         *  the image on a size change is pointless.
        if let url = self.imageURL {
            self.loadTextureFromURL(url)
        }
         */
        self.delegate?.heightChanged(self.height)
    }
    
    
    func noiseWidthTextFieldChanged(sender: AnyObject) {
        self.noiseWidth = self.noiseWidthTextField.CGFloatValue
        self.noiseWidthTextField.window?.makeFirstResponder(nil)
        
        self.delegate?.noiseWidthChanged(self.noiseWidth)
    }
    
    func noiseHeightTextFieldChanged(sender: AnyObject) {
        self.noiseHeight = self.noiseHeightTextField.CGFloatValue
        self.noiseHeightTextField.window?.makeFirstResponder(nil)
        
        self.delegate?.noiseHeightChanged(self.noiseHeight)
    }
    
    func xOffsetTextFieldChanged(sender: AnyObject) {
        self.xOffset = self.xOffsetTextField.CGFloatValue
        
        self.delegate?.xOffsetChanged(self.xOffset)
    }
    
    func yOffsetTextFieldChanged(sender: AnyObject) {
        self.yOffset = self.yOffsetTextField.CGFloatValue
        
        self.delegate?.yOffsetChanged(self.yOffset)
    }
    
    func zOffsetTextFieldChanged(sender: AnyObject) {
        self.zOffset = self.zOffsetTextField.CGFloatValue
        
        self.delegate?.zOffsetChanged(self.zOffset)
    }
    
    func seedTextFieldChanged(sender: AnyObject) {
        self.seed = UInt32(self.seedTextField.intValue)
        self.delegate?.seedChanged(self.seed)
    }
    
    
    @IBAction func noiseWidthStepperChanged(sender: AnyObject) {
        self.noiseWidth = self.noiseWidthStepper.CGFloatValue
        self.delegate?.noiseWidthChanged(self.noiseWidth)
    }
    
    @IBAction func noiseHeightStepperChanged(sender: AnyObject) {
        self.noiseHeight = self.noiseHeightStepper.CGFloatValue
        self.delegate?.noiseHeightChanged(self.noiseHeight)
    }
    
    @IBAction func xOffsetStepperChanged(sender: AnyObject) {
        self.xOffset = self.xOffsetStepper.CGFloatValue
        self.delegate?.xOffsetChanged(self.xOffset)
    }
    
    @IBAction func yOffsetStepperChanged(sender: AnyObject) {
        self.yOffset = self.yOffsetStepper.CGFloatValue
        self.delegate?.yOffsetChanged(self.yOffset)
    }
    
    @IBAction func zOffsetStepperChanged(sender: AnyObject) {
        self.zOffset = self.zOffsetStepper.CGFloatValue
        self.delegate?.zOffsetChanged(self.zOffset)
    }

    @IBAction func noiseTypePopUpChanged(sender: AnyObject) {
        
        guard let title = self.noiseTypePopUp.selectedItem?.title, let noiseType = GLSPerlinNoiseSprite.NoiseType(rawValue: title) else {
            return
        }
        
        self.internalNoiseType = noiseType
        self.delegate?.noiseTypeChanged(noiseType)
    }
    
    @IBAction func scrambleButtonPressed(sender: AnyObject) {
        self.seed = arc4random()
        self.seedTextField.stringValue = "\(self.seed)"
        self.delegate?.seedChanged(self.seed)
    }

    @IBAction func noiseDivisorSliderChanged(sender: AnyObject) {
        self.internalNoiseDivisor = MenuController.convertSliderToDivisor(self.noiseDivisorSlider.CGFloatValue)
        self.delegate?.noiseDivisorChanged(self.internalNoiseDivisor)
    }
    
    @IBAction func isTiledCheckBoxChanged(sender: AnyObject) {
        self.internalIsTiled = self.isTiledCheckBox.boolValue
        self.delegate?.isTiledChanged(self.internalIsTiled)
    }
    
    @IBAction func flipButtonPressed(sender: AnyObject) {
        swap(&self.width, &self.height)
        swap(&self.noiseWidth, &self.noiseHeight)
        self.delegate?.stateChanged(self.state)
    }

    @IBAction func imageButtonPressed(sender: AnyObject) {
        let op = NSOpenPanel()
        op.treatsFilePackagesAsDirectories = false
        op.allowedFileTypes = ["noise"]
        switch op.runModal() {
        case NSModalResponseOK:
            self.imageURL = op.URL
            guard let url = op.URL else {
                return
            }
            self.loadTextureFromURL(url)
        default:
            break
        }
    }
    
    @IBAction func squareButtonPressed(sender: AnyObject) {
        let texture         = CCTextureOrganizer.textureForString("White Tile")!
        self.textureData    = nil
        self.texture        = texture
        self.delegate?.textureChanged(texture, withData: nil)
    }
    
    @IBAction func circleButtonPressed(sender: AnyObject) {
        let texture         = CCTextureOrganizer.textureForString("White Circle")!
        self.textureData    = nil
        self.texture        = texture
        self.delegate?.textureChanged(texture, withData: nil)
    }
    
    func loadTextureFromURL(url:NSURL) {
        guard let path = url.path else {
            self.presentImageErrorAlert()
            return
        }
        
        if let texture = self.texture {
            var name = texture.name
            glDeleteTextures(1, &name)
        }
        do {
            let tex:GLKTextureInfo
            if path.hasSuffix("pdf") {
                guard let image = NSImage.imageWithPDFURL(url, size: NSSize(width: width, height: height)) else {
                    self.presentImageErrorAlert()
                    return
                }
                let data = image.TIFFRepresentation!
                self.textureData = data
                tex = try GLKTextureLoader.textureWithContentsOfData(data, options: [GLKTextureLoaderOriginBottomLeft:true])
            } else {
                guard let data = NSData(contentsOfURL: url) else {
                    self.presentImageErrorAlert()
                    return
                }
                self.textureData = data
                tex = try GLKTextureLoader.textureWithContentsOfData(data, options: [GLKTextureLoaderOriginBottomLeft:true])
            }
            self.texture = CCTexture(name: tex.name)
            self.delegate?.textureChanged(self.texture!, withData: self.textureData)
        } catch {
            print(error)
            self.presentImageErrorAlert()
        }
    }
    
    func presentImageErrorAlert() {
        let alert = NSAlert()
        alert.alertStyle = NSAlertStyle.WarningAlertStyle
        alert.messageText = "Could not load image. Sorry!"
        alert.addButtonWithTitle("Ok")
        alert.runModal()
    }
    
    func gradientChanged(gradientContainer: GradientContainer) {
        let gradient = gradientContainer.gradient.blendColor(gradientContainer.overlay.getVector4())
        self.gradientView.gradient = gradient
        self.delegate?.gradientChanged(gradient)
    }
    
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "GradientSegue"?:
            guard let dest = segue.destinationController as? GradientViewController else {
                return
            }
            dest.gradientContainer = self.gradientContainer
        default:
            break
        }
    }
    
    // MARK: - Undo
    
    func registerUndo(closure:(MenuController) -> Void) {
        guard self.undoingEnabled else {
            return
        }
        guard let undoManager = self.undoManager else {
            return
        }
        undoManager.registerUndoWithTarget(self, handler: closure)
    }
    
    func undo(sender:AnyObject) {
        self.undoManager?.undo()
    }
    
    func redo(sender:AnyObject) {
        self.undoManager?.redo()
    }
    
}
