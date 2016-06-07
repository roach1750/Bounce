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
    
    
    var friendsOnlyPostData: [Post]?
    var everyonePostData: [Post]?

    
    var allPlacesData: [Place]?
    
    
    func deleteAllPostFromCoreDatabase() {
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Post", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entityDescription
        
        do {
            let result = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            print("Core Data Deleted \(result.count) posts")
            for object in result {
                let newPost = object as! Post
                managedObjectContext.deleteObject(newPost)
            }
                        
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }

    }
    
    
    func queryForAllPlaces() {
        
        allPlacesData = [Place]()
        let store = KCSAppdataStore.storeWithOptions([ KCSStoreKeyCollectionName : BOUNCEPLACECLASSNAME, KCSStoreKeyCollectionTemplateClass : Place.self
            ])
        let query = configurePlaceQuery()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        store.queryWithQuery(
            query,
            withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
                print("Fetched \(objectsOrNil.count) Place objects")
                if objectsOrNil.count > 0 {
                    for object in objectsOrNil{
                        let newPlace = object as! Place
                        self.allPlacesData!.append(newPlace)
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName(BOUNCEANNOTATIONSREADYNOTIFICATION, object: nil)
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false;

            },
            withProgressBlock: { (objects, percentComplete) in
        })
    }
    
    //
    // This method will download a place if either of the following are true:
    // 1. There is any data in the everyone authors array
    // 2. The users or a friend's facebook ID is in the friends only authors array
    // These two are combine with an OR
    //
    func configurePlaceQuery() -> KCSQuery {
        //Everyone Query
        let everyoneQuery = KCSQuery(onField: BOUNCEPLACEEVERYONEAUTHORS, usingConditional: .KCSNotEqual, forValue: [])
        //Friends Only Query
        let facebookFriendIDs =  KCSUser.activeUser().getValueForAttribute("Facebook Friends IDs") as! [String]
        let friendsOnlyQuery = KCSQuery(onField: BOUNCEPLACEFRIENDONLYAUTHORS, usingConditional: .KCSIn, forValue: facebookFriendIDs)
        //combine and return
        return everyoneQuery.queryByJoiningQuery(friendsOnlyQuery, usingOperator: .KCSOr)
    }
    

    
/////////////////////////////////////////////////POST SECTION////////////////////////////////////////////////
    
    func fetchPostsForPlace(place: Place) {
        self.fetchPostFromKinveyForPlace(place)
    }
    
    //
    // Downloads the post from Kinvey withImages
    //
    private func fetchPostFromKinveyForPlace(place: Place) {
        if everyonePostData == nil {
            everyonePostData = [Post]()
        }
        if friendsOnlyPostData == nil {
            friendsOnlyPostData = [Post]()
        }
        self.fetchPostFromCoreDataForPlace(place)
        
        let store = KCSAppdataStore.storeWithOptions([ KCSStoreKeyCollectionName : BOUNCEPOSTCLASSNAME, KCSStoreKeyCollectionTemplateClass : Post.self])
        let query = configurePostQueryWithPlace(place)
        
        store.queryWithQuery(query, withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
            if let downloadedData = objectsOrNil {
                print("Kinvey Downloaded \(downloadedData.count) posts")
                for object in downloadedData{
                    let newPost = object as! Post
                    if newPost.postShareSetting == BOUNCEFRIENDSONLYSHARESETTING {
                        self.friendsOnlyPostData?.append(newPost)
                    }
                    self.everyonePostData?.append(newPost)
                    self.savePostToCoreDataWithoutImage(newPost)
                    self.fetchImageForPost(newPost)
                }
            }
            else {
                if let error = errorOrNil {
                    print("Error from downloading posts data only: \(error)")
                }
            }

            },
                             
                             withProgressBlock: { (objects, percentComplete) in
        })
    }
    
    func configurePostQueryWithPlace(place:Place) -> KCSQuery {
        let mainQuery = KCSQuery(onField: BOUNCEKEY, withExactMatchForValue: place.placeBounceKey)
        
        if let mostRecentPostInDBDate = dateOfMostRecentPostInDataBase() {
//            print("Most Recent post's date in DB: \(mostRecentPostInDBDate)")
            let dateRangeQuery = KCSQuery(onField: BOUNCEPOSTCREATIONDATEKEY, usingConditional: KCSQueryConditional.KCSGreaterThan, forValue: mostRecentPostInDBDate)
            mainQuery.addQuery(dateRangeQuery)
            mainQuery.queryByJoiningQuery(dateRangeQuery, usingOperator: .KCSAnd)
        }
        
        //TODO: need to add location to main query
        
        //Get a post from anyone who has the setting set to everyone
        let everyoneQuery = KCSQuery(onField: BOUNCESHARESETTINGKEY, withExactMatchForValue: BOUNCEEVERYONESHARESETTING)
        
        
        //If the share setting is to friends only, make sure this person is a friend
        let friendsOnlyQuery = KCSQuery(onField: BOUNCESHARESETTINGKEY, withExactMatchForValue: BOUNCEFRIENDSONLYSHARESETTING)
        let facebookFriendIDs =  KCSUser.activeUser().getValueForAttribute("Facebook Friends IDs") as! [String]
        let matchingFriendsQuery = KCSQuery(onField: BOUNCEPOSTUPLOADERFACEBOOKUSERID, usingConditional: .KCSIn, forValue: facebookFriendIDs)
        friendsOnlyQuery.addQuery(matchingFriendsQuery)
        
        
        let combineEveryoneQuery = everyoneQuery.queryByJoiningQuery(mainQuery, usingOperator: .KCSAnd)
        let combineFriendsQuery = friendsOnlyQuery.queryByJoiningQuery(mainQuery, usingOperator: .KCSAnd)

        let queryToReturn = combineFriendsQuery.queryByJoiningQuery(combineEveryoneQuery, usingOperator: .KCSOr)
    
        return queryToReturn
    
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
                return dateToReturn
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        print("There are no recent Post in Core Data")
        return nil
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
            print("Core Data Fetched \(result.count) posts")
            for object in result {
                let newPost = object as! Post
                if !(self.everyonePostData?.contains(newPost))! {
                    self.everyonePostData!.append(newPost)
                }
                if !(self.friendsOnlyPostData?.contains(newPost))! && newPost.postShareSetting! == BOUNCEFRIENDSONLYSHARESETTING {
                    self.friendsOnlyPostData!.append(newPost)

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
        if friendsOnlyPostData?.count > 0 {
            self.friendsOnlyPostData!.sortInPlace({ $0.postCreationDate!.compare($1.postCreationDate!) == NSComparisonResult.OrderedDescending })
        }
        if everyonePostData?.count > 0 {
            self.everyonePostData!.sortInPlace({ $0.postCreationDate!.compare($1.postCreationDate!) == NSComparisonResult.OrderedDescending })
        }
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
                        print("Refreshed Score Success")
                    } else {
                        print("Refreshed Score Error: \(error)")
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
                    print("Error from fetching post image \(error)")
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
