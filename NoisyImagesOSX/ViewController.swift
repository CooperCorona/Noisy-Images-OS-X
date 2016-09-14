//
//  ViewController.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 3/26/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import CoronaConvenience
import CoronaStructures
import CoronaGL

class PNGSavePanelDelegate: NSObject, NSOpenSavePanelDelegate {
    
    enum Error: ErrorType {
        case InvalidPath
        case InvalidExtension
    }
    
    let validExtensions:[String]
    
    init(extensions:[String]) {
        self.validExtensions = extensions
    }
    
    convenience override init() {
        self.init(extensions: ["png"])
    }
    
    func panel(sender: AnyObject, validateURL url: NSURL) throws {
        guard let path = url.path else {
            throw Error.InvalidPath
        }
        for ext in self.validExtensions {
            if path.hasSuffix(ext) {
                return
            }
        }
        throw Error.InvalidExtension
    }
    
}

class ViewController: NSViewController {

    @IBOutlet weak var glView: OmniGLView2d!
    lazy var timer:NSTimer = NSTimer(timeInterval: 1.0 / 30.0, target: self, selector: #selector(timerMethod), userInfo: nil, repeats: true)
    var time:CGFloat = 0.0
    
    lazy var checkerSprite:GLSCheckerSprite = GLSCheckerSprite(off: SCVector4.lightGrayColor, on: SCVector4.whiteColor, size: self.glView.frame.size)
    lazy var noiseSprite:GLSPerlinNoiseSprite = GLSPerlinNoiseSprite(size: NSSize(square: 256.0), texture: "White Tile", noise: Noise3DTexture2D(), gradient: GLGradientTexture2D(gradient: ColorGradient1D.grayscaleGradient))
    
    weak var menuController:MenuController? = nil
    private var isTiled = false
    
    private var zoomLevels:[CGFloat] = [1.0 / 16.0, 1.0 / 8.0, 1.0 / 4.0, 1.0 / 3.0, 1.0 / 2.0, 1.0, 2.0, 3.0, 4.0, 8.0, 16.0]
    private var zoomLevelIndex = 5
    private var zoomLevel:CGFloat { return self.zoomLevels[self.zoomLevelIndex] }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        OmniGLView2d.setupOpenGL()
        self.glView.clearColor = SCVector4.blackColor
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()

        self.checkerSprite.anchor = NSPoint.zero
        self.glView.addChild(self.checkerSprite)
        
        self.noiseSprite.position = self.glView.frame.size.center
        self.glView.addChild(self.noiseSprite)
        self.renderToTexture()
        let menu = (self.parentViewController?.childViewControllers.first as? MenuController)
        menu?.seed = self.noiseSprite.noiseTexture.noise.seed
        self.menuController = menu
        
        NSNotificationCenter.defaultCenter().addObserver(self, name: NSViewGlobalFrameDidChangeNotification, selector: #selector(self.windowSizeChanged))
        NSNotificationCenter.defaultCenter().addObserver(self, name: AppDelegate.ExportImageItemClickedNotification, selector: #selector(self.exportImageItemClicked(_:)))
        NSNotificationCenter.defaultCenter().addObserver(self, name: AppDelegate.ExportImageAdvancedItemClickedNotification, selector: #selector(self.exportImagesAdvancedItemClicked(_:)))
        NSNotificationCenter.defaultCenter().addObserver(self, name: AppDelegate.ZoomInItemClickedNotification, selector: #selector(self.zoomInItemClicked(_:)))
        NSNotificationCenter.defaultCenter().addObserver(self, name: AppDelegate.ZoomOutItemClickedNotification, selector: #selector(self.zoomOutItemClicked(_:)))
        NSNotificationCenter.defaultCenter().addObserver(self, name: AppDelegate.ResetZoomItemClickedNotification, selector: #selector(self.resetZoomItemClicked(_:)))
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.noiseSprite.position = self.glView.frame.size.center
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func timerMethod(sender:NSTimer) {
        self.time += 1.0 / 30.0
        self.glView.clearColor = SCVector4(gray: sin(self.time * 2.0) * 0.5 + 0.5)
        self.glView.setNeedsDisplayInRect(self.glView.frame)
        self.glView.container.update(1.0 / 30.0)
    }

    func render() {
        self.glView.display()
    }
    
    func windowSizeChanged(notification:NSNotification) {
        self.checkerSprite.contentSize = self.glView.frame.size
        self.noiseSprite.position = self.glView.frame.size.center
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        let sprite = GLSSprite(size: NSSize(square: 128.0), texture: "White Tile")
        let x = Int(arc4random() % UInt32(self.glView.frame.width))
        let y = Int(arc4random() % UInt32(self.glView.frame.height))
        sprite.position = NSPoint(x: x, y: y)
        sprite.shadeColor = SCVector3.randomRainbowColor()
        self.glView.addChild(sprite)
        
        let nt = Noise3DTexture2D()
        let gradient = ColorGradient1D.grayscaleGradient
        let ns = GLSPerlinNoiseSprite(size: NSSize(square: 128.0), texture: "White Tile", noise: nt, gradient: GLGradientTexture2D(gradient: gradient))
        ns.position = ns.contentSize.center
        ns.noiseSize = NSSize(square: 8.0)
        glViewport(0, 0, GLsizei(self.glView.frame.width), GLsizei(self.glView.frame.height))
        let ns2 = GLSPerlinNoiseSprite(size: NSSize(square: 128.0), texture: "White Tile", noise: nt, gradient: GLGradientTexture2D(gradient: gradient))
        ns2.position = ns.contentSize.center + NSPoint(x: ns2.contentSize.width)
        ns2.noiseSize = NSSize(square: 8.0)
        ns2.noiseType = .Fractal
        self.glView.addChild(ns)
        self.glView.addChild(ns2)
        ns.renderToTexture()
        ns2.renderToTexture()
    }
    
    func exportImageItemClicked(sender:NSNotification) {
        /*
        let image = self.noiseSprite.buffer.getImage()
        
        let panel = NSSavePanel()
        panel.canSelectHiddenExtension = true
        panel.allowedFileTypes = ["png"]
        switch panel.runModal() {
        case NSModalResponseOK:
            guard let url = panel.URL else {
                return
            }
            let cgImage = image.CGImageForProposedRect(nil, context: nil, hints: nil)!
            let bitmap = NSBitmapImageRep(CGImage: cgImage)
            bitmap.size = image.size
            let data = bitmap.representationUsingType(.NSPNGFileType, properties: [:])
            do {
                try data?.writeToURL(url, options: .DataWritingAtomic)
            } catch {
                print(error)
            }
        default:
            break
        }
        */
        let exportController = NSStoryboard(name: "Document", bundle: nil).instantiateControllerWithIdentifier("exportImageViewController") as! ExportImageViewController
        exportController.noiseSprite = self.noiseSprite
//        self.presentViewControllerAsModalWindow(exportController)
        self.presentViewControllerAsSheet(exportController)
    }
    
    func exportImagesAdvancedItemClicked(sender:NSNotification) {
        let exportController = NSStoryboard(name: "Document", bundle: nil).instantiateControllerWithIdentifier("exportImageAdvancedViewController") as! ExportImageAdvancedViewController
        exportController.noiseSprite = self.noiseSprite
//        self.presentViewControllerAsModalWindow(exportController)
        self.presentViewControllerAsSheet(exportController)
    }
    
    func zoomInItemClicked(notification:NSNotification?) {
        guard self.zoomLevelIndex < self.zoomLevels.count - 1 else {
            return
        }
        self.zoomLevelIndex += 1
        self.zoomChanged()
    }
    
    func zoomOutItemClicked(notification:NSNotification?) {
        guard self.zoomLevelIndex > 0 else {
            return
        }
        self.zoomLevelIndex -= 1
        self.zoomChanged()
    }
    
    func resetZoomItemClicked(notification:NSNotification?) {
        self.zoomLevelIndex = self.zoomLevels.count / 2
        self.zoomChanged()
    }
    
    private func zoomChanged() {
        self.noiseSprite.scale = self.zoomLevel
        self.checkerSprite.checkerSize = 32.0 * self.zoomLevel
        self.render()
    }
    
}

extension ViewController: MenuControllerDelegate {
    
    func widthChanged(width: CGFloat) {
        self.noiseSprite.contentSize.width = width
        self.renderToTexture()
        self.resetZoomItemClicked(nil)
    }
    
    func heightChanged(height: CGFloat) {
        self.noiseSprite.contentSize.height = height
        self.renderToTexture()
        self.resetZoomItemClicked(nil)
    }
    
    func noiseWidthChanged(noiseWidth: CGFloat) {
        self.noiseSprite.noiseSize.width = noiseWidth
        self.updateForTiled()
        self.renderToTexture()
    }
    
    func noiseHeightChanged(noiseHeight: CGFloat) {
        self.noiseSprite.noiseSize.height = noiseHeight
        self.updateForTiled()
        self.renderToTexture()
    }
    
    func xOffsetChanged(xOffset: CGFloat) {
        self.noiseSprite.offset.x = xOffset
        self.renderToTexture()
    }
    
    func yOffsetChanged(yOffset: CGFloat) {
        self.noiseSprite.offset.y = yOffset
        self.renderToTexture()
    }
    
    func zOffsetChanged(zOffset: CGFloat) {
        self.noiseSprite.offset.z = zOffset
        self.renderToTexture()
    }
    
    func noiseTypeChanged(noiseType: GLSPerlinNoiseSprite.NoiseType) {
        self.noiseSprite.noiseType = noiseType
        self.renderToTexture()
    }
    
    func seedChanged(seed: UInt32) {
        self.noiseSprite.noiseTexture = Noise3DTexture2D(seed: seed)
        self.renderToTexture()
    }
    
    func noiseDivisorChanged(noiseDivisor: CGFloat) {
        self.noiseSprite.noiseDivisor = noiseDivisor
        self.renderToTexture()
    }
    
    func isTiledChanged(isTiled: Bool) {
        self.isTiled = isTiled
        self.updateForTiled()
        self.renderToTexture()
    }
    
    func updateForTiled() {
        if self.isTiled {
            self.noiseSprite.xyPeriod = (Int(self.noiseSprite.noiseSize.width), Int(self.noiseSprite.noiseSize.height))
        } else {
            self.noiseSprite.xyPeriod = (256, 256)
        }
    }
    
    func noiseAngleChanged(noiseAngle: CGFloat) {
        self.noiseSprite.noiseAngle = noiseAngle
        self.renderToTexture()
    }
    
    func gradientChanged(gradient: ColorGradient1D) {
        self.noiseSprite.gradient = GLGradientTexture2D(gradient: gradient)
        self.renderToTexture()
    }
    
    func textureChanged(texture: CCTexture, withData data:NSData?) {
        self.noiseSprite.shadeTexture = texture
        self.renderToTexture()
    }
    
    func setState(state:NoiseState) {
        self.noiseSprite.contentSize    = state.contentSize
        self.noiseSprite.noiseSize      = state.noiseSize
        self.noiseSprite.offset         = state.offset
        self.noiseSprite.noiseTexture   = Noise3DTexture2D(seed: state.seed)
        self.noiseSprite.noiseDivisor   = state.noiseDivisor
        self.noiseSprite.noiseType      = state.noiseType
        self.noiseSprite.noiseAngle     = state.noiseAngle
        self.noiseSprite.gradient       = GLGradientTexture2D(gradient: state.gradient)
        
        self.updateForTiled()
    }
    
    func stateChanged(state: NoiseState) {
        self.setState(state)
        self.renderToTexture()
        self.resetZoomItemClicked(nil)
    }
    
    class func setViewportTo(size:NSSize) {
        glViewport(0, 0, GLsizei(size.width), GLsizei(size.height))
        GLSNode.universalProjection = SCMatrix4(right: size.width, top: size.height)
    }
    
    func renderToTexture() {
        GLSFrameBuffer.globalContext.makeCurrentContext()
        ViewController.setViewportTo(self.noiseSprite.contentSize)
        self.noiseSprite.renderToTexture()
        self.glView.openGLContext?.makeCurrentContext()
        ViewController.setViewportTo(self.glView.bounds.size)
        self.render()
    }
    
}