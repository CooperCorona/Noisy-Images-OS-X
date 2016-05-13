//
//  ExportImageViewController.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 5/6/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import OmniSwiftX

class ExportImageViewController: NSViewController {

    var noiseSprite:GLSPerlinNoiseSprite? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func exportButtonPressed(sender: AnyObject) {
        guard let noiseSprite = self.noiseSprite else {
            return
        }
        
        let panel = NSSavePanel()
        panel.canSelectHiddenExtension = true
        panel.allowedFileTypes = ["png"]
        switch panel.runModal() {
        case NSModalResponseOK:
            guard let url = panel.URL else {
                return
            }
            ExportImageViewController.writeNoiseSprite(noiseSprite, toURL: url)
        default:
            break
        }
        
        self.presentingViewController?.dismissViewController(self)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewController(self)
    }
    
    class func writeNoiseSprite(noiseSprite:GLSPerlinNoiseSprite, toURL url:NSURL) {
        let image = noiseSprite.buffer.getImage()
        let cgImage = image.CGImageForProposedRect(nil, context: nil, hints: nil)!
        let bitmap = NSBitmapImageRep(CGImage: cgImage)
        bitmap.size = image.size
        let data = bitmap.representationUsingType(.NSPNGFileType, properties: [:])
        do {
            try data?.writeToURL(url, options: .DataWritingAtomic)
        } catch {
            print(error)
        }
    }
}
