//
//  SizeSet+CoreDataClass.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 12/16/17.
//  Copyright © 2017 Cooper Knaak. All rights reserved.
//
//

import Foundation
import CoreData


public class SizeSet: NSManagedObject {

    public var sizes:Set<SizeSetMember>? {
        get {
            if let members = self.members {
                return (members as! Set<SizeSetMember>)
            } else {
                return nil
            }
        }
        set {
            if let value = newValue {
                self.members = (value as NSSet)
            } else {
                self.members = nil
            }
        }
    }
    
}
