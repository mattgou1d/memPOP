//  PersonInfoMO+CoreDataProperties.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Matthew Gould   on 2018-11-17.
//  Programmers:
//  Copyright © 2018 Iota Inc. All rights reserved.

//===============================================================
// Defines characterstics and attributes of PersonInfoMO entity
// used to store and save user's information and statistics
//===============================================================

import Foundation
import CoreData

extension PersonInfoMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonInfoMO> {
        return NSFetchRequest<PersonInfoMO>(entityName: "PersonInfoMO")
    }

    @NSManaged public var name: String?
    @NSManaged public var totalDistance: Int32
    @NSManaged public var contactName: String?
    @NSManaged public var foodNum: Int16
    @NSManaged public var funNum: Int16
    @NSManaged public var taskNum: Int16
    @NSManaged public var addHotspotNotifSetting: Int16
    @NSManaged public var activitiesNotifSetting: Int16
}
