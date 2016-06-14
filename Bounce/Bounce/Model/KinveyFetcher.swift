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
    
    
    var friendsOnlyPlaceData: [Place]?
    var everyonePlaceData: [Place]?
    
    
    
    func queryForAllPlaces() {
        
        friendsOnlyPlaceData = [Place]()
        everyonePlaceData = [Place]()
        
        let store = KCSAppdataStore.storeWithOptions([ KCSStoreKeyCollectionName : BOUNCEPLACECLASSNAME, KCSStoreKeyCollectionTemplateClass : Place.self
            ])
        let query = configurePlaceQuery()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        store.queryWithQuery(
            query,
            withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
                print("Fetched \(objectsOrNil.count) Place objects")
                self.sortPlaceData(objectsOrNil)
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
        let combineQuery = everyoneQuery.queryByJoiningQuery(friendsOnlyQuery, usingOperator: .KCSOr)
        return combineQuery
    }
    
    func sortPlaceData(data:[AnyObject]) {
        if data.count > 0 {
            for object in data{
                let newPlace = object as! Place
                let currentUserFBFriends = KCSUser.activeUser().getValueForAttribute("Facebook Friends IDs") as? [String]
                if let fOAS = newPlace.friendsOnlyAuthors {
                    for fOA in fOAS {
                        if currentUserFBFriends!.contains(fOA) {
                            friendsOnlyPlaceData?.append(newPlace)
                            break
                        }
                    }
                }
                everyonePlaceData?.append(newPlace)
                }
            NSNotificationCenter.defaultCenter().postNotificationName(BOUNCEANNOTATIONSREADYNOTIFICATION, object: nil)
        }
    }
    
    
    
    /////////////////////////////////////////////////POST SECTION////////////////////////////////////////////////
    
    func fetchPostsForPlace(place: Place) {
        self.fetchPostFromKinveyForPlace(place)
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
    // Downloads the post from Kinvey withImages
    //
    private func fetchPostFromKinveyForPlace(place: Place) {
        everyonePostData = everyonePostData == nil ? [Post]() : everyonePostData
        friendsOnlyPostData = friendsOnlyPostData == nil ? [Post]() : friendsOnlyPostData
        
        let store = KCSAppdataStore.storeWithOptions([ KCSStoreKeyCollectionName : BOUNCEPOSTCLASSNAME, KCSStoreKeyCollectionTemplateClass : Post.self])
        let query = configurePostQueryWithPlace(place)
        store.queryWithQuery(query, withCompletionBlock: { (downloadedData: [AnyObject]!, errorOrNil: NSError!) -> Void in
            
            if let error = errorOrNil {
                print("Error from downloading posts data only: \(error)")
            }
            else {
                print("Fetch \(downloadedData.count) objects from Kinvey")
                self.handleDownloadedData(downloadedData as! [Post])
            }
            },
                             withProgressBlock: { (objects, percentComplete) in
        })
    }
    
    
    
    func countCoreData(){
        managedObjectContext.performBlock {
            let count = self.managedObjectContext.countForFetchRequest(NSFetchRequest(entityName:"Post"), error: nil)
            print(count)
        }
    }
    
    func handleDownloadedData(data:[Post]) {
        managedObjectContext.performBlockAndWait {
            for newPost in data  {
                //create new, unique post
                _ = Post.postWithPostInfo(newPost, inManagedObjectContext: self.managedObjectContext)
                self.fetchImageForPost(newPost)
            }
            do {
                try self.managedObjectContext.save()
                self.fetchDataFromDataBase()
            }
            catch let error {
                print(error)
            }
        }
    }
    
    func fetchDataFromDataBase() {
        managedObjectContext.performBlockAndWait {
            let fetchRequest = NSFetchRequest(entityName: "Post")
            let sortDescriptor = NSSortDescriptor(
                key: "postCreationDate",
                ascending: true,
                selector: #selector(NSString.localizedStandardCompare(_:))
            )
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                let queryResults = try self.managedObjectContext.executeFetchRequest(fetchRequest)
                for post in queryResults as! [Post] {
                    if post.postShareSetting == BOUNCEFRIENDSONLYSHARESETTING {
                        self.friendsOnlyPostData?.append(post)
                    }
                }
                self.everyonePostData = queryResults as? [Post]
                
                NSNotificationCenter.defaultCenter().postNotificationName(BOUNCETABLEDATAREADYNOTIFICATION, object: nil)
            } catch let error {
                print(error)
            }
        }
    }
    
    func deleteAllPostFromCoreDatabase() {
        let fetchRequest = NSFetchRequest(entityName: "Post")
        do {
            let queryResults = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            print("Deleted \(queryResults.count) objects")
            for result in (queryResults as? [Post])! {
                managedObjectContext.deleteObject(result)
            }
            
        } catch let error {
            print(error)
        }
        
    }
    
    
    
    
    //
    // fetches the lastest score value from Kinvey for a post, this should be called as a loop? 
    //
    
    func fetchScoreForPost(post: Post) {
        fetchDataFromDataBase()
        sleep(1)
        var dataToUpload = [String]()
        print(everyonePostData?.count)
        for post in self.everyonePostData! {
            dataToUpload.append(post.postUniqueId!)
        }

        print(dataToUpload)
        KCSCustomEndpoints.callEndpoint(
            "fetchScoreForPost",
            params: ["_id": dataToUpload],
            completionBlock: { (results: AnyObject!, error: NSError!) -> Void in
                if results != nil {
                    
                    print("Refreshed Score Success results are: \(results)")
//                    self.updateScoreForPostInDataBase(post, score: results["postScore"] as! Int)
                } else {
                    print("Refreshed Score Error: \(error)")
                }
            }
        )
    }
    
    
    func updateScoreForPostInDataBase(post: Post, score:Int) {
        let predicate = NSPredicate(format: "postUniqueId == %@", post.postUniqueId!)
        
        let fetchRequest = NSFetchRequest(entityName: "Post")
        fetchRequest.predicate = predicate
        
        do {
            let fetchedEntities = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Post]
            fetchedEntities.first?.postScore = score
            NSNotificationCenter.defaultCenter().postNotificationName(BOUNCETABLEDATAREADYNOTIFICATION, object: nil)
            
        } catch {
        }
        
        do {
            try self.managedObjectContext.save()
        } catch {
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
