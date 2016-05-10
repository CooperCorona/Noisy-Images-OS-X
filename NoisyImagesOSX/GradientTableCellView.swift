//
//  GradientTableCellView.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 4/8/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import OmniSwiftX

class GradientTableCellView: NSTableCellView {

    @IBOutlet weak var gradientView: ColorGradientView!
    var gradient:ColorGradient1D? {
        get { return self.gradientView.gradient }
        set { self.gradientView.gradient = newValue }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.gradientView.layer?.backgroundColor = NSColor(patternImage: NSImage(byReferencingFile: NSBundle.mainBundle().pathForImageResource("BigCheckeredBackgroud.png")!)!).CGColor
    }
}
