//
//  EditSizeSetsViewController.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 5/8/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa

class EditSizeSetsViewController: NSViewController {
    
    // MARK: - Types
    
    enum SuffixValidationResult {
        case Valid
        case AlreadyExists
        case MissingWidth
        case MissingHeight
        case OnlyWhitespace
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var sizeSetPopupButton: NSPopUpButton!
    let tableDelegate = EditSizeSetsTableViewDelegate(editable: true)
    @IBOutlet weak var sizeTableView: NSTableView!
    @IBOutlet weak var widthTextField: NSTextField!
    @IBOutlet weak var heightTextField: NSTextField!
    @IBOutlet weak var suffixTextField: NSTextField!
    @IBOutlet weak var addSizeSetMemberButton: NSButton!
    
    let integerFormatter = NSNumberFormatter()
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.integerFormatter.allowsFloats  = false
        self.integerFormatter.minimum       = 8.0
        self.integerFormatter.maximum       = 1024.0
        self.widthTextField.formatter       = self.integerFormatter
        self.heightTextField.formatter      = self.integerFormatter
        
        self.sizeTableView.registerNib(NSNib(nibNamed: "EditSizeSetsTableViewCell", bundle: NSBundle.mainBundle()), forIdentifier: "EditSizeSetsTableViewCell")
        
        self.tableDelegate.loadSizeSets()
        self.tableDelegate.configurePopupButton(self.sizeSetPopupButton, selectTitle: nil)
        if self.sizeSetPopupButton.integerValue != 0 {
            self.tableDelegate.loadMembersForSet(self.sizeSetPopupButton.titleOfSelectedItem!)
        }
        self.sizeTableView.setDelegate(self.tableDelegate)
        self.sizeTableView.setDataSource(self.tableDelegate)
        
        self.enableOrDisableTextFields()
    }
    
    // MARK: - Logic
    
    func enableOrDisableTextFields() {
        if self.sizeSetPopupButton.integerValue == 0 {
            self.widthTextField.enabled         = false
            self.heightTextField.enabled        = false
            self.suffixTextField.enabled        = false
            self.addSizeSetMemberButton.enabled = false
        } else {
            self.widthTextField.enabled         = true
            self.heightTextField.enabled        = true
            self.suffixTextField.enabled        = true
            self.addSizeSetMemberButton.enabled = true
        }
    }
    
    @IBAction func sizeSetPopupButtonChanged(sender: AnyObject) {
        self.enableOrDisableTextFields()
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
    
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        
    }
    
    @IBAction func widthTextFieldEndedEditing(sender: AnyObject) {
        self.heightTextField.becomeFirstResponder()
    }
    
    @IBAction func heightTextFieldEndedEditing(sender: AnyObject) {
        self.suffixTextField.becomeFirstResponder()
    }
    
    @IBAction func suffixTextFieldEndedEditing(sender: AnyObject) {
        self.addSizeSetMemberButtonPressed(sender)
    }
    
    @IBAction func addSizeSetMemberButtonPressed(sender: AnyObject) {
        switch self.validateMemberData(self.suffixTextField.stringValue) {
        case .Valid:
            let setName = self.sizeSetPopupButton.titleOfSelectedItem!
            let width   = self.widthTextField.integerValue
            let height  = self.heightTextField.integerValue
            let suffix  = self.suffixTextField.stringValue
            self.tableDelegate.addMemberTo(setName, width: width, height: height, suffix: suffix)
            self.sizeTableView.reloadData()
            self.clearTextFields()
        case .AlreadyExists:
            self.presentAlert("That suffix already exists!")
        case .MissingWidth:
            self.presentAlert("The width must not be empty!")
        case .MissingHeight:
            self.presentAlert("The height must not be empty!")
        case .OnlyWhitespace:
//            self.presentAlert("The suffix must not be empty!")
            // For now, we don't present an alert, because clicking
            // into the text field and clicking out presents it, which is weird.
            break
        }
    }
    
    func validateMemberData(suffix:String) -> SuffixValidationResult {
        if suffix.removeAllWhiteSpace() == "" {
            return .OnlyWhitespace
        }
        
        if self.widthTextField.stringValue.characterCount == 0 {
            return .MissingWidth
        }
        if self.heightTextField.stringValue.characterCount == 0 {
            return .MissingHeight
        }
        
        for member in self.tableDelegate.sizeSetMembers {
            if member.suffix == suffix {
                return .AlreadyExists
            }
        }
        return .Valid
    }
    
    func clearTextFields() {
        self.widthTextField.stringValue  = ""
        self.heightTextField.stringValue = ""
        self.suffixTextField.stringValue = ""
    }
    
    func presentAlert(message:String) {
        let alert = NSAlert()
        alert.alertStyle = NSAlertStyle.WarningAlertStyle
        alert.messageText = message
        alert.addButtonWithTitle("Ok")
        alert.runModal()
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "AddSizeSetSegue"?:
            guard let dest = segue.destinationController as? AddSizeSetViewController else {
                return
            }
            dest.dismissHandler = { [weak self] newName in
                guard let strongSelf = self else { return }
                strongSelf.tableDelegate.loadSizeSets()
                strongSelf.tableDelegate.loadMembersForSet(newName)
                strongSelf.tableDelegate.configurePopupButton(strongSelf.sizeSetPopupButton, selectTitle: newName)
                strongSelf.sizeTableView.reloadData()
                strongSelf.enableOrDisableTextFields()
            }
        default:
            break
        }
    }

    @IBAction func deleteItemClicked(sender: NSMenuItem) {
        self.deleteBackward(sender)
    }
    
    override func deleteBackward(sender: AnyObject?) {
        let index = self.sizeTableView.selectedRow
        if self.sizeTableView.isRowSelected(index) {
            self.tableDelegate.removeMemberAtIndex(index)
            self.sizeTableView.reloadData()
        }
    }
    
    override func keyDown(theEvent: NSEvent) {
        self.interpretKeyEvents([theEvent])
    }
    
}
