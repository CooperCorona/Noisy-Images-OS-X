//
//  MenuController.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 4/3/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import CoronaConvenience
import CoronaStructures
import CoronaGL
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
    
    func widthChanged(_ width:CGFloat)
    func heightChanged(_ height:CGFloat)
    func noiseWidthChanged(_ noiseWidth:CGFloat)
    func noiseHeightChanged(_ noiseHeight:CGFloat)
    func xOffsetChanged(_ xOffset:CGFloat)
    func yOffsetChanged(_ yOffset:CGFloat)
    func zOffsetChanged(_ zOffset:CGFloat)
    func noiseTypeChanged(_ noiseType:GLSPerlinNoiseSprite.NoiseType)
    func seedChanged(_ seed:UInt32)
    func noiseDivisorChanged(_ noiseDivisor:CGFloat)
    func isTiledChanged(_ isTiled:Bool)
    func noiseAngleChanged(_ noiseAngle:CGFloat)
    func gradientChanged(_ gradient:ColorGradient1D)
    
    func textureChanged(_ texture:CCTexture, withData data:Data?)
    
    func stateChanged(_ state:NoiseState)
    
}

class MenuController: NSViewController, NSTextFieldDelegate, GradientContainerDelegate {

    // MARK: - Properties
    
    fileprivate static let minDivisor:CGFloat = 0.35
    fileprivate static let maxDivisor:CGFloat = 1.05
    fileprivate static let maxNoiseAngleSlider:CGFloat = 100.0
    
    let integerFormatter = NumberFormatter()
    let floatFormatter = NumberFormatter()
    
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
    @IBOutlet weak var noiseAngleTextField: NSTextField!
    @IBOutlet weak var noiseAngleSlider: NSSlider!
    @IBOutlet weak var isTiledCheckBox: NSButton!
    @IBOutlet weak var gradientView: ColorGradientView!
    
    // MARK: - Computed Properties
    
    fileprivate var internalWidth:CGFloat       = 256.0
    fileprivate var internalHeight:CGFloat      = 256.0
    fileprivate var internalNoiseWidth:CGFloat  = 4.0
    fileprivate var internalNoiseHeight:CGFloat = 4.0
    fileprivate var internalXOffset:CGFloat     = 0.0
    fileprivate var internalYOffset:CGFloat     = 0.0
    fileprivate var internalZOffset:CGFloat     = 0.0
    fileprivate var internalNoiseType           = GLSPerlinNoiseSprite.NoiseType.Default
    fileprivate var internalSeed:UInt32         = 0
    fileprivate var internalNoiseDivisor:CGFloat = 0.7
    fileprivate var internalIsTiled             = false
    fileprivate var internalNoiseAngle:CGFloat  = 0.0
    
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
                self.noiseTypePopUp.selectItem(at: 0)
            case .Fractal:
                self.noiseTypePopUp.selectItem(at: 1)
            case .Abs:
                self.noiseTypePopUp.selectItem(at: 2)
            case .Sin:
                self.noiseTypePopUp.selectItem(at: 3)
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
            self.noiseAngleSlider.CGFloatValue = MenuController.convertNoiseAngleToSlider(newValue)
            self.noiseAngleTextField.CGFloatValue = newValue
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
    
    var imageURL:URL?     = nil
    var textureData:Data? = nil
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
        
        self.widthTextField.formatter       = self.integerFormatter.copy() as! NumberFormatter
        self.heightTextField.formatter      = self.integerFormatter.copy() as! NumberFormatter
        self.noiseWidthTextField.formatter  = self.floatFormatter.copy() as! NumberFormatter
        self.noiseHeightTextField.formatter = self.floatFormatter.copy() as! NumberFormatter
        self.xOffsetTextField.formatter     = self.floatFormatter.copy() as! NumberFormatter
        self.yOffsetTextField.formatter     = self.floatFormatter.copy() as! NumberFormatter
        self.zOffsetTextField.formatter     = self.floatFormatter.copy() as! NumberFormatter
        self.noiseAngleTextField.formatter  = self.floatFormatter.copy() as! NumberFormatter
        
        self.noiseTypePopUp.addItems(withTitles: ["Default", "Fractal", "Abs", "Sin"])
        self.gradientView.gradient = ColorGradient1D.grayscaleGradient
        
        self.gradientContainer.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        NotificationCenter.default.addObserver(self, selector: #selector(widthTextFieldChanged), name: NSControl.textDidEndEditingNotification, object: self.widthTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(heightTextFieldChanged), name: NSControl.textDidEndEditingNotification, object: self.heightTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(noiseWidthTextFieldChanged), name: NSControl.textDidEndEditingNotification, object: self.noiseWidthTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(noiseHeightTextFieldChanged), name: NSControl.textDidEndEditingNotification, object: self.noiseHeightTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(xOffsetTextFieldChanged), name: NSControl.textDidEndEditingNotification, object: self.xOffsetTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(yOffsetTextFieldChanged), name: NSControl.textDidEndEditingNotification, object: self.yOffsetTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(zOffsetTextFieldChanged), name: NSControl.textDidEndEditingNotification, object: self.zOffsetTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(seedTextFieldChanged), name: NSControl.textDidEndEditingNotification, object: self.seedTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(seedTextFieldChanged), name: NSControl.textDidEndEditingNotification, object: self.seedTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(noiseAngleTextFieldChanged), name: NSControl.textDidEndEditingNotification, object: self.noiseAngleTextField)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Logic
    
    class func convertSliderToDivisor(_ slider:CGFloat) -> CGFloat {
        return linearlyInterpolate(slider, left: self.minDivisor, right: self.maxDivisor)
    }
    
    class func convertDivisorToSlider(_ divisor:CGFloat) -> CGFloat {
        return (divisor - MenuController.minDivisor) / (MenuController.maxDivisor - MenuController.minDivisor)
    }
    
    class func convertSliderToNoiseAngle(_ slider:CGFloat) -> CGFloat {
        /*
         *  The slider considers 0.0 to be the top, goes clockwise, and ends
         *  at 100.0. The noise angle starts at the right, goes counterclockwise,
         *  and ends at 2π.
         *      ((MenuController.maxNoiseAngleSlider - slider)
         *      - MenuController.maxNoiseAngleSlider / 4.0)
         *      / MenuController.maxNoiseAngleSlider
         *      * 2π
         */
        
        return (0.25 - slider / MenuController.maxNoiseAngleSlider) * 2 * CGFloat.pi
    }
    
    class func convertNoiseAngleToSlider(_ noiseAngle:CGFloat) -> CGFloat {
        return (0.25 - noiseAngle / (2.0 * CGFloat.pi)) * MenuController.maxNoiseAngleSlider
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        self.noiseWidthTextFieldChanged(obj as AnyObject)
    }
    
    @objc func widthTextFieldChanged(_ sender: AnyObject) {
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
    
    @objc func heightTextFieldChanged(_ sender: AnyObject) {
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
    
    
    @objc func noiseWidthTextFieldChanged(_ sender: AnyObject) {
        self.noiseWidth = self.noiseWidthTextField.CGFloatValue
        self.noiseWidthTextField.window?.makeFirstResponder(nil)
        
        self.delegate?.noiseWidthChanged(self.noiseWidth)
    }
    
    @objc func noiseHeightTextFieldChanged(_ sender: AnyObject) {
        self.noiseHeight = self.noiseHeightTextField.CGFloatValue
        self.noiseHeightTextField.window?.makeFirstResponder(nil)
        
        self.delegate?.noiseHeightChanged(self.noiseHeight)
    }
    
    @objc func xOffsetTextFieldChanged(_ sender: AnyObject) {
        self.xOffset = self.xOffsetTextField.CGFloatValue
        
        self.delegate?.xOffsetChanged(self.xOffset)
    }
    
    @objc func yOffsetTextFieldChanged(_ sender: AnyObject) {
        self.yOffset = self.yOffsetTextField.CGFloatValue
        
        self.delegate?.yOffsetChanged(self.yOffset)
    }
    
    @objc func zOffsetTextFieldChanged(_ sender: AnyObject) {
        self.zOffset = self.zOffsetTextField.CGFloatValue
        
        self.delegate?.zOffsetChanged(self.zOffset)
    }
    
    @objc func seedTextFieldChanged(_ sender: AnyObject) {
        self.seed = UInt32(self.seedTextField.intValue)
        self.delegate?.seedChanged(self.seed)
    }
    
    @objc func noiseAngleTextFieldChanged(_ sender: AnyObject) {
        self.noiseAngle = self.noiseAngleTextField.CGFloatValue
        self.delegate?.noiseAngleChanged(self.noiseAngle)
    }
    
    
    @IBAction func noiseWidthStepperChanged(_ sender: AnyObject) {
        self.noiseWidth = self.noiseWidthStepper.CGFloatValue
        self.delegate?.noiseWidthChanged(self.noiseWidth)
    }
    
    @IBAction func noiseHeightStepperChanged(_ sender: AnyObject) {
        self.noiseHeight = self.noiseHeightStepper.CGFloatValue
        self.delegate?.noiseHeightChanged(self.noiseHeight)
    }
    
    @IBAction func xOffsetStepperChanged(_ sender: AnyObject) {
        self.xOffset = self.xOffsetStepper.CGFloatValue
        self.delegate?.xOffsetChanged(self.xOffset)
    }
    
    @IBAction func yOffsetStepperChanged(_ sender: AnyObject) {
        self.yOffset = self.yOffsetStepper.CGFloatValue
        self.delegate?.yOffsetChanged(self.yOffset)
    }
    
    @IBAction func zOffsetStepperChanged(_ sender: AnyObject) {
        self.zOffset = self.zOffsetStepper.CGFloatValue
        self.delegate?.zOffsetChanged(self.zOffset)
    }

    @IBAction func noiseTypePopUpChanged(_ sender: AnyObject) {
        
        guard let title = self.noiseTypePopUp.selectedItem?.title, let noiseType = GLSPerlinNoiseSprite.NoiseType(rawValue: title) else {
            return
        }
        
        self.internalNoiseType = noiseType
        self.delegate?.noiseTypeChanged(noiseType)
    }
    
    @IBAction func scrambleButtonPressed(_ sender: AnyObject) {
        self.seed = arc4random()
        self.seedTextField.stringValue = "\(self.seed)"
        self.delegate?.seedChanged(self.seed)
    }

    @IBAction func noiseDivisorSliderChanged(_ sender: AnyObject) {
        self.internalNoiseDivisor = MenuController.convertSliderToDivisor(self.noiseDivisorSlider.CGFloatValue)
        self.delegate?.noiseDivisorChanged(self.internalNoiseDivisor)
    }
    
    @IBAction func noiseAngleSliderChanged(_ sender: NSSlider) {
        self.internalNoiseAngle = MenuController.convertSliderToNoiseAngle(sender.CGFloatValue)
        self.noiseAngleTextField.CGFloatValue = self.internalNoiseAngle
        self.delegate?.noiseAngleChanged(self.internalNoiseAngle)
    }
    
    @IBAction func isTiledCheckBoxChanged(_ sender: AnyObject) {
        self.internalIsTiled = self.isTiledCheckBox.boolValue
        self.delegate?.isTiledChanged(self.internalIsTiled)
    }
    
    @IBAction func flipButtonPressed(_ sender: AnyObject) {
        swap(&self.width, &self.height)
        swap(&self.noiseWidth, &self.noiseHeight)
        self.delegate?.stateChanged(self.state)
    }

    @IBAction func imageButtonPressed(_ sender: AnyObject) {
        let op = NSOpenPanel()
        op.treatsFilePackagesAsDirectories = false
        op.allowedFileTypes = ["png", "jpg", "pdf"]
        switch op.runModal() {
        case NSApplication.ModalResponse.OK:
            self.imageURL = op.url
            guard let url = op.url else {
                return
            }
            self.loadTextureFromURL(url)
        default:
            break
        }
    }
    
    @IBAction func squareButtonPressed(_ sender: AnyObject) {
        let texture         = CCTextureOrganizer.textureForString("White Tile")!
        self.textureData    = nil
        self.texture        = texture
        self.delegate?.textureChanged(texture, withData: nil)
    }
    
    @IBAction func circleButtonPressed(_ sender: AnyObject) {
        let texture         = CCTextureOrganizer.textureForString("White Circle")!
        self.textureData    = nil
        self.texture        = texture
        self.delegate?.textureChanged(texture, withData: nil)
    }
    
    func loadTextureFromURL(_ url:URL) {
//        guard let path = url.path else {
//            self.presentImageErrorAlert()
//            return
//        }
        let path = url.path
        
        if let texture = self.texture {
            var name = texture.name
            glDeleteTextures(1, &name)
        }
        do {
            let tex:GLKTextureInfo
            if path.hasSuffix("pdf") {
                guard let image = NSImage.imageWithPDFURL(url as NSURL, size: NSSize(width: width, height: height)) else {
                    self.presentImageErrorAlert()
                    return
                }
                let data = image.tiffRepresentation!
                self.textureData = data
                tex = try GLKTextureLoader.texture(withContentsOf: data, options: [GLKTextureLoaderOriginBottomLeft:true])
            } else {
                guard let data = try? Data(contentsOf: url) else {
                    self.presentImageErrorAlert()
                    return
                }
                self.textureData = data
                tex = try GLKTextureLoader.texture(withContentsOf: data, options: [GLKTextureLoaderOriginBottomLeft:true])
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
        alert.alertStyle = NSAlert.Style.warning
        alert.messageText = "Could not load image. Sorry!"
        alert.addButton(withTitle: "Ok")
        alert.runModal()
    }
    
    func gradientChanged(_ gradientContainer: GradientContainer) {
        let gradient = gradientContainer.gradient.blendColor(gradientContainer.overlay.getVector4())
        self.gradientView.gradient = gradient
        self.delegate?.gradientChanged(gradient)
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.identifier?.rawValue {
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
    
    func registerUndo(_ closure:@escaping (MenuController) -> Void) {
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
