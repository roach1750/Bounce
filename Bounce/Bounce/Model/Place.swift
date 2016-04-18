//
//  Place.swift
//  Bounce
//
//  Created by Andrew Roach on 1/18/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit

class Place: NSObject {
    
    dynamic var name:String = "";
    dynamic var latitude:Double = 0;
    dynamic var longitude:Double = 0;
    
    var distanceFromUser: Double?
    var posts = [Post]()
    dynamic var key: String = ""
    dynamic var score = 0

}
