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
            let query = queryConfigurer()
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

    
    func queryConfigurer() -> PFQuery {
        let dm = DataModel()
        
        //Friend Only Query
        let friendIDS = dm.getFriendIDs()
        let friendOnlyQuery = PFQuery(className: BOUNCECLASSNAME)
        friendOnlyQuery.whereKey(BOUNCEUSERIDKEY, containedIn: friendIDS)
        friendOnlyQuery.whereKey(BOUNCESHARESETTING, equalTo: BOUNCEFRIENDSONLYSHARESETTING)
        
        //Everyone Query
        let everyoneQuery = PFQuery(className: BOUNCECLASSNAME)
        everyoneQuery.whereKey(BOUNCESHARESETTING, equalTo: BOUNCEEVERYONESHARESETTING)
        
        //Combine Query
        let query = PFQuery.orQueryWithSubqueries([friendOnlyQuery, everyoneQuery])
        
        return query
    }
    
    func fetchScoreForPlace(place: Place) {
        PFCloud.callFunctionInBackground("totalScore", withParameters: ["key": place.key]) {
            (score, error) in
            if (error == nil) {
                let dm = DataModel()
                dm.updateScoreForPlaceWithKeyAndScore(place.key, score: Int(score! as! Int))
            }
        }
    }
    
    
    func fetchPostForPlace(place: Place) {
        let query = PFQuery(className: BOUNCECLASSNAME)
        query.whereKey(BOUNCELOCATIONIDENTIFIER, equalTo: place.key)
        query.findObjectsInBackgroundWithBlock { (results, error) in
            if results?.count > 0 {
                print("newData Count is: \(results?.count)")
                let dm = DataModel()
                for PFObject in results! {
                    let post = dm.createPostFromPFObject(PFObject)
                    dm.checkIfPostIsExistingAndUpdateScore(post)
                }
            }
            else {
                print(error)
            }
        }
    }
    
    
    
}
