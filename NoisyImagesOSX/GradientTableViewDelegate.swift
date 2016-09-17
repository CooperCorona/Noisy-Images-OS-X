//
//  GradientTableViewDelegate.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 4/8/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import CoronaConvenience
import CoronaStructures
import CoronaGL
import CoreData

extension NSObject {
    var appDelegate:AppDelegate { return NSApplication.shared().delegate! as! AppDelegate }
}

extension ColorGradient1D {

    convenience init(gradient:Gradient) {
        var colors:[SCVector4]  = []
        var weights:[CGFloat] = []
        for col in gradient.colors {
            colors.append(col.color.getVector4())
            weights.append(col.weight)
        }
        self.init(colors: colors, weights: weights, smoothed: gradient.smoothed?.boolValue ?? false)
    }
    
    func configureGradient(_ gradient:Gradient) {
        gradient.colors = self.anchors.map() { ColorAnchor(color: NSColor(vector4: $0.0), weight: $0.1) }
        gradient.smoothed = self.isSmoothed as NSNumber?
    }

}

class GradientTableViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {

    // MARK: - Properties
    
    static let GradientStoreChangedNotification = "com.coopercorona.GradientStoreChangedNotification"
    
    let managedObjectContext:NSManagedObjectContext = ((NSApplication.shared().delegate as? AppDelegate)?.managedObjectContext)!
    let fetchRequest = NSFetchRequest<Gradient>(entityName: "Gradient")
    
    fileprivate(set) var gradientObjects:[Gradient] = []
    fileprivate(set) var gradients:[ColorGradient1D] = []
    
    fileprivate var selectedGradientIndex:Int? = nil
    fileprivate var selectedGradient:Gradient? {
        if let index = self.selectedGradientIndex {
            return self.gradientObjects[index]
        } else {
            return nil
        }
    }
    var gradientSelectedHandler:((Gradient) -> Void)? = nil
    var gradientStoreChangedHandler:((GradientTableViewDelegate) -> Void)? = nil
    var uuids:[String] { return self.gradientObjects.map() { $0.universalId! } }
    
    // MARK: - Setup
    
    override init() {

        super.init()
        
        self.storeChanged(nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged), name: NSNotification.Name(rawValue: GradientTableViewDelegate.GradientStoreChangedNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.gradients.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return self.gradients[row]
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.make(withIdentifier: "GradientCell", owner: self) as! ColorGradientView
        view.gradient = self.gradients[row]
        view.subviews.first?.wantsLayer = true
        view.subviews.first?.layer?.backgroundColor = self.gradientObjects[row].overlayColor?.cgColor
        return view
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else {
            return
        }
        self.selectedGradientIndex = tableView.selectedRow
        if let gradient = self.gradientObjects.objectAtIndex(tableView.selectedRow) {
            self.gradientSelectedHandler?(gradient)
        }
    }
    
    // MARK: - Logic

    func addGradient(_ gradient:GradientContainer) {
        gradient.generateUUID()
        let newGradient = NSEntityDescription.insertNewObject(forEntityName: "Gradient", into: self.managedObjectContext) as! Gradient
        gradient.toGradient(newGradient)
        do {
            try self.managedObjectContext.save()
            self.gradientObjects.insert(newGradient, at: 0)
            self.gradients.insert(gradient.gradient, at: 0)
        } catch {
            Swift.print("Could not insert new gradient!")
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: GradientTableViewDelegate.GradientStoreChangedNotification), object: nil)
    }

    ///Overwrites the currently selected gradient with the new gradient
    func saveGradient(_ gradient:GradientContainer) {
        //If the gradient container does not yet have a valid UUID,
        //then it should be empty, and thus should not exist in the
        //gradientObjects array, so addGradient should get invoked.
        if let index = self.gradientObjects.index(where: { $0.universalId == gradient.uuid }) {
            gradient.generateUUID()
            self.gradientObjects[index].universalId = gradient.uuid
            gradient.toGradient(self.gradientObjects[index])
            self.gradients[index] = gradient.gradient
            do {
                try self.managedObjectContext.save()
            } catch {
                Swift.print("Failed to save gradient!")
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: GradientTableViewDelegate.GradientStoreChangedNotification), object: nil)
        } else {
            self.addGradient(gradient)
        }
        
    }
    
    func verifyGradient(_ gradient:GradientContainer) {
        guard !self.gradientObjects.contains(where: { $0.universalId == gradient.uuid }) else {
            return
        }
        self.addGradient(gradient)
    }
    
    subscript(uuid:String) -> GradientContainer? {
        guard let index = self.gradientObjects.index(where: { $0.universalId == uuid }) else {
            return nil
        }
        let grad = GradientContainer()
        grad.gradient = self.gradients[index]
        grad.uuid = self.gradientObjects[index].universalId!
        return grad
    }
 
    func storeChanged(_ notification:Notification?) {
        do {
            self.gradientObjects = try self.managedObjectContext.fetch(self.fetchRequest) as! [Gradient]
        } catch {
            self.gradientObjects = []
        }
        self.gradients = self.gradientObjects.map({ ColorGradient1D(gradient: $0) })
        if self.gradients.count == 0 {
            //Preload first gradient
            let gradient = NSEntityDescription.insertNewObject(forEntityName: "Gradient", into: self.managedObjectContext) as! Gradient
            gradient.gradient = ColorGradient1D.grayscaleGradient
            gradient.overlay = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).getString()
            gradient.generateUUID()
            do {
                try self.managedObjectContext.save()
                self.gradientObjects.append(gradient)
                self.gradients.append(ColorGradient1D.grayscaleGradient)
            } catch {
                
            }
        }
        self.gradientStoreChangedHandler?(self)
    }
    
    
}
