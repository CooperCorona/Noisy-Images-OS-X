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
        case valid
        case alreadyExists
        case missingWidth
        case missingHeight
        case onlyWhitespace
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var sizeSetPopupButton: NSPopUpButton!
    let tableDelegate = EditSizeSetsTableViewDelegate(editable: true)
    @IBOutlet weak var sizeTableView: NSTableView!
    @IBOutlet weak var widthTextField: NSTextField!
    @IBOutlet weak var heightTextField: NSTextField!
    @IBOutlet weak var suffixTextField: NSTextField!
    @IBOutlet weak var addSizeSetMemberButton: NSButton!
    
    let integerFormatter = NumberFormatter()
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.integerFormatter.allowsFloats  = false
        self.integerFormatter.minimum       = 8.0
        self.integerFormatter.maximum       = 1024.0
        self.widthTextField.formatter       = self.integerFormatter
        self.heightTextField.formatter      = self.integerFormatter
        
        self.sizeTableView.register(NSNib(nibNamed: NSNib.Name(rawValue: "EditSizeSetsTableViewCell"), bundle: Bundle.main), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "EditSizeSetsTableViewCell"))
        
        self.tableDelegate.loadSizeSets()
        self.tableDelegate.configurePopupButton(self.sizeSetPopupButton, selectTitle: nil)
        if self.sizeSetPopupButton.integerValue != 0 {
            self.tableDelegate.loadMembersForSet(self.sizeSetPopupButton.titleOfSelectedItem!)
        }
        self.sizeTableView.delegate = self.tableDelegate
        self.sizeTableView.dataSource = self.tableDelegate
        
        self.enableOrDisableTextFields()
    }
    
    // MARK: - Logic
    
    func enableOrDisableTextFields() {
        if self.sizeSetPopupButton.integerValue == 0 {
            self.widthTextField.isEnabled         = false
            self.heightTextField.isEnabled        = false
            self.suffixTextField.isEnabled        = false
            self.addSizeSetMemberButton.isEnabled = false
        } else {
            self.widthTextField.isEnabled         = true
            self.heightTextField.isEnabled        = true
            self.suffixTextField.isEnabled        = true
            self.addSizeSetMemberButton.isEnabled = true
        }
    }
    
    @IBAction func sizeSetPopupButtonChanged(_ sender: AnyObject) {
        self.enableOrDisableTextFields()
    }
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
    
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func widthTextFieldEndedEditing(_ sender: AnyObject) {
        self.heightTextField.becomeFirstResponder()
    }
    
    @IBAction func heightTextFieldEndedEditing(_ sender: AnyObject) {
        self.suffixTextField.becomeFirstResponder()
    }
    
    @IBAction func suffixTextFieldEndedEditing(_ sender: AnyObject) {
        self.addSizeSetMemberButtonPressed(sender)
    }
    
    @IBAction func addSizeSetMemberButtonPressed(_ sender: AnyObject) {
        switch self.validateMemberData(self.suffixTextField.stringValue) {
        case .valid:
            let setName = self.sizeSetPopupButton.titleOfSelectedItem!
            let width   = self.widthTextField.integerValue
            let height  = self.heightTextField.integerValue
            let suffix  = self.suffixTextField.stringValue
            self.tableDelegate.addMemberTo(setName, width: width, height: height, suffix: suffix)
            self.sizeTableView.reloadData()
            self.clearTextFields()
        case .alreadyExists:
            self.presentAlert("That suffix already exists!")
        case .missingWidth:
            self.presentAlert("The width must not be empty!")
        case .missingHeight:
            self.presentAlert("The height must not be empty!")
        case .onlyWhitespace:
//            self.presentAlert("The suffix must not be empty!")
            // For now, we don't present an alert, because clicking
            // into the text field and clicking out presents it, which is weird.
            break
        }
    }
    
    func validateMemberData(_ suffix:String) -> SuffixValidationResult {
        if suffix.removeAllWhiteSpace() == "" {
            return .onlyWhitespace
        }
        
        if self.widthTextField.stringValue.characterCount == 0 {
            return .missingWidth
        }
        if self.heightTextField.stringValue.characterCount == 0 {
            return .missingHeight
        }
        
        for member in self.tableDelegate.sizeSetMembers {
            if member.suffix == suffix {
                return .alreadyExists
            }
        }
        return .valid
    }
    
    func clearTextFields() {
        self.widthTextField.stringValue  = ""
        self.heightTextField.stringValue = ""
        self.suffixTextField.stringValue = ""
    }
    
    func presentAlert(_ message:String) {
        let alert = NSAlert()
        alert.alertStyle = NSAlert.Style.warning
        alert.messageText = message
        alert.addButton(withTitle: "Ok")
        alert.runModal()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.identifier?.rawValue {
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

    @IBAction func deleteItemClicked(_ sender: NSMenuItem) {
        self.deleteBackward(sender)
    }
    
    override func deleteBackward(_ sender: Any?) {
        let index = self.sizeTableView.selectedRow
        if self.sizeTableView.isRowSelected(index) {
            self.tableDelegate.removeMemberAtIndex(index)
            self.sizeTableView.reloadData()
        }
    }
    
    override func keyDown(with theEvent: NSEvent) {
        self.interpretKeyEvents([theEvent])
    }
    
}
