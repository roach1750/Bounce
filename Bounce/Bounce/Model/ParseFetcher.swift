//
//  ParseFetcher.swift
//  Bounce
//
//  Created by Andrew Roach on 1/14/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import Parse

class ParseFetcher: NSObject {
    
    class var sharedInstance: LocationFetcher {
        struct Singleton {
            static let instance = LocationFetcher()
        }
        return Singleton.instance
    }
    
    
    func fetchData(){
        if let userLocation = LocationFetcher.sharedInstance.currentLocation {
            let query = PFQuery(className: BOUNCECLASSNAME)
            let lat = userLocation.coordinate.latitude
            let lng = userLocation.coordinate.longitude
            let userGeopoint = PFGeoPoint(latitude: lat, longitude: lng)
            query.whereKey(BOUNCELOCATIONGEOPOINTKEY, nearGeoPoint: userGeopoint, withinMiles: 300)
            query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                print(results)

                
            }
        }
    }

    
    
    
    
}
