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
        let store = KCSAppdataStore.storeWithOptions([ KCSStoreKeyCollectionName : BOUNCEPLACECLASSNAME, KCSStoreKeyCollectionTemplateClass : Place.self
            ])
//        let query = configurePlaceQuery()
        store.queryWithQuery(
            KCSQuery(),
            withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
                print("Fetched \(objectsOrNil.count) Place objects")
                if objectsOrNil.count > 0 {
                    for object in objectsOrNil{
                        let newPlace = object as! Place
                        print(newPlace)
                        self.allPlacesData!.append(newPlace)
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName(BOUNCEANNOTATIONSREADYNOTIFICATION, object: nil)
                }
            },
            withProgressBlock: { (objects, percentComplete) in
        })
    }
    
//    func configurePlaceQuery() -> KCSQuery {
//        
//        //Friends Only Query
//        let facebookFriendIDs =  KCSUser.activeUser().getValueForAttribute("Facebook Friends IDs") as! [String]
//        let friendsOnlyQuery = KCSQuery(onField: BOUNCEPOSTUPLOADERFACEBOOKUSERID, usingConditional: .KCSIn, forValue: facebookFriendIDs)
//        
//        //Everyone Query
//        let everyoneQuery = KCSQuery(onField: BOUNCESHARESETTINGKEY, withExactMatchForValue: BOUNCEEVERYONESHARESETTING)
//        
//        everyoneQuery.addQuery(friendsOnlyQuery)
//        
//        return everyoneQuery
//    }
//    

    
/////////////////////////////////////////////////POST SECTION////////////////////////////////////////////////
    
    func fetchPostsForPlace(place: Place) {
        self.fetchPostFromKinveyForPlace(place)
    }
    
    //
    // Downloads the post from Kinvey withImages
    //
    private func fetchPostFromKinveyForPlace(place: Place) {
        postsData = [Post]()
        let store = KCSAppdataStore.storeWithOptions([ KCSStoreKeyCollectionName : BOUNCEPOSTCLASSNAME, KCSStoreKeyCollectionTemplateClass : Post.self])
        print(place)
        let mainQuery = KCSQuery(onField: BOUNCEKEY, withExactMatchForValue: place.placeBounceKey)
        if let mostRecentPostInDBDate = dateOfMostRecentPostInDataBase() {
            let dateRangeQuery = KCSQuery(onField: BOUNCEPOSTCREATIONDATEKEY, usingConditional: KCSQueryConditional.KCSGreaterThan, forValue: mostRecentPostInDBDate)
            mainQuery.addQuery(dateRangeQuery)
        }
        
        store.queryWithQuery(mainQuery, withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
            print("Kinvey Downloaded \(objectsOrNil.count) posts")
            if objectsOrNil.count > 0 {
                for object in objectsOrNil{
                    let newPost = object as! Post
                    self.postsData!.append(newPost)
                    self.savePostToCoreDataWithoutImage(newPost)
                    self.fetchImageForPost(newPost)
                }
            }
            else {
                if let error = errorOrNil {
                    print(error)
                }
            }
            self.fetchPostFromCoreDataForPlace(place)

            },
                             
                             withProgressBlock: { (objects, percentComplete) in
        })
    }
    
    
    
    //
    // Fetches all post stored in core data for a place
    //
    private func fetchPostFromCoreDataForPlace(place: Place) {
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Post", inManagedObjectContext: self.managedObjectContext)
        let predicate = NSPredicate(format: "postBounceKey == %@", place.placeBounceKey!)
        fetchRequest.predicate = predicate
        fetchRequest.entity = entityDescription
        
        do {
            let result = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            print("Core Data Fetched\(result.count) posts")
            for object in result {
                let newPost = object as! Post
                if !(self.postsData?.contains(newPost))! {

                    self.postsData!.append(newPost)
                }
            }
            sortData()
            
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    //Sorts the post by most recent then sends notification that they're ready to be displayed
    
    private func sortData() {
        self.postsData!.sortInPlace({ $0.postCreationDate!.compare($1.postCreationDate!) == NSComparisonResult.OrderedDescending })

        NSNotificationCenter.defaultCenter().postNotificationName(BOUNCETABLEDATAREADYNOTIFICATION, object: nil)

    }
    
    
    //
    // fetches the lastest score value from Kinvey for a post
    //
    
    func fetchScoreForPost(post: Post) {
            KCSCustomEndpoints.callEndpoint(
                "fetchScoreForPost",
                params: ["_id": post.postUniqueId!],
                completionBlock: { (results: AnyObject!, error: NSError!) -> Void in
                    if results != nil {
                        print("Incremental Success")
                    } else {
                        print("Incremental Error: \(error)")
                    }
                }
            )
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
    func dateOfMostRecentPostInDataBase() -> NSDate? {
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Post", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "postCreationDate", ascending: false)]
        fetchRequest.fetchLimit = 1
        fetchRequest.entity = entityDescription
        do {
            let result = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Post]
            if result?.count > 0 {
                let dateToReturn = result![0].postCreationDate
                print("Most Recent Post in Core Data was created at: \(dateToReturn)")
                return dateToReturn
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        print("There are no recent Post in Core Data")
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
                    self.saveImageToCoreDataForPost(post)
                    print("fetched Image for post")
                } else {
                    NSLog("Got an error: %@", error)
                }
            },
            progressBlock: { (objects, percentComplete) in
//                print("Image Download: \(percentComplete * 100)%")
        })
    }
    
    func saveImageToCoreDataForPost(post: Post) {
        let predicate = NSPredicate(format: "postUniqueId == %@", post.postUniqueId!)
        
        let fetchRequest = NSFetchRequest(entityName: "Post")
        fetchRequest.predicate = predicate
        
        do {
            let fetchedEntities = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Post]
            fetchedEntities.first?.postHasImage = post.postHasImage
            fetchedEntities.first?.postImageData = post.postImageData
            

        } catch {
        }
        
        do {
            try self.managedObjectContext.save()
        } catch {
        }
    }
}
