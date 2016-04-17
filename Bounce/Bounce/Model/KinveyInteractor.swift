//
//  KinveyInteractor.swift
//  Bounce
//
//  Created by Andrew Roach on 4/11/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit

class KinveyInteractor: NSObject {
    
    
    //This uploads the image first, then calls the method below to upload the object
    func uploadPostImageThenObject(post: Post) {
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
        let collection = KCSCollection(fromString: BOUNCECLASSNAME, ofClass: Post.self)
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
        let store = KCSAppdataStore.storeWithOptions([ KCSStoreKeyCollectionName : BOUNCECLASSNAME, KCSStoreKeyCollectionTemplateClass : Post.self
            ])
        store.queryWithQuery(
            KCSQuery(),
            withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
                print("Fetched \(objectsOrNil.count) objects")
                if objectsOrNil.count > 0 {
                    for object in objectsOrNil{
                        
                        let newPost = Post()
                        newPost.postMessage = object[BOUNCECOMMENTKEY] as? String
                        newPost.postImageFileInfo = object[BOUNCEKINVEYIMAGEFILEIDKEY] as? String
                        newPost.postLocation = object[KCSEntityKeyGeolocation] as? CLLocation
                        newPost.postPlaceName = object[BOUNCELOCATIONNAMEKEY] as? String
//                        newPost.postScore = object[BOUNCESCOREKEY] as! Int
                        newPost.postShareSetting = object[BOUNCESHARESETTINGKEY] as? String
                        newPost.postUploaderFacebookUserID = object[BOUNCEPOSTUPLOADERFACEBOOKUSERID] as? String
                        newPost.postUploaderKinveyUserID = object[BOUNCEPOSTUPLOADERKINVEYUSERID] as? String
                        newPost.postUploaderKinveyUserName = object[BOUNCEPOSTUPLOADERKINVEYUSERNAME] as? String
                        
                        self.fetchImageForPost(newPost)
                        
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
                    
                    self.data!.append(post)
                    print("fetching")
                } else {
                    NSLog("Got an error: %@", error)
                }
            },
            progressBlock: { (objects, percentComplete) in
                print(percentComplete)
        })
        print("fetching done")
    }
}
