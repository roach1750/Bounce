//
//  Place.swift
//  
//
//  Created by Andrew Roach on 4/24/16.
//
//

import Foundation
import CoreData


class Place: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    var distanceFromUser: Double?
    dynamic var placeLocation: CLLocation?


    
    override func hostToKinveyPropertyMapping() -> [NSObject : AnyObject]! {
        return [
            "entityId" : KCSEntityKeyId, //the required _id field
            "placeName": BOUNCELOCATIONNAMEKEY,
            "placeLocation": BOUNCEPOSTGEOLOCATIONKEY,
            "placeBounceKey": BOUNCEKEY,
            "placeScore" : BOUNCESCOREKEY
        ]
    }
    
    internal override static func kinveyObjectBuilderOptions() -> [NSObject : AnyObject]! {
        return [
            KCS_USE_DESIGNATED_INITIALIZER_MAPPING_KEY : true,
            KCS_REFERENCE_MAP_KEY : [ "place" : Place.self ]
        ]
    }
    
    internal override static func kinveyDesignatedInitializer(jsonDocument: [NSObject : AnyObject]!) -> AnyObject! {
        let existingID = jsonDocument[KCSEntityKeyId] as? String
        var obj: Place? = nil
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let entity = NSEntityDescription.entityForName("Place", inManagedObjectContext: context)!
        if existingID != nil {
            let request = NSFetchRequest()
            request.entity = entity
            let predicate = NSPredicate(format: "entityId = %@", existingID!)
            request.predicate = predicate

            
            do {
                let results = try context.executeFetchRequest(request)
                if results.count > 0 {
                    obj = results.first as? Place
                }
            } catch {
                print("error fetching results")
            }
            
        }
        if obj == nil {
            //fall back to creating a new if one if there is an error, or if it is new
            obj = Place(entity: entity, insertIntoManagedObjectContext: context)
        }
        return obj
    }
    

}
