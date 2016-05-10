//
//  EditSizeSetsTableViewDelegate.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 5/8/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import CoreData

class EditSizeSetsTableViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {

    // MARK: - Properties
    
    let request = NSFetchRequest(entityName: "SizeSet")
    let editable:Bool
    let managedObjectContext:NSManagedObjectContext = ((NSApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext)!
    
    private var sizeSets:[SizeSet] = []
    private(set) var sizeSetMembers:[SizeSetMember] = []
    private var currentSetName = ""

    // MARK: - Setup
    
    init(editable:Bool) {
        self.editable = editable
        self.request.sortDescriptors?.append(NSSortDescriptor(key: "name", ascending: true))
        super.init()
    }
    
    func loadSizeSets() {
//        let predicate = NSPredicate(format: "%K like %@", "name", setName)
        do {
            let sizeSets = try self.managedObjectContext.executeFetchRequest(self.request) as! [SizeSet]
            self.sizeSets = sizeSets
        } catch {
            
        }
    }
    
    func loadMembersForSet(setName:String) {
        guard let index = self.sizeSets.indexOf({ $0.name == setName }), let sizeSetMembers = self.sizeSets[index].sizes else {
            return
        }
        self.currentSetName = setName
        self.sizeSetMembers = sizeSetMembers.toArray()
        self.sortMembers()
    }
    
    private func sortMembers() {
        self.sizeSetMembers = self.sizeSetMembers.sort() {
            if $0.width!.integerValue == $1.width!.integerValue {
                return $0.height!.integerValue < $1.height!.integerValue
            } else {
                return $0.width!.integerValue < $1.width!.integerValue
            }
        }
    }
    
    // MARK: - Logic
    
    func configurePopupButton(popupButton:NSPopUpButton, selectTitle:String?) {
        popupButton.removeAllItems()
        for sizeSet in self.sizeSets {
            popupButton.addItemWithTitle(sizeSet.name!)
        }
        if let selectTitle = selectTitle {
            popupButton.selectItemWithTitle(selectTitle)
        }
    }
    
    func addMemberTo(setName:String, width:Int, height:Int, suffix:String) -> Bool {
        guard let set = self.sizeSets.findObject({ $0.name == setName }) else {
            return false
        }
        do {
            let member = NSEntityDescription.insertNewObjectForEntityForName("SizeSetMember", inManagedObjectContext: self.managedObjectContext) as! SizeSetMember
            member.width  = width
            member.height = height
            member.suffix = suffix
            set.sizes?.insert(member)
            try self.managedObjectContext.save()
            self.loadMembersForSet(setName)
            return true
        } catch {
            return false
        }
    }
    
    func removeMemberAtIndex(index:Int) {
        guard index >= 0 && index < self.sizeSetMembers.count else {
            return
        }
        let member = self.sizeSetMembers.removeAtIndex(index)
        guard let sizeSet = self.sizeSets.findObject({ $0.name == self.currentSetName }) else {
            return
        }
        
        do {
            print("Before: \(sizeSet.sizes?.count)")
            sizeSet.sizes?.remove(member)
            print("After: \(sizeSet.sizes?.count)")
            self.managedObjectContext.deleteObject(member)
            try self.managedObjectContext.save()
        } catch {
            
        }
    }
    
    // MARK: - NSTableViewDelegate
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.sizeSetMembers.count
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeViewWithIdentifier("EditSizeSetsTableViewCell", owner: self)!
        let label = view.subviews.first! as! NSTextField
        
        switch tableColumn?.identifier {
        case "AutomaticTableColumnIdentifier.0"?:
            label.stringValue = "\(self.sizeSetMembers[row].width!.integerValue)"
        case "AutomaticTableColumnIdentifier.1"?:
            label.stringValue = "\(self.sizeSetMembers[row].height!.integerValue)"
        case "AutomaticTableColumnIdentifier.2"?:
            label.stringValue = self.sizeSetMembers[row].suffix!
        default:
            break
        }
        
        
        return view
    }
    
}
