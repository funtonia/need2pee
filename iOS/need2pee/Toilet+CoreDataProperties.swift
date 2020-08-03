//
//  Toilet+CoreDataProperties.swift
//  need2pee
//
//  Created by Schlaue Füchse on 29.03.16.
//  Copyright © 2016 Schlaue Füchse. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Toilet {

    @NSManaged var name: String?
    @NSManaged var descr: String?
    @NSManaged var free: NSNumber?
    @NSManaged var barrierFree: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var latitude: NSNumber?

}
