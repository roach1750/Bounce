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
            "placeName": BOUNCELOCATIONNAMEKEY,
            "placeLocation": BOUNCEPOSTGEOLOCATIONKEY,
            "placeBounceKey": BOUNCEKEY,
            "placeScore" : BOUNCESCOREKEY
        ]
    }
    
    
    

}
