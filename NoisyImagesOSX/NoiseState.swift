//
//  NoiseState.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 4/3/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Foundation
import CoronaConvenience
import CoronaStructures
import CoronaGL

struct NoiseState {
    
    var width:CGFloat           = 256.0
    var height:CGFloat          = 256.0
    var noiseWidth:CGFloat      = 4.0
    var noiseHeight:CGFloat     = 4.0
    var xOffset:CGFloat         = 0.0
    var yOffset:CGFloat         = 0.0
    var zOffset:CGFloat         = 0.0
    var seed:UInt32             = arc4random()
    var noiseDivisor:CGFloat    = 0.7
    var noiseType               = GLSPerlinNoiseSprite.NoiseType.Default
    var isTiled                 = false
    var noiseAngle:CGFloat      = 0.0
    var gradient:ColorGradient1D = ColorGradient1D.grayscaleGradient
    
    var contentSize:NSSize {
        get { return NSSize(width: self.width, height: self.height) }
        set {
            self.width = newValue.width
            self.height = newValue.height
        }
    }
    var noiseSize:NSSize {
        get { return NSSize(width: self.noiseWidth, height: self.noiseHeight) }
        set {
            self.noiseWidth = newValue.width
            self.noiseHeight = newValue.height
        }
    }
    var offset:SCVector3 {
        get { return SCVector3(x: self.xOffset, y: self.yOffset, z: self.zOffset) }
        set {
            self.xOffset = newValue.x
            self.yOffset = newValue.y
            self.zOffset = newValue.z
        }
    }
    
}