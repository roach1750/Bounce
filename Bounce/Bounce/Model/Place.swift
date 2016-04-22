//
//  Place.swift
//  Bounce
//
//  Created by Andrew Roach on 1/18/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit

class Place: NSObject {
    
    dynamic var placeName:String?
    dynamic var placeLocation: CLLocation?
    
    var distanceFromUser: Double?
    var posts = [Post]()
    
    dynamic var placeBounceKey: String?
    dynamic var placeScore = 0




    override func hostToKinveyPropertyMapping() -> [NSObject : AnyObject]! {
        return [
            "placeName": BOUNCELOCATIONNAMEKEY,
            "placeLocation": BOUNCEPOSTGEOLOCATIONKEY,
            "placeBounceKey": BOUNCEKEY,
            "placeScore" : BOUNCESCOREKEY
        ]
    }


















}
