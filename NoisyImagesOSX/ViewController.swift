//
//  ViewController.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 3/26/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import OmniSwiftX

class ViewController: NSViewController {

    @IBOutlet weak var glView: OmniGLView2d!
    lazy var timer:NSTimer = NSTimer(timeInterval: 1.0 / 30.0, target: self, selector: #selector(timerMethod), userInfo: nil, repeats: true)
    var time:CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        OmniGLView2d.setupOpenGL()
        glView.clearColor = SCVector4.darkBlueColor
        
        NSRunLoop.mainRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func timerMethod(sender:NSTimer) {
        self.time += 1.0 / 30.0
        self.glView.clearColor = SCVector4(gray: sin(self.time * 2.0) * 0.5 + 0.5)
        self.glView.setNeedsDisplayInRect(self.glView.frame)
    }

    @IBAction func buttonPressed(sender: AnyObject) {
        self.glView.framebufferStack.internalContext?.makeCurrentContext()
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
        glFinish()
        /*let im = ns.buffer.getImage()
        let imV = NSImageView(frame: NSRect(size: ns.contentSize))
        imV.image = im
        imV.frame.origin = NSPoint(x: 0.0, y: self.view.frame.size.height - ns.contentSize.height)
        self.view.addSubview(imV)*/
        self.glView.openGLContext?.makeCurrentContext()
    }

}

