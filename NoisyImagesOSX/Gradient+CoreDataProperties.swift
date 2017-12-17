//
//  Gradient+CoreDataProperties.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 12/16/17.
//  Copyright © 2017 Cooper Knaak. All rights reserved.
//
//

import Foundation
import CoreData


extension Gradient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Gradient> {
        return NSFetchRequest<Gradient>(entityName: "Gradient")
    }

    @NSManaged public var color1: String?
    @NSManaged public var color2: String?
    @NSManaged public var color3: String?
    @NSManaged public var color4: String?
    @NSManaged public var color5: String?
    @NSManaged public var color6: String?
    @NSManaged public var color7: String?
    @NSManaged public var color8: String?
    @NSManaged public var color9: String?
    @NSManaged public var color10: String?
    @NSManaged public var color11: String?
    @NSManaged public var color12: String?
    @NSManaged public var color13: String?
    @NSManaged public var color14: String?
    @NSManaged public var color15: String?
    @NSManaged public var color16: String?
    @NSManaged public var overlay: String?
    @NSManaged public var smoothed: NSNumber?
    @NSManaged public var universalId: String?

}
