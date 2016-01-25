//
//  Place.swift
//  Bounce
//
//  Created by Andrew Roach on 1/18/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class Place: Object {
    dynamic var name:String = "";
    dynamic var latitude:Double = 0;
    dynamic var longitude:Double = 0;
    
    var distanceFromUser: Double?
    var posts = List<Post>()
    var key: String?
    
    
//    override var description: String {
//        return("\(name!), key: \(key!), lat: \(latitude!), long: \(longitude!), distance from user: \(distanceFromUser!) ft)")
//    }
    

}
