//
//  NSMultiSlider.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 4/10/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import CoronaConvenience
import CoronaStructures
import CoronaGL

protocol NSMultiSliderDelegate: class {
    
    func thumbSlider(slider:NSMultiSlider, selectedThumbAt thumbIndex:Int)
    func thumbSlider(slider:NSMultiSlider, movedThumbAt thumbIndex:Int, to value:CGFloat)
    func thumbSlider(slider:NSMultiSlider, stoppedMovingThumbAt thumbIndex:Int)
    func colorOfThumbAtIndex(index:Int) -> NSColor
    
}

@IBDesignable
public class NSMultiSlider: NSControl {

    public enum OutlineStyle {
        case Shadow
        case Outline(NSColor, NSColor)
    }
    
    // MARK: - Properties
    
    ///The values of the thumbs.
    private(set) var thumbs:[CGFloat]       = [0.5]
    private(set) var thumbColors:[NSColor]  = [NSColor.whiteColor()]
    
    @IBInspectable public var thumbCount = 1 {
        didSet {
            if self.thumbCount < 1 {
                self.thumbCount = 1
            }
            while self.thumbs.count < self.thumbCount {
                self.thumbColors.append(self.delegate?.colorOfThumbAtIndex(self.thumbs.count) ?? NSColor.whiteColor())
                self.thumbs.append(0.0)
            }
            while self.thumbs.count > self.thumbCount {
                self.thumbs.removeLast()
                self.thumbColors.removeLast()
            }
        }
    }
    @IBInspectable public var vertical = false
    @IBInspectable public var minValue:CGFloat = 0.0
    @IBInspectable public var maxValue:CGFloat = 1.0
    public var length:CGFloat { return self.maxValue - self.minValue }
    
    @IBInspectable public var trackColor:NSColor = NSColor.grayColor()
    
    public var outlineStyle:OutlineStyle = .Shadow
    
    weak var delegate:NSMultiSliderDelegate? = nil
    
    private var movingIndex:Int? = nil
    private var lastMouseLocation = NSPoint.zero
    private(set) var selectedIndex:Int? = nil
    
    // MARK: - Setup
    
    public override init(frame:NSRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Logic
    
    func addThumbAt(value:CGFloat) {
        self.thumbCount += 1
        self.thumbs[self.thumbs.count - 1] = value
    }
    
    func removeThumbAtIndex(index:Int) {
        guard index >= 0 && index < self.thumbs.count else {
            return
        }
        self.thumbs.removeAtIndex(index)
        self.thumbColors.removeAtIndex(index)
        self.thumbCount -= 1
        self.colorsNeedDisplay()
        self.setNeedsDisplay()
    }
    
    func setThumb(thumb:CGFloat, atIndex index:Int) {
        guard 0 <= index && index < self.thumbs.count else {
            return
        }
        self.thumbs[index] = thumb
    }
    
    subscript(index:Int) -> CGFloat {
        get {
            return self.thumbs[index]
        }
        set {
            self.thumbs[index] = newValue
        }
    }
    
    func colorsNeedDisplay() {
        self.colorsNeedDisplay(0..<self.thumbCount)
    }
    
    func colorsNeedDisplay<T: SequenceType where T.Generator.Element == Int>(colorIndices:T) {
        for i in colorIndices {
            self.thumbColors[i] = self.delegate?.colorOfThumbAtIndex(i) ?? NSColor.whiteColor()
        }
        self.setNeedsDisplay()
    }
    
    func convertWindowCoordinatesToSliderValue(windowCoords:NSPoint) -> CGFloat {
        return (self.getLocation(windowCoords).x - self.bounds.height / 2.0) / (self.bounds.width - self.bounds.height) * self.length
    }
    
    private func getLocation(location:NSPoint) -> NSPoint {
        var loc = location
        var superView:NSView? = self
        while let sView = superView {
            loc -= sView.frame.origin
            superView = sView.superview
        }
        return loc
    }
    
    private func locationOfThumb(thumb:CGFloat) -> NSPoint {
        let percent = (thumb - self.minValue) / (self.maxValue - self.minValue)
        return linearlyInterpolate(percent, left: self.frame.leftMiddle + NSPoint(x: self.bounds.height / 2.0), right: self.frame.rightMiddle - NSPoint(x: self.bounds.height / 2.0))
    }
    
    private func thumbIndexAtLocation(location:NSPoint) -> Int? {
        let r = self.bounds.height / 2.0
        //Iterate backwards so we check the topmost thumbs first.
        for (i, thumb) in self.thumbs.enumerate().reverse() {
            let loc = self.locationOfThumb(thumb)
            if loc.distanceFrom(location) <= r {
                return i
            }
        }
        return nil
    }
    
    public override func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        let location = theEvent.locationInWindow
        self.lastMouseLocation = location
        if let index = self.thumbIndexAtLocation(location) {
            self.movingIndex = index
            self.selectedIndex = index
            self.delegate?.thumbSlider(self, selectedThumbAt: index)
            switch self.outlineStyle {
            case .Outline:
                self.setNeedsDisplay()
            default:
                break
            }
        }
        
    }
    
    public override func mouseDragged(theEvent: NSEvent) {
        super.mouseDragged(theEvent)
        guard let movingIndex = self.movingIndex else {
            return
        }
        let location = theEvent.locationInWindow
        let offset = (location.x - self.lastMouseLocation.x) / (self.bounds.width - self.bounds.height) * self.length
        self.thumbs[movingIndex] += offset
        self.thumbs[movingIndex] = min(max(self.thumbs[movingIndex], self.minValue), self.maxValue)
        self.setNeedsDisplay()
        self.lastMouseLocation = location
        
        self.delegate?.thumbSlider(self, movedThumbAt: movingIndex, to: self.thumbs[movingIndex])
    }
    
    public override func mouseExited(theEvent: NSEvent) {
        super.mouseExited(theEvent)
    }
    
    public override func mouseUp(theEvent: NSEvent) {
        super.mouseUp(theEvent)
        guard let movingIndex = self.movingIndex else {
            return
        }
        self.delegate?.thumbSlider(self, stoppedMovingThumbAt: movingIndex)
        self.movingIndex = nil
    }
    
    public override func drawRect(dirtyRect: NSRect) {

        func percent(p:CGFloat) -> CGFloat {
            return (p - self.minValue) / (self.maxValue - self.minValue)
        }

        guard let context = NSGraphicsContext.currentContext() else {
            return
        }
        context.saveGraphicsState()
        
        let trackFactor:CGFloat = 6.0 / 32.0
        
        //Horizontal
        let h = self.bounds.height * trackFactor
        let y = self.bounds.height / 2.0 - h / 2.0
        let radius:CGFloat = h / 4.0
        let minPath = NSBezierPath(roundedRect: NSRect(x: radius, y: y, width: self.frame.width - radius * 2, height: h), xRadius: radius, yRadius: radius)
        self.trackColor.setFill()
        minPath.fill()
        
        let r = self.bounds.height / 2.0
        for (i, value) in self.thumbs.enumerate() {
            let percent = (value - self.minValue) / (self.maxValue - self.minValue)
            let thumbPoint = CGPoint(x: percent * (self.frame.size.width - 2.0 * r) + r, y: self.bounds.height / 2.0)
            self.thumbColors[i].setFill()
            
            switch self.outlineStyle {
            case .Shadow:
                CGContextSetShadowWithColor(context.CGContext, CGSize(width: 0.0, height: 0.0), 1.0, NSColor(white: 0.0, alpha: 0.75).CGColor)
                CGContextFillEllipseInRect(context.CGContext, NSRect(center: thumbPoint, size: NSSize(square: 2.0 * r - 2.0)))
            case let .Outline(color, highlightColor):
                CGContextFillEllipseInRect(context.CGContext, NSRect(center: thumbPoint, size: NSSize(square: 2.0 * r - 2.0)))
                if i == self.selectedIndex {
                    highlightColor.setStroke()
                } else {
                    color.setStroke()
                }
                CGContextStrokeEllipseInRect(context.CGContext, NSRect(center: thumbPoint, size: NSSize(square: 2.0 * r - 2.0)))
            }
            
        }
        
        context.restoreGraphicsState()
    }

}
