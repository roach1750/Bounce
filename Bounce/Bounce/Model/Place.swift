//
//  Place.swift
//  
//
//  Created by Andrew Roach on 4/24/16.
//
//

import Foundation
import CoreData


class Place: NSObject {

// Insert code here to add functionality to your managed object subclass
    
    var distanceFromUser: Double?
    
    dynamic var placeLocation: CLLocation?
    dynamic var friendsOnlyAuthors: [String]?
    dynamic var everyoneAuthors: [String]?
    dynamic var placeName: String?
    dynamic var placeBounceKey: String?
    dynamic var placeScore: NSNumber?
    dynamic var entityId: String?

    
    override func hostToKinveyPropertyMapping() -> [AnyHashable: Any]! {
        return [
            "entityId" : KCSEntityKeyId, //the required _id field
            "placeName": BOUNCELOCATIONNAMEKEY,
            "placeLocation": BOUNCEPOSTGEOLOCATIONKEY,
//            "bounceKey": BOUNCEKEY,
            "placeScore" : BOUNCESCOREKEY,
            "friendsOnlyAuthors" : BOUNCEFRIENDSONLYAUTHORSKEY,
            "everyoneAuthors" : BOUNCEEVERYONEAUTHORSKEY,
        ]
    }
    
    
    
    
    override var description: String {
        get {
            return "entityId: \(entityId) \n" + "placeName: \(placeName) \n" + "placeLocation: \(placeLocation) \n" + "placeBounceKey: \(placeBounceKey) \n" + "placeScore: \(placeScore) \n" + "friendsOnlyAuthors: \(friendsOnlyAuthors) \n" + "everyoneAuthors: \(everyoneAuthors)"
        }
    }
    
    
    
    /// Below is kinvey core data methods, this may be useful for the future...don't delete for now
    
//    internal override static func kinveyObjectBuilderOptions() -> [NSObject : AnyObject]! {
//        return [
//            KCS_USE_DESIGNATED_INITIALIZER_MAPPING_KEY : true,
//            KCS_REFERENCE_MAP_KEY : [ "place" : Place.self ]
//        ]
//    }
//    
//    override func kinveyDesignatedInitializer(_ jsonDocument: [AnyHashable : Any]!) -> Any! {
    
//        let existingID = jsonDocument[KCSEntityKeyId] as? String
//        var obj: Place? = nil
//        let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
//        let entity = NSEntityDescription.entity(forEntityName: "Place", in: context)!
////        if existingID != nil {
////            let request: NSFetchRequest<Place> = NSFetchRequest(entityName: "Place")
////            request.entity = entity
////            let predicate = NSPredicate(format: "entityId = %@", existingID!)
////            request.predicate = predicate
////
////            
////            do {
////                let results = try context.executeFetchRequest(request)
////                if results.count > 0 {
////                    obj = results.first as? Place
////                }
////            } catch {
////                print("error fetching results")
////            }
////            
////       }
////        if obj == nil {
////            //fall back to creating a new if one if there is an error, or if it is new
////            obj = Place(entity: entity, insertIntoManagedObjectContext: nil)
////        }
//        return Place()
//    }
//    

}
