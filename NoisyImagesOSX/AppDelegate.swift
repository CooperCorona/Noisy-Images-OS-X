//
//  AppDelegate.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 3/26/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa
import CoreData

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Computed Variables
    
    fileprivate(set) lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    fileprivate(set) lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "NoisyImagesOSX", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    fileprivate(set) lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator:NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
//        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("NoiseGenerator.sqlite")
        let url = Bundle.main.url(forResource: "NoisyImagesOSX", withExtension: "momd")!.appendingPathComponent("NoiseGenerator.sqlite")
        do {
            try coordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch var error1 as NSError {
            coordinator = nil
            print("Error initializing persistent store: \(error1)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    fileprivate(set) lazy var managedObjectContext: NSManagedObjectContext? = {
        guard let coordinator = self.persistentStoreCoordinator else {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Properties
    
    var editSizeSetsController:NSWindowController? = nil
    
    // MARK: - App States
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // MARK: - Logic
    
    static let SaveGradientItemClickedNotification          = "Save Gradient Item Clicked Notification"
    static let SaveNewGradientItemClickedNotification       = "Save New Gradient Item Clicked Notification"
    static let ExportImageItemClickedNotification           = "com.coopercorona.NoisyImagesOSX.ExportImageItemClicked"
    static let ExportImageAdvancedItemClickedNotification   = "com.coopercorona.NoisyImagesOSX.ExportImageAdvancedItemClicked"
    static let ZoomInItemClickedNotification                = "com.coopercorona.NoisyImagesOSX.ZoomInItemClicked"
    static let ZoomOutItemClickedNotification               = "com.coopercorona.NoisyImagesOSX.ZoomOutItemClicked"
    static let ResetZoomItemClickedNotification             = "com.coopercorona.NoisyImagesOSX.ResetZoomItemClicked"
    
    @IBAction func saveItemClicked(_ sender: AnyObject) {
        print("Save item clicked...")
    }
    
    @IBAction func saveGradientItemClicked(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppDelegate.SaveGradientItemClickedNotification), object: self)
    }
    
    @IBAction func saveNewGradientItemClicked(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppDelegate.SaveNewGradientItemClickedNotification), object: self)
    }
    
    @IBAction func exportImageItemClicked(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppDelegate.ExportImageItemClickedNotification), object: nil)
    }
    
    @IBAction func exportImageAdvancedItemClicked(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppDelegate.ExportImageAdvancedItemClickedNotification), object: nil)
    }
    
    
    @IBAction func editSizeSetsItemClicked(_ sender: AnyObject?) {
        let window = NSStoryboard(name: NSStoryboard.Name(rawValue: "EditSizeSets"), bundle: nil).instantiateInitialController() as! NSWindowController
        window.showWindow(self)
        self.editSizeSetsController = window
    }
    
    class func presentEditSizeSetsController() {
        (NSApplication.shared.delegate! as! AppDelegate).editSizeSetsItemClicked(nil)
    }
    
    @IBAction func zoomInItemClicked(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppDelegate.ZoomInItemClickedNotification), object: self)
    }
    
    @IBAction func zoomOutItemClicked(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppDelegate.ZoomOutItemClickedNotification), object: self)
    }
    
    @IBAction func resetZoomItemClicked(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppDelegate.ResetZoomItemClickedNotification), object: self)
    }
    
}

