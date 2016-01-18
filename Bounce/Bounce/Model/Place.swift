//
//  Place.swift
//  Bounce
//
//  Created by Andrew Roach on 1/18/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit

class Place: NSObject {
    var name: String?
    var latitude: Double?
    var longitude: Double?
    var distanceFromUser: Double?
    
    override var description: String {
        return("\(name!), lat: \(latitude!), long: \(longitude!), distance from user: \(distanceFromUser!) ft)")
    }
}
