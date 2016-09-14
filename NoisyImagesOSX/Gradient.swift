//
//  Gradient.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 4/10/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import AppKit
import CoreData
import CoronaConvenience
import CoronaStructures
import CoronaGL

struct ColorAnchor {
    var color:NSColor
    var weight:CGFloat
    
    init(color:NSColor, weight:CGFloat) {
        self.color  = color
        self.weight = weight
    }
    
    init(string:String) {
        let comps = string.componentsSeparatedByString(", ")
        self.color = NSColor(red: comps[0].getCGFloatValue(), green: comps[1].getCGFloatValue(), blue: comps[2].getCGFloatValue(), alpha: comps[3].getCGFloatValue())
        self.weight = comps[4].getCGFloatValue()
    }
    
    func getString() -> String {
        return "\(self.color.getString()), \(self.weight)"
    }
    
    func getTuple() -> (color:SCVector4, weight:CGFloat) {
        return (color: self.color.getVector4(), weight: self.weight)
    }
}

class Gradient: NSManagedObject {
    
    static let colorCount = 16
    
    subscript(index:Int) -> ColorAnchor? {
        get {
            switch index {
            case 0:
                if let c = self.color1 {
                    return ColorAnchor(string: c)
                }
            case 1:
                if let c = self.color2 {
                    return ColorAnchor(string: c)
                }
            case 2:
                if let c = self.color3 {
                    return ColorAnchor(string: c)
                }
            case 3:
                if let c = self.color4 {
                    return ColorAnchor(string: c)
                }
            case 4:
                if let c = self.color5 {
                    return ColorAnchor(string: c)
                }
            case 5:
                if let c = self.color6 {
                    return ColorAnchor(string: c)
                }
            case 6:
                if let c = self.color7 {
                    return ColorAnchor(string: c)
                }
            case 7:
                if let c = self.color8 {
                    return ColorAnchor(string: c)
                }
            case 8:
                if let c = self.color9 {
                    return ColorAnchor(string: c)
                }
            case 9:
                if let c = self.color10 {
                    return ColorAnchor(string: c)
                }
            case 10:
                if let c = self.color11 {
                    return ColorAnchor(string: c)
                }
            case 11:
                if let c = self.color12 {
                    return ColorAnchor(string: c)
                }
            case 12:
                if let c = self.color13 {
                    return ColorAnchor(string: c)
                }
            case 13:
                if let c = self.color14 {
                    return ColorAnchor(string: c)
                }
            case 14:
                if let c = self.color15 {
                    return ColorAnchor(string: c)
                }
            case 15:
                if let c = self.color16 {
                    return ColorAnchor(string: c)
                }
            default:
                break
            }
            return nil
        }
        set {
            switch index {
            case 0:
                self.color1 = newValue?.getString()
            case 1:
                self.color2 = newValue?.getString()
            case 2:
                self.color3 = newValue?.getString()
            case 3:
                self.color4 = newValue?.getString()
            case 4:
                self.color5 = newValue?.getString()
            case 5:
                self.color6 = newValue?.getString()
            case 6:
                self.color7 = newValue?.getString()
            case 7:
                self.color8 = newValue?.getString()
            case 8:
                self.color9 = newValue?.getString()
            case 9:
                self.color10 = newValue?.getString()
            case 10:
                self.color11 = newValue?.getString()
            case 11:
                self.color12 = newValue?.getString()
            case 12:
                self.color13 = newValue?.getString()
            case 13:
                self.color14 = newValue?.getString()
            case 14:
                self.color15 = newValue?.getString()
            case 15:
                self.color16 = newValue?.getString()
            default:
                break
            }
        }
    }
    
    var colors:[ColorAnchor] {
        get {
            var colors:[ColorAnchor] = []
            for i in 0..<Gradient.colorCount {
                guard let color = self[i] else {
                    return colors
                }
                colors.append(color)
            }
            return colors
        }
        set {
            for (i, anchor) in newValue.enumerate() {
                self[i] = anchor
            }
            for i in newValue.count..<Gradient.colorCount {
                self[i] = nil
            }
        }
    }
    
    var overlayColor:NSColor? {
        get {
            guard let overlay = self.overlay else {
                return nil
            }
            return NSColor(string: overlay)
        }
        set { self.overlay = newValue?.getString() }
    }
    
    var gradient:ColorGradient1D {
        get {
            return ColorGradient1D(colorsAndWeights: self.colors.map() { (color: $0.color.getVector4(), weight: $0.weight) }, smoothed: self.smoothed?.boolValue ?? false)
        }
        set {
            self.colors = newValue.anchors.map() { ColorAnchor(color: NSColor(vector4: $0.0), weight: $0.1) }
            self.smoothed = NSNumber(bool: newValue.isSmoothed)
        }
    }

    func generateUUID() {
        self.universalId = NSUUID().UUIDString
    }
}
