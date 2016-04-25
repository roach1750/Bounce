//
//  KinveyFetcher.swift
//  Bounce
//
//  Created by Andrew Roach on 4/21/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//


class KinveyFetcher: NSObject {
    
    class var sharedInstance: KinveyFetcher {
        struct Singleton {
            static let instance = KinveyFetcher()
        }
        return Singleton.instance
    }
    
    
    var postsData: [Post]?

    var allPlacesData: [Place]?
    
    func queryForAllPlaces() {
        allPlacesData = [Place]()
        
        let store = KCSAppdataStore.storeWithOptions([ KCSStoreKeyCollectionName : BOUNCEPLACECLASSNAME, KCSStoreKeyCollectionTemplateClass : Place.self
            ])
        
        store.queryWithQuery(
            KCSQuery(),
            withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
                print("Fetched \(objectsOrNil.count) Place objects")
                if objectsOrNil.count > 0 {
                    for object in objectsOrNil{
                        let newPlace = object as! Place
                        self.allPlacesData!.append(newPlace)
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName(BOUNCEANNOTATIONSREADYNOTIFICATION, object: nil)

                }
            },
            withProgressBlock: { (objects, percentComplete) in
        })


        
        
    }
    
    
    
    func fetchPostsForPlace(place: Place) {
        postsData = [Post]()
        
        let store = KCSAppdataStore.storeWithOptions([ KCSStoreKeyCollectionName : BOUNCEPOSTCLASSNAME, KCSStoreKeyCollectionTemplateClass : Post.self])
        
        let query = KCSQuery(onField: BOUNCEKEY, withExactMatchForValue: place.placeBounceKey)
        
        store.queryWithQuery(query, withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
            if objectsOrNil.count > 0 {
                for object in objectsOrNil{
                    let newPost = object as! Post
                    self.postsData!.append(newPost)
                }
                print("there are \(objectsOrNil.count) posts for this place")
                NSNotificationCenter.defaultCenter().postNotificationName(BOUNCETABLEDATAREADYNOTIFICATION, object: nil)
            
            }
            else {
                print(errorOrNil)
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
                    NSNotificationCenter.defaultCenter().postNotificationName(BOUNCETABLEDATAREADYNOTIFICATION, object: nil)

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
