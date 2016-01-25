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
        
        for dataObject in data {
            let post = createPostFromPFObject(dataObject)
            //First check if we already have this post, if so return get out of this method
            if checkIfPostIsExisting(post) {
                return
            }
            if let existingPlace = fetchExistingPlaceFromRealmForPost(post) { //Returns place if there is one already, otherwise returns nil
                //The place exist...check to make sure place doesn't already contain post:
                if existingPlace.posts.indexOf(post) == nil {
                    addPostToExistingPlace(existingPlace, post: post)
                }
            }
            else {
                //Create new place and add post to it
                let newPlace = createNewPlaceFromPostAndAddPostToPlace(post)
                addPlaceToRealm(newPlace)
            }
            
        }
        
    }
    
    
    
    
    
    
    //MARK: - Parse Methods
    
    func createPostFromPFObject(object: PFObject) -> Post{
        let newPost = Post()
        newPost.postMessage = object[BOUNCECOMMENTKEY] as? String
        newPost.postKey = object[BOUNCELOCATIONIDENTIFIER] as? String
        newPost.postPlaceName = object[BOUNCELOCATIONNAME] as? String
        let postLocationGeoPoint = object[BOUNCELOCATIONGEOPOINTKEY] as? PFGeoPoint
        newPost.postLatitude = postLocationGeoPoint?.latitude
        newPost.postLongitude = postLocationGeoPoint?.longitude
        newPost.postID = object.objectId!
        return newPost
    }

    func createNewPlaceFromPostAndAddPostToPlace(post: Post) -> Place {
        let place = Place()
        place.name = post.postPlaceName
        place.latitude = post.postLatitude
        place.longitude = post.postLongitude
        place.posts = List<Post>()
        place.key = post.postKey
        place.posts.append(post)
        return place
    }
    
    //MARK: - Realm Methods
    
    //checks if there is an existing place in realm for this
    func fetchExistingPlaceFromRealmForPost(post: Post) -> Place?{
        let realm = try! Realm()
        let predicate = NSPredicate(format: "key = %@", post.postKey!)
        let searchResults = realm.objects(Place).filter(predicate)
        if searchResults.count > 0 {
            let place = searchResults[0]
            return place
        }
        else {
            return nil
        }
    }
    
    
    func checkIfPostIsExisting(post: Post) -> Bool {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "postID = %@", post.postID!)
        let searchResults = realm.objects(Post).filter(predicate)
        return searchResults.count > 0 ? true : false
    }
    
    
    func addPlaceToRealm(place:Place) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(place)
        }
    }
    
    func addPostToExistingPlace(place: Place, post: Post) {
        let realm = try! Realm()
        try! realm.write {
            place.posts.append(post)
        }
    }

    
    
    
}
