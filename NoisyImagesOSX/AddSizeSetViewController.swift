//
//  AddSizeSetViewController.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 5/8/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa

class AddSizeSetViewController: NSViewController {
    
    var sizeSets:[SizeSet] = []
    @IBOutlet weak var nameTextField: NSTextField!
    let managedObjectContext:NSManagedObjectContext = ((NSApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext)!
    var dismissHandler:((String) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sizeSets = self.fetchSizeSets()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(nameTextFieldChanged), name: NSControlTextDidEndEditingNotification, object: self.nameTextField)
    }
    
    func fetchSizeSets() -> [SizeSet] {
        do {
            let request = NSFetchRequest(entityName: "SizeSet")
            let sizeSets = try self.managedObjectContext.executeFetchRequest(request) as! [SizeSet]
            return sizeSets
        } catch {
            return []
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func textIsValid(text:String) -> Bool {
        for sizeSet in self.sizeSets {
            if sizeSet.name == text {
                return false
            }
        }
        return true
    }
    
    func nameTextFieldChanged(sender:NSTextField) {
        self.addButtonPressed(sender)
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        if self.textIsValid(self.nameTextField.stringValue) {
            self.addSizeSet(self.nameTextField.stringValue)
        } else {
            self.presentNameTakenError()
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewController(self)
    }
    
    func presentNameTakenError() {
        let alert = NSAlert()
        alert.alertStyle = NSAlertStyle.WarningAlertStyle
        alert.messageText = "That name is already taken!"
        alert.addButtonWithTitle("Ok")
        alert.runModal()
    }
    
    func addSizeSet(name:String) {
        do {
            let sizeSet = NSEntityDescription.insertNewObjectForEntityForName("SizeSet", inManagedObjectContext: self.managedObjectContext) as! SizeSet
            sizeSet.name = name
            try self.managedObjectContext.save()
        } catch {
            
        }
        
        self.dismissHandler?(name)
        self.presentingViewController?.dismissViewController(self)
    }
    
}
