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
    
    private(set) lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    private(set) lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("NoisyImagesOSX", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    private(set) lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator:NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
//        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("NoiseGenerator.sqlite")
        let url = NSBundle.mainBundle().URLForResource("NoisyImagesOSX", withExtension: "momd")!.URLByAppendingPathComponent("NoiseGenerator.sqlite")
        do {
            try coordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            coordinator = nil
            print("Error initializing persistent store: \(error1)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    private(set) lazy var managedObjectContext: NSManagedObjectContext? = {
        guard let coordinator = self.persistentStoreCoordinator else {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Properties
    
    var editSizeSetsController:NSWindowController? = nil
    
    // MARK: - App States
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
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
    
    @IBAction func saveItemClicked(sender: AnyObject) {
        print("Save item clicked...")
    }
    
    @IBAction func saveGradientItemClicked(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.SaveGradientItemClickedNotification, object: self)
    }
    
    @IBAction func saveNewGradientItemClicked(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.SaveNewGradientItemClickedNotification, object: self)
    }
    
    @IBAction func exportImageItemClicked(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.ExportImageItemClickedNotification, object: nil)
    }
    
    @IBAction func exportImageAdvancedItemClicked(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.ExportImageAdvancedItemClickedNotification, object: nil)
    }
    
    
    @IBAction func editSizeSetsItemClicked(sender: AnyObject?) {
        let window = NSStoryboard(name: "EditSizeSets", bundle: nil).instantiateInitialController() as! NSWindowController
        window.showWindow(self)
        self.editSizeSetsController = window
    }
    
    class func presentEditSizeSetsController() {
        (NSApplication.sharedApplication().delegate! as! AppDelegate).editSizeSetsItemClicked(nil)
    }
    
    @IBAction func zoomInItemClicked(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.ZoomInItemClickedNotification, object: self)
    }
    
    @IBAction func zoomOutItemClicked(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.ZoomOutItemClickedNotification, object: self)
    }
    
    @IBAction func resetZoomItemClicked(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.ResetZoomItemClickedNotification, object: self)
    }
    
}

