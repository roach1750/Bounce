//
//  KinveyUploader.swift
//  Bounce
//
//  Created by Andrew Roach on 4/11/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import CoreData

class KinveyUploader: NSObject {
    
    class var sharedInstance: KinveyUploader {
        struct Singleton {
            static let instance = KinveyUploader()
        }
        return Singleton.instance
    }
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    
    
    func createPostThenUpload(message: String, image: NSData, shareSetting: String, selectedPlace: FourSquarePlace ) {
        
        // Create Entity
        let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: self.managedObjectContext)
        
        // Initialize Record
        let coreDataPost = Post(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)
        
        coreDataPost.postMessage = message
        coreDataPost.postImageData = image
        coreDataPost.postHasImage = true
        coreDataPost.postPlaceName = selectedPlace.name
        coreDataPost.postLocation = selectedPlace.location
        coreDataPost.postBounceKey = selectedPlace.name! + "," + String(selectedPlace.location!.coordinate.latitude) + "," + String(selectedPlace.location!.coordinate.longitude)
        coreDataPost.postScore = 0
        coreDataPost.postShareSetting = shareSetting
        coreDataPost.postUploaderFacebookUserID = KCSUser.activeUser().getValueForAttribute("Facebook ID") as? String
        coreDataPost.postUploaderKinveyUserName = KCSUser.activeUser().username
        coreDataPost.postUploaderKinveyUserID = KCSUser.activeUser().userId
        coreDataPost.postCreationDate = NSDate()
        
        uploadPostImageThenObject(coreDataPost)
        
        
    }
    
    
    
//    private func checkIfPlaceIsExistingForPost(post:Post) {
//        let store = KCSAppdataStore.storeWithOptions([ KCSStoreKeyCollectionName : BOUNCEPLACECLASSNAME, KCSStoreKeyCollectionTemplateClass : Place.self])
//        let query = KCSQuery(onField: BOUNCEKEY, withExactMatchForValue: post.postBounceKey)
//        store.queryWithQuery(query, withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
//            print("place query done")
//            if objectsOrNil.count == 0 {
//                print("Place for post is not existing, uploading place")
//                self.uploadPlaceForPost(post)
//            }
//            else {
//                print("Place for post is existing, uploading post")
//                self.uploadPostImageThenObject(post)
//            }
//            
//            },
//                             
//                             withProgressBlock: { (objects, percentComplete) in
//                                print("Query for existing Place: \(percentComplete * 100) %")
//                                
//        })
//    }
//    
//
//    private func uploadPlaceForPost(post:Post) {
//        
//        let placeToUpload = convertPostToPlace(post)
//        let collection = KCSCollection(fromString: BOUNCEPLACECLASSNAME, ofClass: Place.self)
//        let updateStore = KCSLinkedAppdataStore.storeWithOptions([KCSStoreKeyResource: collection])
//        updateStore.saveObject(
//            placeToUpload,
//            withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError?) -> Void in
//                if errorOrNil != nil {
//                    //save failed
//                    //                    print("Save failed, with error: %@", errorOrNil?.localizedFailureReason)
//                } else {
//                    //save was successful
//                    //                    print("Successfully saved Place (id='%@').", (objectsOrNil[0] as! NSObject).kinveyObjectId())
//                    self.uploadPostImageThenObject(post)
//                }
//            },
//            withProgressBlock: { (objects, percentComplete) in
//                //                print(percentComplete)
//        })
//    }
//    
//    
//    
//    private func convertPostToPlace(post: Post) -> Place {
//        print("Converting post to Place")
//        let entity = NSEntityDescription.entityForName("Place", inManagedObjectContext: self.managedObjectContext)
//        let placeToReturn = Place(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)
//        placeToReturn.placeName = post.postPlaceName
//        placeToReturn.placeLocation = post.postLocation
//        placeToReturn.placeScore = 0
//        placeToReturn.placeBounceKey = post.postBounceKey
//        print("Done post to Place")
//        
//        return placeToReturn
//    }
    
    
    
    //This uploads the image first, then calls the method below to upload the object
    private func uploadPostImageThenObject(post: Post) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        print("uploading Image for Post")
        NSNotificationCenter.defaultCenter().postNotificationName(BOUNCEIMAGEUPLOADBEGANNOTIFICATION, object: nil, userInfo: nil)
        if let PID = post.postImageData {
            KCSFileStore.uploadData(PID, options: nil, completionBlock: { (uploadInfo, error) in
                if let receivedUploadInfo = uploadInfo {
                    self.upLoadPostObject(receivedUploadInfo,post: post)
                    
                }
                NSNotificationCenter.defaultCenter().postNotificationName(BOUNCEIMAGEUPLOADCOMPLETENOTIFICATION, object: nil, userInfo: nil)
                }, progressBlock: { (objects, percentComplete) in
                    
                    let progressDictionary = ["progress" : percentComplete]
                    NSNotificationCenter.defaultCenter().postNotificationName(BOUNCEIMAGEUPLOADINPROGRESSNOTIFICATION, object: nil, userInfo: progressDictionary)
                    //                    print(percentComplete)
            })
        }
    }
    
    private func upLoadPostObject(imageInfo: KCSFile, post: Post) {
        
        post.postImageFileInfo = imageInfo.fileId
        let collection = KCSCollection(fromString: BOUNCEPOSTCLASSNAME, ofClass: Post.self)
        let updateStore = KCSLinkedAppdataStore.storeWithOptions([KCSStoreKeyResource: collection])
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

        updateStore.saveObject(
            post,
            withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
                if errorOrNil != nil {
                    //save failed
                    print("Save failed, with error: %@", errorOrNil.localizedFailureReason)
                } else {
                    //save was successful
                    
                    print("Successfully saved event (id='%@').", (objectsOrNil[0] as! NSObject).kinveyObjectId())
                }
                
            },
            withProgressBlock: { (objects, percentComplete) in
                //                print(percentComplete)
        })
    }
    
    
    
    
    
    
    
}
