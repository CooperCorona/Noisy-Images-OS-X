//
//  SizeSet+CoreDataProperties.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 5/8/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SizeSet {

    @NSManaged var name: String?
    @NSManaged var members: NSSet?

}
