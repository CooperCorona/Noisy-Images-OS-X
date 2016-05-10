//
//  GradientContainer.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 5/1/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import OmniSwiftX

protocol GradientContainerDelegate: class {
    func gradientChanged(gradientContainer:GradientContainer)
}

class GradientContainer: NSObject {

    var gradient:ColorGradient1D = ColorGradient1D.grayscaleGradient {
        didSet {
            self.delegate?.gradientChanged(self)
        }
    }
    var overlay = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0) {
        didSet {
            self.delegate?.gradientChanged(self)
        }
    }
    
    var uuid = ""
    
    weak var delegate:GradientContainerDelegate? = nil
    
    override init() {
        
    }
    
    init(gradient:Gradient) {
        self.gradient = gradient.gradient
        self.uuid = gradient.universalId ?? ""
    }
    
    func toGradient(gradient:Gradient) {
        gradient.gradient       = self.gradient
        gradient.universalId    = self.uuid
        gradient.overlay        = self.overlay.getString()
    }
    
    func generateUUID() {
        self.uuid = NSUUID().UUIDString
    }
    
}