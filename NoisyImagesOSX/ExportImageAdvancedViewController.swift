//
//  ExportImageAdvancedViewController.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 5/7/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import OmniSwiftX

class ExportImageAdvancedTableViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return 3
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeViewWithIdentifier("SizeCell", owner: self) as! NSTextField
        return view
    }

    
}

class ExportImageAdvancedViewController: NSViewController {
    
    @IBOutlet weak var sizesTableView: NSTableView!
//    let sizesDelegate = ExportImageAdvancedTableViewDelegate()
    let sizesDelegate = EditSizeSetsTableViewDelegate(editable: false)
    @IBOutlet weak var sizeSetsPopupButton: NSPopUpButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    var noiseSprite:GLSPerlinNoiseSprite? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sizesTableView.registerNib(NSNib(nibNamed: "EditSizeSetsTableViewCell", bundle: NSBundle.mainBundle()), forIdentifier: "EditSizeSetsTableViewCell")
        self.sizesTableView.setDelegate(self.sizesDelegate)
        self.sizesTableView.setDataSource(self.sizesDelegate)
        
        self.sizesDelegate.loadSizeSets()
        self.sizesDelegate.configurePopupButton(self.sizeSetsPopupButton, selectTitle: nil)
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
            guard let pathExtension = url.pathExtension else {
                return
            }
            let originalSize = noiseSprite.contentSize
            self.progressIndicator.startAnimation(self)
            
            let pathPrefix = url.URLByDeletingPathExtension!.path!
            for sizeMember in self.sizesDelegate.sizeSetMembers {
                noiseSprite.contentSize = NSSize(width: sizeMember.width!.integerValue, height: sizeMember.height!.integerValue)
                ViewController.setViewportTo(noiseSprite.contentSize)
                noiseSprite.renderToTexture()
                let currentURL = NSURL(fileURLWithPath: "\(pathPrefix)\(sizeMember.suffix!)").URLByAppendingPathExtension(pathExtension)
                ExportImageViewController.writeNoiseSprite(noiseSprite, toURL: currentURL)
                self.progressIndicator.incrementBy(100.0 / Double(self.sizesDelegate.sizeSetMembers.count))
            }
            self.progressIndicator.stopAnimation(self)
            
            noiseSprite.contentSize = originalSize
            ViewController.setViewportTo(originalSize)
            noiseSprite.renderToTexture()
        default:
            break
        }
        
        self.presentingViewController?.dismissViewController(self)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewController(self)
    }
    @IBAction func editSizeSetsButtonPressed(sender: AnyObject) {
        AppDelegate.presentEditSizeSetsController()
    }
    
    @IBAction func sizeSetsPopupButtonChanged(sender: AnyObject) {
        let index = self.sizeSetsPopupButton.indexOfSelectedItem
        guard 0 <= index && index < self.sizeSetsPopupButton.itemTitles.count else {
            return
        }
        let setName = self.sizeSetsPopupButton.itemTitleAtIndex(index)
        self.sizesDelegate.loadMembersForSet(setName)
        self.sizesDelegate.configurePopupButton(self.sizeSetsPopupButton, selectTitle: setName)
        self.sizesTableView.reloadData()
    }
    
}
