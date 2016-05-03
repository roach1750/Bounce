//
//  KinveyFetcher.swift
//  Bounce
//
//  Created by Andrew Roach on 4/21/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import CoreData

class KinveyFetcher: NSObject {
    
    class var sharedInstance: KinveyFetcher {
        struct Singleton {
            static let instance = KinveyFetcher()
        }
        return Singleton.instance
    }
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    var postsData: [Post]?
    
    var allPlacesData: [Place]?
    
    func queryForAllPlaces() {
        allPlacesData = [Place]()
        dateOfMostRecentPostInDataBase()
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
    
    //
    // Downloads the post from Kinvey withImages
    //
    func fetchPostsForPlace(place: Place) {
        postsData = [Post]()
        
        let store = KCSAppdataStore.storeWithOptions([ KCSStoreKeyCollectionName : BOUNCEPOSTCLASSNAME, KCSStoreKeyCollectionTemplateClass : Post.self])
        
        let query = KCSQuery(onField: BOUNCEKEY, withExactMatchForValue: place.placeBounceKey)
        
        store.queryWithQuery(query, withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
            if objectsOrNil.count > 0 {
                for object in objectsOrNil{
                    let newPost = object as! Post
                    self.postsData!.append(newPost)
                    self.savePostToCoreDataWithoutImage(newPost)
                }
                self.fetchAllPostFromCoreDataBase()
//                print("there are \(objectsOrNil.count) posts for this place")
                NSNotificationCenter.defaultCenter().postNotificationName(BOUNCETABLEDATAREADYNOTIFICATION, object: nil)
                
            }
            else {
                print(errorOrNil)
            }
            
            },
                             
                             withProgressBlock: { (objects, percentComplete) in
        })
    }
    
    //
    // Saves a post to core data
    //
    func savePostToCoreDataWithoutImage(post:Post) {
        do {
            try post.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }
    }
    
    
    
    //
    // Fetch the date of the most recent post in the data base in order to decide what needs to be update from Kinvey
    //
    func dateOfMostRecentPostInDataBase() {
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Post", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "postCreationDate", ascending: false)]
        fetchRequest.fetchLimit = 1
        fetchRequest.entity = entityDescription
        do {
            let result = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Post]
            let dateToReturn = result![0].postCreationDate
            print(dateToReturn);
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }

    }
    
    
    
    
    //
    // Fetch all post from from core data
    //
    func fetchAllPostFromCoreDataBase() -> [Post]?{
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Post", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entityDescription
        
        do {
            let result = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            print(result.count)
            print(result)
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return nil
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
