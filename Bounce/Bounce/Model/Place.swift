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
    var name: String?
    var latitude: Double?
    var longitude: Double?
    var distanceFromUser: Double?
    var posts = List<Post>()
    var key: String?
    
    
//    override var description: String {
//        return("\(name!), key: \(key!), lat: \(latitude!), long: \(longitude!), distance from user: \(distanceFromUser!) ft)")
//    }
}
