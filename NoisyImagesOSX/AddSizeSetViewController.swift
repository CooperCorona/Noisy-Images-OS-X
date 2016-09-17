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
    let managedObjectContext:NSManagedObjectContext = ((NSApplication.shared().delegate as? AppDelegate)?.managedObjectContext)!
    var dismissHandler:((String) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sizeSets = self.fetchSizeSets()
        
        NotificationCenter.default.addObserver(self, selector: #selector(nameTextFieldChanged), name: NSNotification.Name.NSControlTextDidEndEditing, object: self.nameTextField)
    }
    
    func fetchSizeSets() -> [SizeSet] {
        do {
            let request = NSFetchRequest<SizeSet>(entityName: "SizeSet")
            let sizeSets = try self.managedObjectContext.fetch(request) as! [SizeSet]
            return sizeSets
        } catch {
            return []
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        NotificationCenter.default.removeObserver(self)
    }
    
    func textIsValid(_ text:String) -> Bool {
        for sizeSet in self.sizeSets {
            if sizeSet.name == text {
                return false
            }
        }
        return true
    }
    
    func nameTextFieldChanged(_ sender:NSTextField) {
        self.addButtonPressed(sender)
    }
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        if self.textIsValid(self.nameTextField.stringValue) {
            self.addSizeSet(self.nameTextField.stringValue)
        } else {
            self.presentNameTakenError()
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.presenting?.dismissViewController(self)
    }
    
    func presentNameTakenError() {
        let alert = NSAlert()
        alert.alertStyle = NSAlertStyle.warning
        alert.messageText = "That name is already taken!"
        alert.addButton(withTitle: "Ok")
        alert.runModal()
    }
    
    func addSizeSet(_ name:String) {
        do {
            let sizeSet = NSEntityDescription.insertNewObject(forEntityName: "SizeSet", into: self.managedObjectContext) as! SizeSet
            sizeSet.name = name
            try self.managedObjectContext.save()
        } catch {
            
        }
        
        self.dismissHandler?(name)
        self.presenting?.dismissViewController(self)
    }
    
}
