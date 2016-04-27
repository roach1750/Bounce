//
//  Place+CoreDataProperties.swift
//  
//
//  Created by Andrew Roach on 4/24/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Place {

    @NSManaged var placeName: String?
    @NSManaged var placeLatitude: NSNumber?
    @NSManaged var placeLongitude: NSNumber?
    @NSManaged var placeBounceKey: String?
    @NSManaged var placeScore: NSNumber?
    @NSManaged var posts: NSOrderedSet?
    @NSManaged var entityId: String?


}
