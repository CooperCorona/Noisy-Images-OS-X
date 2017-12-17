//
//  SizeSetMember+CoreDataProperties.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 12/16/17.
//  Copyright © 2017 Cooper Knaak. All rights reserved.
//
//

import Foundation
import CoreData


extension SizeSetMember {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SizeSetMember> {
        return NSFetchRequest<SizeSetMember>(entityName: "SizeSetMember")
    }

    @NSManaged public var height: NSNumber?
    @NSManaged public var suffix: String?
    @NSManaged public var width: NSNumber?
    @NSManaged public var owner: SizeSet?

}
