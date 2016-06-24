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
    
    
    func configurePostQueryWithPlace(place:Place, addDate:Bool) -> KCSQuery {
        let mainQuery = KCSQuery(onField: BOUNCEKEY, withExactMatchForValue: place.placeBounceKey)
        
        if addDate {
            if let mostRecentPostInDBDate = dateOfMostRecentPostInDataBase() {
                //            print("Most Recent post's date in DB: \(mostRecentPostInDBDate)")
                let dateRangeQuery = KCSQuery(onField: BOUNCEPOSTCREATIONDATEKEY, usingConditional: KCSQueryConditional.KCSGreaterThan, forValue: mostRecentPostInDBDate)
                mainQuery.addQuery(dateRangeQuery)
                mainQuery.queryByJoiningQuery(dateRangeQuery, usingOperator: .KCSAnd)
            }
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
        let query = configurePostQueryWithPlace(place, addDate: true)
        store.queryWithQuery(query, withCompletionBlock: { (downloadedData: [AnyObject]!, errorOrNil: NSError!) -> Void in
            if let error = errorOrNil {
                print("Error from downloading posts data only: \(error)")
            }
            else {
                print("Fetch \(downloadedData.count) objects from Kinvey")
                self.handleDownloadedData(downloadedData as! [Post], place: place)
            }
            },
                             withProgressBlock: { (objects, percentComplete) in
        })
    }
    
    
    

    func handleDownloadedData(data:[Post], place:Place) {
        managedObjectContext.performBlockAndWait {
            for newPost in data  {
                //create new, unique post
                _ = Post.postWithPostInfo(newPost, inManagedObjectContext: self.managedObjectContext)
                self.fetchImageForPost(newPost)
            }
            do {
                try self.managedObjectContext.save()
                self.fetchDataFromDataBase(place)
            }
            catch let error {
                print(error)
            }
        }
    }
    
    func fetchDataFromDataBase(place:Place) {
        countCoreData()
        everyonePostData = [Post]()
        friendsOnlyPostData = [Post]()

        managedObjectContext.performBlockAndWait {
            let fetchRequest = NSFetchRequest(entityName: "Post")
            let sortDescriptor = NSSortDescriptor(
                key: "postCreationDate",
                ascending: false,
                selector: #selector(NSString.localizedStandardCompare(_:))
            )
            fetchRequest.sortDescriptors = [sortDescriptor]
            let placeKeyPredicate = NSPredicate(format: "postBounceKey = %@", place.placeBounceKey!)
            fetchRequest.predicate = placeKeyPredicate
            
            
            do {
                let queryResults = try self.managedObjectContext.executeFetchRequest(fetchRequest)
                for post in queryResults as! [Post] {
                    if post.postShareSetting == BOUNCEFRIENDSONLYSHARESETTING {
                        if !(self.friendsOnlyPostData?.contains(post))! {
                            self.friendsOnlyPostData?.append(post)
                            
                        }
                    }
                    if !(self.everyonePostData?.contains(post))! {
                        self.everyonePostData = queryResults as? [Post]
                    }
                }
                
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
    
    func countCoreData(){
        managedObjectContext.performBlock {
            let count = self.managedObjectContext.countForFetchRequest(NSFetchRequest(entityName:"Post"), error: nil)
            print("There are: \(count) post in the data base")
        }
    }
    
    
    //  THIS IS THE UPDATE SECTION!
    //
    // downlods all objects that are old
    //
    
    func fetchUpdatedPostsForPlace(place: Place) {

        let collection = KCSCollection(fromString: BOUNCEPOSTCLASSNAME, ofClass: Post.self)
        let store = KCSAppdataStore(collection: collection, options: nil)
        let query = configurePostQueryWithPlace(place, addDate: false)
        
        store.queryWithQuery(query, withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) in
            if errorOrNil == nil {
                print("Downloaded \(objectsOrNil.count) posts to update")
                self.saveUpdatedDataToCoreData(objectsOrNil as! [Post], place: place)
            } else {
                NSLog("error occurred: %@", errorOrNil)
            }
            
            }, withProgressBlock: nil)
    }
    
    func saveUpdatedDataToCoreData(data:[Post], place:Place) {
        
        let fetchRequest = NSFetchRequest(entityName: "Post")
        print(data.count)
        for post in data {
            let predicate = NSPredicate(format: "postUniqueId == %@", post.postUniqueId!)
            fetchRequest.predicate = predicate
            do {
                let fetchedEntities = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Post]
                if fetchedEntities.count > 1 {
                    print("Found \(fetchedEntities.count) post in the date base for this one post to update")
                }
                fetchedEntities.first?.postScore = post.postScore
                
            } catch {
            }
            
            do {
                try self.managedObjectContext.save()
            } catch {
            }
        }
        self.fetchDataFromDataBase(place)
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
