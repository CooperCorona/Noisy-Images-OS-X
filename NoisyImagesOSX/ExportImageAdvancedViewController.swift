//
//  ExportImageAdvancedViewController.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 5/7/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import CoronaConvenience
import CoronaStructures
import CoronaGL

class ExportImageAdvancedTableViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SizeCell"), owner: self) as! NSTextField
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
        
        self.sizesTableView.register(NSNib(nibNamed: NSNib.Name(rawValue: "EditSizeSetsTableViewCell"), bundle: Bundle.main), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "EditSizeSetsTableViewCell"))
        self.sizesTableView.delegate = self.sizesDelegate
        self.sizesTableView.dataSource = self.sizesDelegate
        
        self.sizesDelegate.loadSizeSets()
        self.sizesDelegate.configurePopupButton(self.sizeSetsPopupButton, selectTitle: nil)
    }
    
    @IBAction func exportButtonPressed(_ sender: AnyObject) {
        guard let noiseSprite = self.noiseSprite else {
            return
        }
        
        let panel = NSSavePanel()
        panel.canSelectHiddenExtension = true
        panel.allowedFileTypes = ["png"]
        switch panel.runModal() {
        case NSApplication.ModalResponse.OK:
            guard let url = panel.url else {
                return
            }
            let pathExtension = url.pathExtension
            let originalSize = noiseSprite.contentSize
            self.progressIndicator.startAnimation(self)
            
            let pathPrefix = url.deletingPathExtension().path
            for sizeMember in self.sizesDelegate.sizeSetMembers {
                noiseSprite.contentSize = NSSize(width: sizeMember.width!.intValue, height: sizeMember.height!.intValue)
                ViewController.setViewportTo(noiseSprite.contentSize)
                noiseSprite.renderToTexture()
                let currentURL = URL(fileURLWithPath: "\(pathPrefix)\(sizeMember.suffix!)").appendingPathExtension(pathExtension)
                ExportImageViewController.writeNoiseSprite(noiseSprite, toURL: currentURL)
                self.progressIndicator.increment(by: 100.0 / Double(self.sizesDelegate.sizeSetMembers.count))
            }
            self.progressIndicator.stopAnimation(self)
            
            noiseSprite.contentSize = originalSize
            ViewController.setViewportTo(originalSize)
            noiseSprite.renderToTexture()
        default:
            break
        }
        
        self.presenting?.dismissViewController(self)
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.presenting?.dismissViewController(self)
    }
    @IBAction func editSizeSetsButtonPressed(_ sender: AnyObject) {
        AppDelegate.presentEditSizeSetsController()
    }
    
    @IBAction func sizeSetsPopupButtonChanged(_ sender: AnyObject) {
        let index = self.sizeSetsPopupButton.indexOfSelectedItem
        guard 0 <= index && index < self.sizeSetsPopupButton.itemTitles.count else {
            return
        }
        let setName = self.sizeSetsPopupButton.itemTitle(at: index)
        self.sizesDelegate.loadMembersForSet(setName)
        self.sizesDelegate.configurePopupButton(self.sizeSetsPopupButton, selectTitle: setName)
        self.sizesTableView.reloadData()
    }
    
}
