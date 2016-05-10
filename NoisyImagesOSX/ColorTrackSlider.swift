//
//  ColorTrackSlider.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 4/8/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa

extension NSSlider {
    public var percent:CGFloat {
        return CGFloat((self.doubleValue - self.minValue) / (self.maxValue - self.minValue))
    }
}

@IBDesignable
class ColorTrackSlider: NSSlider {
    
    @IBInspectable var minTrackTintColor:NSColor    = NSColor.cyanColor()
    @IBInspectable var maxTrackTintColor:NSColor    = NSColor.grayColor()
    @IBInspectable var thumbTrackTintColor:NSColor  = NSColor.whiteColor()
    
    override func drawRect(dirtyRect: NSRect) {
//        super.drawRect(dirtyRect)
        
        guard let context = NSGraphicsContext.currentContext() else {
            return
        }
        context.saveGraphicsState()
        
        let trackFactor:CGFloat = 4.0 / 32.0
        
        let r:CGFloat = 16.0
        let thumbPoint:NSPoint
        if self.vertical == 0 {
            //Horizontal
            let h = self.bounds.height * trackFactor
            let x = self.percent * self.bounds.width
            let y = self.bounds.height / 2.0 - h / 2.0
            let radius:CGFloat = h / 4.0
            let minPath = NSBezierPath(roundedRect: NSRect(x: radius, y: y, width: x - h, height: h), xRadius: radius, yRadius: radius)
            let maxPath = NSBezierPath(roundedRect: NSRect(x: x, y: y, width: self.bounds.width - x, height: h), xRadius: radius, yRadius: radius)
            self.minTrackTintColor.setFill()
            minPath.fill()
            self.maxTrackTintColor.setFill()
            maxPath.fill()
            
            let realLength = self.bounds.width - r
            thumbPoint = CGPoint(x: r / 2.0 + realLength * self.percent, y: self.bounds.height / 2.0)
        } else {
            //Horizontal
            let w = self.bounds.width * trackFactor
            let y = self.percent * self.bounds.height
            let x = self.bounds.width / 2.0 - w / 2.0
            let radius:CGFloat = w / 4.0
            let minPath = NSBezierPath(roundedRect: NSRect(x: x, y: radius, width: w, height: y - w), xRadius: radius, yRadius: radius)
            let maxPath = NSBezierPath(roundedRect: NSRect(x: x, y: y, width: w, height: self.bounds.height - w), xRadius: radius, yRadius: radius)
            self.minTrackTintColor.setFill()
            minPath.fill()
            self.maxTrackTintColor.setFill()
            maxPath.fill()
            
            thumbPoint = CGPoint(x: self.bounds.width / 2.0, y: y)
        }
        
        self.thumbTrackTintColor.setFill()
        CGContextSetShadowWithColor(context.CGContext, CGSize(width: 0.0, height: 0.0), 1.0, NSColor(white: 0.0, alpha: 0.75).CGColor)
        CGContextFillEllipseInRect(context.CGContext, NSRect(center: thumbPoint, size: NSSize(square: r)))
        
        context.restoreGraphicsState()
    }
    
}
