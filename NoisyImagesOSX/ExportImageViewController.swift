//
//  ExportImageViewController.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 5/6/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa

class ExportImageViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func exportButtonPressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewController(self)
    }
    
}
