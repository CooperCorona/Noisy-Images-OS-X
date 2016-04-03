//
//  OmniGLView2d.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 3/29/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import AppKit
import GLKit
import OmniSwiftX
import OpenGL

public class OmniGLView2d: NSOpenGLView {
    
    public var clearColor = SCVector4.blackColor
    public private(set) var container = GLSNode(position: NSPoint.zero, size: NSSize.zero)
    private(set) lazy var framebufferStack:GLSFramebufferStack = GLSFramebufferStack(initialBuffer: self)
    
    public static var globalContext:NSOpenGLContext? = nil
    // MARK: - Setup
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let attrs: [NSOpenGLPixelFormatAttribute] = [
            UInt32(NSOpenGLPFAAccelerated),            //  Use accelerated renderers
            UInt32(NSOpenGLPFAColorSize), UInt32(32),  //  Use 32-bit color
            UInt32(NSOpenGLPFAOpenGLProfile),          //  Use version's >= 3.2 core
            UInt32(NSOpenGLProfileVersion3_2Core),
            UInt32(0)                                  //  C API's expect to end with 0
        ]
        
        //  Create a pixel format using our attributes
        guard let pixelFormat = NSOpenGLPixelFormat(attributes: attrs) else {
            Swift.print("pixelFormat could not be constructed")
            return
        }
        self.pixelFormat = pixelFormat
        
        //  Create a context with our pixel format (we have no other context, so nil)
        guard let context = NSOpenGLContext(format: pixelFormat, shareContext: nil) else {
            Swift.print("context could not be constructed")
            return
        }
        self.openGLContext = context
        self.openGLContext?.makeCurrentContext()
        context.view = self
        
        OmniGLView2d.globalContext = NSOpenGLContext(format: pixelFormat, shareContext: context)
//        self.container.framebufferStack = self.framebufferStack
    }
    
    private static var onceToken:dispatch_once_t = 0
    public class func setupOpenGL() {
        dispatch_once(&OmniGLView2d.onceToken) {
            ShaderHelper.sharedInstance.loadProgramsFromBundle()
            CCTextureOrganizer.sharedInstance.files = ["Atlases"]
            CCTextureOrganizer.sharedInstance.loadTextures()
        }
    }
    
    public override func prepareOpenGL() {
        super.prepareOpenGL()
    }
    
    public override func reshape() {
        super.reshape()
        glViewport(0, 0, GLsizei(self.frame.width), GLsizei(self.frame.height))
        GLSNode.universalProjection = SCMatrix4(right: self.frame.width, top: self.frame.height)
    }
    
    // MARK: - Logic
    
    public override func drawRect(dirtyRect: NSRect) {
        self.openGLContext?.makeCurrentContext()
        self.clearColor.bindGLClearColor()
        self.container.render()
        glFlush()
        self.openGLContext?.flushBuffer()
    }
    
    // MARK: - Children
    
    public func addChild(child:GLSNode) {
        self.container.addChild(child)
        self.setNeedsDisplayInRect(self.frame)
    }
    
    public func removeChild(child:GLSNode) -> GLSNode? {
        let node = self.container.removeChild(child)
        self.setNeedsDisplayInRect(self.frame)
        return node
    }
    
}
