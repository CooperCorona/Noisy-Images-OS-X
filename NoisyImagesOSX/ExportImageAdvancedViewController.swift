//
//  ExportImageAdvancedViewController.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 5/7/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa

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
    let sizesDelegate = ExportImageAdvancedTableViewDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sizesTableView.registerNib(NSNib(nibNamed: "ExportImageAdvancedTableViewCell", bundle: NSBundle.mainBundle()), forIdentifier: "SizeCell")
        self.sizesTableView.setDelegate(self.sizesDelegate)
        self.sizesTableView.setDataSource(self.sizesDelegate)
    }
    
    @IBAction func exportButtonPressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewController(self)
    }
    
    @IBAction func editSizeSetsButtonPressed(sender: AnyObject) {
        AppDelegate.presentEditSizeSetsController()
    }
    
}
