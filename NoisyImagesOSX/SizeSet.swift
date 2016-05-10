//
//  SizeSet.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 5/8/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Foundation
import CoreData


class SizeSet: NSManagedObject {

    var sizes:Set<SizeSetMember>? {
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
