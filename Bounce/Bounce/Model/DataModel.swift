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
            if checkIfPostIsExistingAndUpdateScore(post) {
                print("This post is already in the database")
                //Update the post score: 
                
                continue
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
        NSNotificationCenter.defaultCenter().postNotificationName(BOUNCEANNOTATIONSREADYNOTIFICATION, object: nil, userInfo: nil)
        
    }
    
    
    
    
    
    
    //MARK: - Parse Methods
    
    func createPostFromPFObject(object: PFObject) -> Post{
        let newPost = Post()
        newPost.postMessage = object[BOUNCECOMMENTKEY] as? String
        newPost.postKey = object[BOUNCELOCATIONIDENTIFIER] as! String
        newPost.postPlaceName = object[BOUNCELOCATIONNAME] as! String
        let postLocationGeoPoint = object[BOUNCELOCATIONGEOPOINTKEY] as? PFGeoPoint
        newPost.postLatitude = (postLocationGeoPoint?.latitude)!
        newPost.postLongitude = (postLocationGeoPoint?.longitude)!
        newPost.postID = object.objectId!
        newPost.postCreationDate = object.createdAt!
        newPost.postScore = object[BOUNCESCOREKEY] as! Int
        if let _ = object[BOUNCEIMAGEKEY] {
            newPost.hasImage = true
        }
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
    
    func downloadImageForPost(post: Post)
    {
        let query = PFQuery(className: BOUNCECLASSNAME)
        query.whereKey("objectId", equalTo: post.postID)
        query.limit = 1
        query.selectKeys([BOUNCEIMAGEKEY])
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if let objects = objects {
                    let userImageFile = objects[0][BOUNCEIMAGEKEY] as! PFFile
                    userImageFile.getDataInBackgroundWithBlock {
                        (imageData: NSData?, error: NSError?) -> Void in
                        if error == nil {
                            if let imageData = imageData {
                                self.addPhotoToPost(post, photo: imageData)
                                NSNotificationCenter.defaultCenter().postNotificationName(BOUNCETABLEDATAREADYNOTIFICATION, object: nil, userInfo: nil)
                            }
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func incrementScoreForObject(post: Post, amount:Int) {
        
        let query = PFQuery(className: BOUNCECLASSNAME)
        query.whereKey("objectId", equalTo: post.postID)
        query.limit = 1
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if let results = objects {
                    let object = results[0]
                    [object .incrementKey(BOUNCESCOREKEY, byAmount: amount)]
                    object.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            // The score key has been incremented
                        } else {
                            // There was a problem, check error.description
                            print("ERROR UPDATING SCORE: \(error?.description)")
                        }
                    }
                } else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
        
        
        
    }
    
    
    //MARK: - Realm Methods
    
    //checks if there is an existing place in realm for this
    func fetchExistingPlaceFromRealmForPost(post: Post) -> Place?{
        let realm = try! Realm()
        let predicate = NSPredicate(format: "key = %@", post.postKey)
        let searchResults = realm.objects(Place).filter(predicate)
        if searchResults.count > 0 {
            let place = searchResults[0]
            return place
        }
        else {
            return nil
        }
    }
    
    // Check if the post is existing based on the post's ID, This property is set by parse
    func checkIfPostIsExistingAndUpdateScore(post: Post) -> Bool {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "postID = %@", post.postID)
        let searchResults = realm.objects(Post).filter(predicate)
        if searchResults.count > 0 {
            let existingPost = searchResults[0]
            let realm = try! Realm()
            try! realm.write {
                existingPost.postScore = post.postScore
            }
        }
        
        
        
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
    
    func fetchAllPlaces() -> Results<(Place)> {
        let realm = try! Realm()
        return realm.objects(Place)
    }
    
    func fetchPlaceWithKey(key: String) -> Place {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "key = %@", key)
        let placeResults = realm.objects(Place).filter(predicate)
        
        return placeResults[0]
    }
    
    func addPhotoToPost(post: Post, photo: NSData){
        let realm = try! Realm()
        try! realm.write {
            post.postImageData = photo
        }
    }

}
