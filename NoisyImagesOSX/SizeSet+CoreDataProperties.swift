//
//  SizeSet+CoreDataProperties.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 12/16/17.
//  Copyright © 2017 Cooper Knaak. All rights reserved.
//
//

import Foundation
import CoreData


extension SizeSet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SizeSet> {
        return NSFetchRequest<SizeSet>(entityName: "SizeSet")
    }

    @NSManaged public var name: String?
    @NSManaged public var members: NSSet?

}

// MARK: Generated accessors for members
extension SizeSet {

    @objc(addMembersObject:)
    @NSManaged public func addToMembers(_ value: SizeSetMember)

    @objc(removeMembersObject:)
    @NSManaged public func removeFromMembers(_ value: SizeSetMember)

    @objc(addMembers:)
    @NSManaged public func addToMembers(_ values: NSSet)

    @objc(removeMembers:)
    @NSManaged public func removeFromMembers(_ values: NSSet)

}
