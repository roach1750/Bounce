//
//  DataModel.swift
//  Bounce
//
//  Created by Andrew Roach on 1/21/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import Parse
import Realm
import RealmSwift


class DataModel: NSObject {
    
    func addNewDataToDataBase(data: [PFObject]) {
        let realm = try! Realm()
        for (_, retrievedPost) in data.enumerate() {
            
            //Re-create the Post from the PFOBject
            
            let newPost = Post()
            newPost.postMessage = retrievedPost[BOUNCECOMMENTKEY] as? String
            newPost.postKey = retrievedPost[BOUNCELOCATIONIDENTIFIER] as? String
            newPost.postPlaceName = retrievedPost[BOUNCELOCATIONNAME] as? String
            let newPostGeoPoint = retrievedPost[BOUNCELOCATIONGEOPOINTKEY] as? PFGeoPoint
            
            //Check if a post with that key already exists
            let predicate = NSPredicate(format: "key = %@", newPost.postKey!)
            let place = realm.objects(Place).filter(predicate)
            if place.count != 0 {
                //existing place
                print("Existing place")
                print(place.count)
                //Add post to existing place - there should only be 1 place that matches the key of the post
                print(place)
                if place[0].posts.indexOf(newPost) == nil {
                    try! realm.write{
                        place[0].posts.append(newPost)
                    }
                }
                else {
                    return
                }
            }
            else {
                //create a new place
                let newPlace = Place()
                newPlace.name = newPost.postPlaceName
                newPlace.latitude = newPostGeoPoint?.latitude
                newPlace.longitude = newPostGeoPoint?.longitude
                newPlace.posts = List<Post>()
                newPlace.key = newPost.postKey
                newPlace.posts.append(newPost)
                try! realm.write{
                    realm.add(newPlace)
                    
                }
                
                
            }
        }
        
        
        
        
    }
    
    
    
    
    
    
}
