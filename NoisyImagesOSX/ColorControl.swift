//
//  ColorControl.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 5/1/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import CoronaConvenience
import CoronaStructures
import CoronaGL

class ColorControl: NSControl {

    var colors = [
        NSColor.red,
        NSColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0),
        NSColor.yellow,
        NSColor.green,
        NSColor.cyan,
        NSColor.blue,
        NSColor(red: 0.4, green: 0.0, blue: 0.8, alpha: 1.0),
        NSColor(red: 0.4, green: 0.2, blue: 0.0, alpha: 1.0),
        NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
        NSColor(red: 1.0 / 3.0, green: 1.0 / 3.0, blue: 1.0 / 3.0, alpha: 1.0),
        NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0),
        NSColor(red: 2.0 / 3.0, green: 2.0 / 3.0, blue: 2.0 / 3.0, alpha: 1.0),
        NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
    ]
    
    override func draw(_ dirtyRect: NSRect) {
        
        guard let context = NSGraphicsContext.current() else {
            return
        }
        context.saveGraphicsState()
        
        let w = self.bounds.width / CGFloat(self.colors.count)
        for (i, color) in self.colors.enumerated() {
            color.setFill()
            let x = CGFloat(i) / CGFloat(self.colors.count) * self.bounds.width
            context.cgContext.fill(NSRect(x: x, y: 0.0, width: w, height: self.bounds.height))
        }
        context.restoreGraphicsState()
    }
    
    func handleClick(_ clickLocation:NSPoint) -> NSColor? {
        guard self.frame.contains(clickLocation) else {
            return nil
        }
        return self.colors.objectAtIndex(Int((clickLocation.x - self.frame.minX) / self.frame.width * CGFloat(self.colors.count)))
    }
}
