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
    
    func thumbSlider(_ slider:NSMultiSlider, selectedThumbAt thumbIndex:Int)
    func thumbSlider(_ slider:NSMultiSlider, movedThumbAt thumbIndex:Int, to value:CGFloat)
    func thumbSlider(_ slider:NSMultiSlider, stoppedMovingThumbAt thumbIndex:Int)
    func colorOfThumbAtIndex(_ index:Int) -> NSColor
    
}

@IBDesignable
open class NSMultiSlider: NSControl {

    public enum OutlineStyle {
        case shadow
        case outline(NSColor, NSColor)
    }
    
    // MARK: - Properties
    
    ///The values of the thumbs.
    fileprivate(set) var thumbs:[CGFloat]       = [0.5]
    fileprivate(set) var thumbColors:[NSColor]  = [NSColor.white]
    
    @IBInspectable open var thumbCount = 1 {
        didSet {
            if self.thumbCount < 1 {
                self.thumbCount = 1
            }
            while self.thumbs.count < self.thumbCount {
                self.thumbColors.append(self.delegate?.colorOfThumbAtIndex(self.thumbs.count) ?? NSColor.white)
                self.thumbs.append(0.0)
            }
            while self.thumbs.count > self.thumbCount {
                self.thumbs.removeLast()
                self.thumbColors.removeLast()
            }
        }
    }
    @IBInspectable open var vertical = false
    @IBInspectable open var minValue:CGFloat = 0.0
    @IBInspectable open var maxValue:CGFloat = 1.0
    open var length:CGFloat { return self.maxValue - self.minValue }
    
    @IBInspectable open var trackColor:NSColor = NSColor.gray
    
    open var outlineStyle:OutlineStyle = .shadow
    
    weak var delegate:NSMultiSliderDelegate? = nil
    
    fileprivate var movingIndex:Int? = nil
    fileprivate var lastMouseLocation = NSPoint.zero
    fileprivate(set) var selectedIndex:Int? = nil
    
    // MARK: - Setup
    
    public override init(frame:NSRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Logic
    
    func addThumbAt(_ value:CGFloat) {
        self.thumbCount += 1
        self.thumbs[self.thumbs.count - 1] = value
    }
    
    func removeThumbAtIndex(_ index:Int) {
        guard index >= 0 && index < self.thumbs.count else {
            return
        }
        self.thumbs.remove(at: index)
        self.thumbColors.remove(at: index)
        self.thumbCount -= 1
        self.colorsNeedDisplay()
        self.setNeedsDisplay()
    }
    
    func setThumb(_ thumb:CGFloat, atIndex index:Int) {
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
    
    func colorsNeedDisplay<T: Sequence>(_ colorIndices:T) where T.Iterator.Element == Int {
        for i in colorIndices {
            self.thumbColors[i] = self.delegate?.colorOfThumbAtIndex(i) ?? NSColor.white
        }
        self.setNeedsDisplay()
    }
    
    func convertWindowCoordinatesToSliderValue(_ windowCoords:NSPoint) -> CGFloat {
        return (self.getLocation(windowCoords).x - self.bounds.height / 2.0) / (self.bounds.width - self.bounds.height) * self.length
    }
    
    fileprivate func getLocation(_ location:NSPoint) -> NSPoint {
        var loc = location
        var superView:NSView? = self
        while let sView = superView {
            loc -= sView.frame.origin
            superView = sView.superview
        }
        return loc
    }
    
    fileprivate func locationOfThumb(_ thumb:CGFloat) -> NSPoint {
        let percent = (thumb - self.minValue) / (self.maxValue - self.minValue)
        return linearlyInterpolate(percent, left: self.frame.leftMiddle + NSPoint(x: self.bounds.height / 2.0), right: self.frame.rightMiddle - NSPoint(x: self.bounds.height / 2.0))
    }
    
    fileprivate func thumbIndexAtLocation(_ location:NSPoint) -> Int? {
        let r = self.bounds.height / 2.0
        //Iterate backwards so we check the topmost thumbs first.
        for (i, thumb) in self.thumbs.enumerated().reversed() {
            let loc = self.locationOfThumb(thumb)
            if loc.distanceFrom(location) <= r {
                return i
            }
        }
        return nil
    }
    
    open override func mouseDown(with theEvent: NSEvent) {
        super.mouseDown(with: theEvent)
        let location = theEvent.locationInWindow
        self.lastMouseLocation = location
        if let index = self.thumbIndexAtLocation(location) {
            self.movingIndex = index
            self.selectedIndex = index
            self.delegate?.thumbSlider(self, selectedThumbAt: index)
            switch self.outlineStyle {
            case .outline:
                self.setNeedsDisplay()
            default:
                break
            }
        }
        
    }
    
    open override func mouseDragged(with theEvent: NSEvent) {
        super.mouseDragged(with: theEvent)
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
    
    open override func mouseExited(with theEvent: NSEvent) {
        super.mouseExited(with: theEvent)
    }
    
    open override func mouseUp(with theEvent: NSEvent) {
        super.mouseUp(with: theEvent)
        guard let movingIndex = self.movingIndex else {
            return
        }
        self.delegate?.thumbSlider(self, stoppedMovingThumbAt: movingIndex)
        self.movingIndex = nil
    }
    
    open override func draw(_ dirtyRect: NSRect) {

        func percent(_ p:CGFloat) -> CGFloat {
            return (p - self.minValue) / (self.maxValue - self.minValue)
        }

        guard let context = NSGraphicsContext.current() else {
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
        for (i, value) in self.thumbs.enumerated() {
            let percent = (value - self.minValue) / (self.maxValue - self.minValue)
            let thumbPoint = CGPoint(x: percent * (self.frame.size.width - 2.0 * r) + r, y: self.bounds.height / 2.0) - r
            self.thumbColors[i].setFill()
            
            switch self.outlineStyle {
            case .shadow:
                context.cgContext.setShadow(offset: CGSize(width: 0.0, height: 0.0), blur: 1.0, color: NSColor(white: 0.0, alpha: 0.75).cgColor)
                (context.cgContext).fillEllipse(in: NSRect(origin: thumbPoint, size: NSSize(square: 2.0 * r - 2.0)))
            case let .outline(color, highlightColor):
                (context.cgContext).fillEllipse(in: NSRect(origin: thumbPoint, size: NSSize(square: 2.0 * r - 2.0)))
                if i == self.selectedIndex {
                    highlightColor.setStroke()
                } else {
                    color.setStroke()
                }
                (context.cgContext).strokeEllipse(in: NSRect(origin: thumbPoint, size: NSSize(square: 2.0 * r - 2.0)))
            }
            
        }
        
        context.restoreGraphicsState()
    }

}
