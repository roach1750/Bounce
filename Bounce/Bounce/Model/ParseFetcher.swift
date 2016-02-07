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

    
    func fetchData(){
        if let userLocation = LocationFetcher.sharedInstance.currentLocation {
            let query = PFQuery(className: BOUNCECLASSNAME)
            let lat = userLocation.coordinate.latitude
            let lng = userLocation.coordinate.longitude
            let userGeopoint = PFGeoPoint(latitude: lat, longitude: lng)
            query.whereKey(BOUNCELOCATIONGEOPOINTKEY, nearGeoPoint: userGeopoint, withinMiles: 300)
            query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                if results?.count > 0 {
                    print("There are \(results!.count) results")
                    let dm = DataModel()
                    dm.addNewDataToDataBase(results as [PFObject]!)
                
                
                }
                

            }
        }
    }

    
    func fetchScoreForPlace(place: Place) {
        PFCloud.callFunctionInBackground("totalScore", withParameters: ["key": place.key]) {
            (score, error) in
            if (error == nil) {
                print("new score is: \(score)")
                let dm = DataModel()
                dm.updateScoreForPlaceWithKeyAndScore(place.key, score: Int(score! as! Int))
            }
        }
    }
    
    
    
    
}
