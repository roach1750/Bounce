//
//  Post+CoreDataProperties.swift
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

extension Post {

    @NSManaged var postMessage: String?
    @NSManaged var postPlaceName: String?
    @NSManaged var postImageData: Data?
    @NSManaged var postHasImage: NSNumber?
    @NSManaged var postExpired: NSNumber?

    @NSManaged var postLatitude: NSNumber?
    @NSManaged var postLongitude: NSNumber?
    @NSManaged var postScore: NSNumber?
    @NSManaged var postReportedCount: NSNumber?
    @NSManaged var postShareSetting: String?
    @NSManaged var postBounceKey: String?
    @NSManaged var postUploaderFacebookUserID: String?
    @NSManaged var postUploaderKinveyUserID: String?
    @NSManaged var postUploaderKinveyUserName: String?
    @NSManaged var postUniqueId: String?
    @NSManaged var postImageFileInfo: String?
    @NSManaged var postPlace: Place?
    @NSManaged var postCreationDate: Date?

    @NSManaged var entityId: String?

}
