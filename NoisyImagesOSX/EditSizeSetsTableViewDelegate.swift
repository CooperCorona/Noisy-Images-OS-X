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
    
    let request = NSFetchRequest<SizeSet>(entityName: "SizeSet")
    let editable:Bool
    let managedObjectContext:NSManagedObjectContext = ((NSApplication.shared.delegate as? AppDelegate)?.managedObjectContext)!
    
    fileprivate var sizeSets:[SizeSet] = []
    fileprivate(set) var sizeSetMembers:[SizeSetMember] = []
    fileprivate var currentSetName = ""

    // MARK: - Setup
    
    init(editable:Bool) {
        self.editable = editable
        self.request.sortDescriptors?.append(NSSortDescriptor(key: "name", ascending: true))
        super.init()
    }
    
    func loadSizeSets() {
//        let predicate = NSPredicate(format: "%K like %@", "name", setName)
        do {
            let sizeSets = try self.managedObjectContext.fetch(self.request) 
            self.sizeSets = sizeSets
        } catch {
            
        }
    }
    
    func loadMembersForSet(_ setName:String) {
        guard let index = self.sizeSets.index(where: { $0.name == setName }), let sizeSetMembers = self.sizeSets[index].sizes else {
            return
        }
        self.currentSetName = setName
        self.sizeSetMembers = sizeSetMembers.toArray()
        self.sortMembers()
    }
    
    fileprivate func sortMembers() {
        self.sizeSetMembers = self.sizeSetMembers.sorted() {
            if $0.width!.intValue == $1.width!.intValue {
                return $0.height!.intValue < $1.height!.intValue
            } else {
                return $0.width!.intValue < $1.width!.intValue
            }
        }
    }
    
    // MARK: - Logic
    
    func configurePopupButton(_ popupButton:NSPopUpButton, selectTitle:String?) {
        popupButton.removeAllItems()
        for sizeSet in self.sizeSets {
            popupButton.addItem(withTitle: sizeSet.name!)
        }
        if let selectTitle = selectTitle {
            popupButton.selectItem(withTitle: selectTitle)
        }
    }
    
    @discardableResult func addMemberTo(_ setName:String, width:Int, height:Int, suffix:String) -> Bool {
        guard let set = self.sizeSets.findObject({ $0.name == setName }) else {
            return false
        }
        do {
            let member = NSEntityDescription.insertNewObject(forEntityName: "SizeSetMember", into: self.managedObjectContext) as! SizeSetMember
            member.width  = width as NSNumber?
            member.height = height as NSNumber?
            member.suffix = suffix
            set.sizes?.insert(member)
            try self.managedObjectContext.save()
            self.loadMembersForSet(setName)
            return true
        } catch {
            return false
        }
    }
    
    func removeMemberAtIndex(_ index:Int) {
        guard index >= 0 && index < self.sizeSetMembers.count else {
            return
        }
        let member = self.sizeSetMembers.remove(at: index)
        guard let sizeSet = self.sizeSets.findObject({ $0.name == self.currentSetName }) else {
            return
        }
        
        do {
            print("Before: \(String(describing: sizeSet.sizes?.count))")
            sizeSet.sizes?.remove(member)
            print("After: \(String(describing: sizeSet.sizes?.count))")
            self.managedObjectContext.delete(member)
            try self.managedObjectContext.save()
        } catch {
            
        }
    }
    
    // MARK: - NSTableViewDelegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.sizeSetMembers.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "EditSizeSetsTableViewCell"), owner: self)!
        let label = view.subviews.first! as! NSTextField
        
        switch tableColumn?.identifier {
        case NSUserInterfaceItemIdentifier(rawValue: "AutomaticTableColumnIdentifier.0")?:
            label.stringValue = "\(self.sizeSetMembers[row].width!.intValue)"
        case NSUserInterfaceItemIdentifier(rawValue: "AutomaticTableColumnIdentifier.1")?:
            label.stringValue = "\(self.sizeSetMembers[row].height!.intValue)"
        case NSUserInterfaceItemIdentifier(rawValue: "AutomaticTableColumnIdentifier.2")?:
            label.stringValue = self.sizeSetMembers[row].suffix!
        default:
            break
        }
        
        
        return view
    }
    
}
