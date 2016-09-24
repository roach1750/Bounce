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
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    func createPostThenUpload(_ message: String, image: Data, shareSetting: String, selectedPlace: FourSquarePlace ) {
        // Create Entity
        let entity = NSEntityDescription.entity(forEntityName: "Post", in: self.managedObjectContext)
        // Initialize Record
        let coreDataPost = Post(entity: entity!, insertInto: self.managedObjectContext)
        coreDataPost.postMessage = message
        coreDataPost.postImageData = image
        coreDataPost.postHasImage = true
        coreDataPost.postPlaceName = selectedPlace.name
        coreDataPost.postLocation = selectedPlace.location
        coreDataPost.postBounceKey = selectedPlace.name! + "," + String(selectedPlace.location!.coordinate.latitude) + "," + String(selectedPlace.location!.coordinate.longitude)
        coreDataPost.postScore = 0
        coreDataPost.postShareSetting = shareSetting
        coreDataPost.postUploaderFacebookUserID = KCSUser.active().getValueForAttribute("Facebook ID") as? String
        coreDataPost.postUploaderKinveyUserName = KCSUser.active().username
        coreDataPost.postUploaderKinveyUserID = KCSUser.active().userId
        coreDataPost.postCreationDate = Date()
        coreDataPost.postReportedCount = 0
        coreDataPost.postExpired = NSNumber(value: false as Bool)
        uploadPostImageThenObject(coreDataPost)
    }
    
    //This uploads the image first, then calls the method below to upload the object
    fileprivate func uploadPostImageThenObject(_ post: Post) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        NotificationCenter.default.post(name: Notification.Name(rawValue: BOUNCEIMAGEUPLOADBEGANNOTIFICATION), object: nil, userInfo: nil)
        let metadata = KCSMetadata()
        metadata.setGloballyReadable(true)
        
        if let PID = post.postImageData {
            KCSFileStore.uploadData(PID as Data!, options: [KCSFileACL : metadata], completionBlock: { (uploadInfo, error) in
                if let receivedUploadInfo = uploadInfo {
                    self.upLoadPostObject(receivedUploadInfo,post: post)
                    
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: BOUNCEIMAGEUPLOADCOMPLETENOTIFICATION), object: nil, userInfo: nil)
                }, progressBlock: { (objects, percentComplete) in
                    
                    let progressDictionary = ["progress" : percentComplete]
                    NotificationCenter.default.post(name: Notification.Name(rawValue: BOUNCEIMAGEUPLOADINPROGRESSNOTIFICATION), object: nil, userInfo: progressDictionary)
                    //                    print(percentComplete)
            })
        }
    }
    
    fileprivate func upLoadPostObject(_ imageInfo: KCSFile, post: Post) {
        
        post.postImageFileInfo = imageInfo.fileId
        let collection = KCSCollection(from: BOUNCEPOSTCLASSNAME, of: Post.self)
        let updateStore = KCSLinkedAppdataStore.withOptions([KCSStoreKeyResource: collection])
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        _ = updateStore?.save(post, withCompletionBlock: { (objectsOrNil, error) in
            if error != nil {
                //save failed
                print("Uploading Object: Save failed, with error: %@", error)
            } else {
                //save was successful
                
                print("Successfully saved event (id='%@').", (objectsOrNil?[0] as! NSObject).kinveyObjectId())
            }
            
            }, withProgressBlock: nil)
        
        
        
    }

    func changeScoreForPost(_ post: Post, place: Place, increment: Int) {
        KCSCustomEndpoints.callEndpoint("incrementScore", params: ["increment":increment,"_id": post.postUniqueId!]) { (results, error) in
            if results != nil {
                print("Incremental Success")
                KinveyFetcher.sharedInstance.fetchUpdatedPostsForPlace(place)
            } else {
                print("Incremental Error: \(error)")
            }
        }
    }
    
    
    func reportPost(_ post:Post,reason:String) {
        let parameters = ["postID" : post.postUniqueId!, "reason" : reason, "userID" : KCSUser.active().userId]
        KCSCustomEndpoints.callEndpoint(
            "reportPost",
            params: parameters,
            completionBlock: { (results, error) in
                if results != nil {
                    print("Report Success")
                } else {
                    print("Report Error: \(error)")
                }
            }
        )
    }

    
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

