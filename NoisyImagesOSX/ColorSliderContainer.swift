//
//  ColorSliderContainer.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 4/9/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import CoronaConvenience
import CoronaStructures
import CoronaGL

class ColorSliderContainer: NSObject {
    
    // MARK: - Properties
    
    let redSlider:ColorTrackSlider
    let greenSlider:ColorTrackSlider
    let blueSlider:ColorTrackSlider
    let alphaSlider:ColorTrackSlider
    var color:NSColor {
        get { return NSColor(red: self.redSlider.CGFloatValue, green: self.greenSlider.CGFloatValue, blue: self.blueSlider.CGFloatValue, alpha: self.alphaSlider.CGFloatValue) }
        set {
            let comps = newValue.getComponents()
            self.redSlider.CGFloatValue     = comps[0]
            self.greenSlider.CGFloatValue   = comps[1]
            self.blueSlider.CGFloatValue    = comps[2]
            self.alphaSlider.CGFloatValue   = comps[3]
        }
    }
    
    fileprivate var animationDuration:TimeInterval = 0.33333
    fileprivate var timer:Timer? = nil
    fileprivate var time:TimeInterval = 0.0
    fileprivate var startColor = SCVector4.blackColor
    fileprivate var finalColor = SCVector4.whiteColor
    
    // MARK: - Setup
    
    init(red:ColorTrackSlider, green:ColorTrackSlider, blue:ColorTrackSlider, alpha:ColorTrackSlider) {
        self.redSlider      = red
        self.greenSlider    = green
        self.blueSlider     = blue
        self.alphaSlider    = alpha
    }
    
    // MARK: - Logic
    
    func setColor(_ color:NSColor, animated:Bool) {
        if animated {
            self.timer?.invalidate()
            
            self.startColor = self.color.getVector4()
            self.finalColor = color.getVector4()
            self.time       = 0.0
            self.timer      = Timer.scheduledTimer(timeInterval: 1.0 / 60.0, target: self, selector: #selector(timerMethod), userInfo: nil, repeats: true)
        } else {
            self.color = color
        }
    }
    
    @objc func timerMethod(_ timer:Timer) {
        self.time += 1.0 / 60.0
        if self.time >= self.animationDuration {
            timer.invalidate()
            self.timer = nil
            self.color = NSColor(vector4: self.finalColor)
        } else {
            let percent = self.time / self.animationDuration
            let color = linearlyInterpolate(smoothstep(CGFloat(percent)), left: self.startColor, right: self.finalColor)
            self.color = NSColor(vector4: color)
        }
    }
    
}
