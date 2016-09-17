//
//  ExportImageViewController.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 5/6/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import CoronaConvenience
import CoronaStructures
import CoronaGL

class ExportImageViewController: NSViewController {

    var noiseSprite:GLSPerlinNoiseSprite? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func exportButtonPressed(_ sender: AnyObject) {
        guard let noiseSprite = self.noiseSprite else {
            return
        }
        
        let panel = NSSavePanel()
        panel.canSelectHiddenExtension = true
        panel.allowedFileTypes = ["png"]
        switch panel.runModal() {
        case NSModalResponseOK:
            guard let url = panel.url else {
                return
            }
            ExportImageViewController.writeNoiseSprite(noiseSprite, toURL: url)
        default:
            break
        }
        
        self.presenting?.dismissViewController(self)
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.presenting?.dismissViewController(self)
    }
    
    class func writeNoiseSprite(_ noiseSprite:GLSPerlinNoiseSprite, toURL url:URL) {
        let image = noiseSprite.buffer.getImage()
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmap = NSBitmapImageRep(cgImage: cgImage)
        bitmap.size = image.size
        let data = bitmap.representation(using: NSBitmapImageFileType.PNG, properties: [:])
        do {
            try data?.write(to: url, options: .atomic)
        } catch {
            print(error)
        }
    }
}
