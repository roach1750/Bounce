//
//  KinveyInteractor.swift
//  Bounce
//
//  Created by Andrew Roach on 4/11/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit

class KinveyInteractor: NSObject {
    
    class var sharedInstance: KinveyInteractor {
        struct Singleton {
            static let instance = KinveyInteractor()
        }
        return Singleton.instance
    }
    
    
    
    func uploadPost(post:Post) {
        checkIfPlaceIsExistingForPost(post)
    }
    
    private func checkIfPlaceIsExistingForPost(post:Post) {
        let store = KCSAppdataStore.storeWithOptions([ KCSStoreKeyCollectionName : BOUNCEPLACECLASSNAME, KCSStoreKeyCollectionTemplateClass : Place.self])
        
        let query = KCSQuery(onField: BOUNCEKEY, withExactMatchForValue: post.postBounceKey)
        
        store.queryWithQuery(query, withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
            if objectsOrNil.count == 0 {
                self.uploadPlaceForPost(post)
                print("Place for post is not existing, uploading place")
            }
            else {
                self.uploadPostImageThenObject(post)
                print("Place for post is existing, uploading post")
            }
            
            },
                             
                             withProgressBlock: { (objects, percentComplete) in
        })
    }
    
    
    private func uploadPlaceForPost(post:Post) {
        
        let placeToUpload = convertPostToPlace(post)
        let collection = KCSCollection(fromString: BOUNCEPLACECLASSNAME, ofClass: Place.self)
        let updateStore = KCSLinkedAppdataStore.storeWithOptions([KCSStoreKeyResource: collection])
        updateStore.saveObject(
            placeToUpload,
            withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
                if errorOrNil != nil {
                    //save failed
                    print("Save failed, with error: %@", errorOrNil.localizedFailureReason)
                } else {
                    //save was successful
                    print("Successfully saved Place (id='%@').", (objectsOrNil[0] as! NSObject).kinveyObjectId())
                    self.uploadPostImageThenObject(post)
                }
            },
            withProgressBlock: { (objects, percentComplete) in
                print(percentComplete)
        })
    }
        
    
    
    private func convertPostToPlace(post: Post) -> Place {
        let placeToReturn = Place()
        placeToReturn.placeName = post.postPlaceName
        placeToReturn.placeLocation = post.postLocation
        placeToReturn.placeScore = 0
        placeToReturn.placeBounceKey = post.postBounceKey
        return placeToReturn
    }
    
    
    
    //This uploads the image first, then calls the method below to upload the object
    private func uploadPostImageThenObject(post: Post) {
        if let PID = post.postImageData {
            KCSFileStore.uploadData(PID, options: nil, completionBlock: { (uploadInfo, error) in
                if let receivedUploadInfo = uploadInfo {
                    self.upLoadPostObject(receivedUploadInfo,post: post)
                    
                }
                
                }, progressBlock: { (objects, percentComplete) in
                    print(percentComplete)
            })
        }
    }
    
    private func upLoadPostObject(imageInfo: KCSFile, post: Post) {
        
        post.postImageFileInfo = imageInfo.fileId
        let collection = KCSCollection(fromString: BOUNCEPOSTCLASSNAME, ofClass: Post.self)
        let updateStore = KCSLinkedAppdataStore.storeWithOptions([KCSStoreKeyResource: collection])
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
                print(percentComplete)
        })
    }
    
    
    
    var data: [Post]?
    
    func query() {
        
        data = [Post]()
        //Future: need to specifiy query type based on share settings and location
        
        let store = KCSAppdataStore.storeWithOptions([ KCSStoreKeyCollectionName : BOUNCEPOSTCLASSNAME, KCSStoreKeyCollectionTemplateClass : Post.self
            ])
        store.queryWithQuery(
            KCSQuery(),
            withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
                print("Fetched \(objectsOrNil.count) objects")
                if objectsOrNil.count > 0 {
                    for object in objectsOrNil{
                        let newPost = object as! Post
                        self.data!.append(newPost)
                        print(self.data)
                        NSNotificationCenter.defaultCenter().postNotificationName(BOUNCEANNOTATIONSREADYNOTIFICATION, object: nil)
                        
                    }
                }
            },
            withProgressBlock: { (objects, percentComplete) in
                
                
        })
    }
    
    
    func fetchImageForPost(post: Post) {
        
        KCSFileStore.downloadData(
            post.postImageFileInfo,
            completionBlock: { (downloadedResources: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    let file = downloadedResources[0] as! KCSFile
                    let fileData = file.data
                    post.postHasImage = true
                    post.postImageData = fileData
                    
                    print("fetched Image for post")
                } else {
                    NSLog("Got an error: %@", error)
                }
            },
            progressBlock: { (objects, percentComplete) in
                print("Image Download: \(percentComplete * 100)%")
        })
    }
}
