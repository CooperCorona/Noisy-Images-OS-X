//
//  ColorGradientView.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 4/7/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import CoronaConvenience
import CoronaStructures
import CoronaGL

class ColorGradientView: NSView {

    var gradient:ColorGradient1D? = ColorGradient1D.rainbowGradient {
        didSet {
            self.setNeedsDisplayInRect(self.bounds)
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        if let context = NSGraphicsContext.currentContext(), gradient = self.gradient {
            context.saveGraphicsState()
            
            let w = dirtyRect.width / 256.0
            CGContextScaleCTM(context.CGContext, w, 1.0)
            for iii in 0..<gradient.size {
                let percent = CGFloat(iii) / CGFloat(gradient.size - 1)
                let vector = gradient[percent]
                NSColor(red: vector.r, green: vector.g, blue: vector.b, alpha: vector.a).setFill()
                //Instead of calculating the width of each bar of color, we scale the drawings.
                //Instead of using 1 as the width, we use 2 to prevent weird errors from showing up.
                CGContextFillRect(context.CGContext, CGRect(x: CGFloat(iii), y: 0.0, width: 2.0, height: dirtyRect.height))
            }
 
            /*
             *  Doesn't work because it ignores smoothing.
             *
            let locations = gradient.anchors.map() { $0.1 }
            let colors = gradient.anchors.map() { NSColor(red: $0.0.r, green: $0.0.g, blue: $0.0.b, alpha: $0.0.a) }
            let gradient = NSGradient(colors: colors, atLocations: locations, colorSpace: NSColorSpace.deviceRGBColorSpace())
            gradient?.drawInRect(dirtyRect, angle: 0.0)
             */
            context.restoreGraphicsState()
        }
    }
    
}