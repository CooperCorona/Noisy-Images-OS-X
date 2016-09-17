//
//  ColorTrackSlider.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 4/8/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import CoronaConvenience

extension NSSlider {
    public var percent:CGFloat {
        return CGFloat((self.doubleValue - self.minValue) / (self.maxValue - self.minValue))
    }
}

@IBDesignable
class ColorTrackSlider: NSSlider {
    
    @IBInspectable var minTrackTintColor:NSColor    = NSColor.cyan
    @IBInspectable var maxTrackTintColor:NSColor    = NSColor.gray
    @IBInspectable var thumbTrackTintColor:NSColor  = NSColor.white
    
    var mouseDownExecutedHandler:((ColorTrackSlider) -> Void)? = nil
    
    override func draw(_ dirtyRect: NSRect) {
//        super.drawRect(dirtyRect)
        
        guard let context = NSGraphicsContext.current() else {
            return
        }
        context.saveGraphicsState()
        
        let trackFactor:CGFloat = 4.0 / 32.0
        
        let r:CGFloat = 16.0
        let thumbPoint:NSPoint
        
        let vertical:Bool
        if #available(OSX 10.12, *) {
            vertical = self.isVertical
        } else if #available(OSX 10.11, *) {
            vertical = (self.value(forKey: "vertical")! as! Int) == 1
        } else {
            vertical = false
        }
        if !vertical {
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
        context.cgContext.setShadow(offset: CGSize(width: 0.0, height: 0.0), blur: 1.0, color: NSColor(white: 0.0, alpha: 0.75).cgColor)
        (context.cgContext).fillEllipse(in: NSRect(origin: thumbPoint - r / 2.0, size: NSSize(square: r)))
        
        context.restoreGraphicsState()
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        super.mouseDown(with: theEvent)
        self.mouseDownExecutedHandler?(self)
    }
}
