//
//  KinveyFetcher.swift
//  Bounce
//
//  Created by Andrew Roach on 4/21/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import CoreData
import FBSDKCoreKit
import FBSDKLoginKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class KinveyFetcher: NSObject {
    
    class var sharedInstance: KinveyFetcher {
        struct Singleton {
            static let instance = KinveyFetcher()
        }
        return Singleton.instance
    }
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    
    var friendsOnlyPostData: [Post]?
    var everyonePostData: [Post]?
    
    
    var friendsOnlyPlaceData: [Place]?
    var everyonePlaceData: [Place]?
    
    var topPlaceImageData = [String : Data]()
    
    
    func queryForAllPlaces() {
        
        friendsOnlyPlaceData = [Place]()
        everyonePlaceData = [Place]()
        
        let store = KCSAppdataStore.withOptions([ KCSStoreKeyCollectionName : BOUNCEPLACECLASSNAME, KCSStoreKeyCollectionTemplateClass : Place.self
            ])
        let query = configurePlaceQuery()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        _ = store?.query(
            withQuery: query,
            withCompletionBlock: { (objectsOrNil, errorOrNil) in
                if let objects = objectsOrNil {
                    print("Fetched \(objects.count) Place objects")
                    self.sortPlaceData(objects as [AnyObject])
                }

                UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                
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
        let everyoneQuery = KCSQuery(onField: BOUNCEPLACEEVERYONEAUTHORS, using: .kcsNotEqual, forValue: nil)
        //Friends Only Query
        if FBSDKAccessToken.current() != nil && KCSUser.active() != nil {
            let facebookFriendIDs =  KCSUser.active().getValueForAttribute("Facebook Friends IDs") as! [String]
            let friendsOnlyQuery = KCSQuery(onField: BOUNCEPLACEFRIENDONLYAUTHORS, using: .kcsIn, forValue: facebookFriendIDs as NSObject!)
            let combineQuery = everyoneQuery?.joiningQuery(friendsOnlyQuery, usingOperator: .kcsOr)
            return combineQuery!
        }
        else {
            return everyoneQuery!
        }

        //combine and return

    }
    
    func sortPlaceData(_ data:[AnyObject]) {
        if data.count > 0 {
            for object in data{
                let newPlace = object as! Place
                let currentUserFBFriends = KCSUser.active().getValueForAttribute("Facebook Friends IDs") as? [String]
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
            NotificationCenter.default.post(name: Notification.Name(rawValue: BOUNCEANNOTATIONSREADYNOTIFICATION), object: nil)
        }
    }
    
    
    
    /////////////////////////////////////////////////POST SECTION////////////////////////////////////////////////
    
    func fetchPostsForPlace(_ place: Place) {
        self.fetchPostFromKinveyForPlace(place)
    }
    
    
    func configurePostQueryWithPlace(_ place:Place, addDate:Bool) -> KCSQuery {
        let mainQuery = KCSQuery(onField: BOUNCEKEY, withExactMatchForValue: place.placeBounceKey as NSObject!)
        
        if addDate {
            if let mostRecentPostInDBDate = dateOfMostRecentPostInDataBase() {
                //            print("Most Recent post's date in DB: \(mostRecentPostInDBDate)")
                let dateRangeQuery = KCSQuery(onField: BOUNCEPOSTCREATIONDATEKEY, using: KCSQueryConditional.kcsGreaterThan, forValue: mostRecentPostInDBDate as NSObject!)
                mainQuery?.addQuery(dateRangeQuery)
                mainQuery?.joiningQuery(dateRangeQuery, usingOperator: .kcsAnd)
            }
        }
        
        //TODO: need to add location to main query
        
        //Get a post from anyone who has the setting set to everyone
        let everyoneQuery = KCSQuery(onField: BOUNCESHARESETTINGKEY, withExactMatchForValue: BOUNCEEVERYONESHARESETTING as NSObject!)
        let combineEveryoneQuery = everyoneQuery?.joiningQuery(mainQuery, usingOperator: .kcsAnd)

        
        if FBSDKAccessToken.current() != nil && KCSUser.active() != nil {
            //If the share setting is to friends only, make sure this person is a friend
            let friendsOnlyQuery = KCSQuery(onField: BOUNCESHARESETTINGKEY, withExactMatchForValue: BOUNCEFRIENDSONLYSHARESETTING as NSObject!)
            let facebookFriendIDs =  KCSUser.active().getValueForAttribute("Facebook Friends IDs") as! [String]
            let matchingFriendsQuery = KCSQuery(onField: BOUNCEPOSTUPLOADERFACEBOOKUSERID, using: .kcsIn, forValue: facebookFriendIDs as NSObject!)
            friendsOnlyQuery?.addQuery(matchingFriendsQuery)
            let combineFriendsQuery = friendsOnlyQuery?.joiningQuery(mainQuery, usingOperator: .kcsAnd)
            let queryToReturn = combineFriendsQuery?.joiningQuery(combineEveryoneQuery, usingOperator: .kcsOr)
            return queryToReturn!
        }
        else {
            return combineEveryoneQuery!
        }
        
        
        

    }
    
    //
    // Fetch the date of the most recent post in the data base in order to decide what needs to be update from Kinvey
    //
    func dateOfMostRecentPostInDataBase() -> Date? {
        let fetchRequest: NSFetchRequest<Post> = NSFetchRequest()
        let entityDescription = NSEntityDescription.entity(forEntityName: "Post", in: self.managedObjectContext)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "postCreationDate", ascending: false)]
        fetchRequest.fetchLimit = 1
        fetchRequest.entity = entityDescription
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest) 
            if result.count > 0 {
                let dateToReturn = result[0].postCreationDate
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
    fileprivate func fetchPostFromKinveyForPlace(_ place: Place) {
        everyonePostData = everyonePostData == nil ? [Post]() : everyonePostData
        friendsOnlyPostData = friendsOnlyPostData == nil ? [Post]() : friendsOnlyPostData
        
        let store = KCSAppdataStore.withOptions([ KCSStoreKeyCollectionName : BOUNCEPOSTCLASSNAME, KCSStoreKeyCollectionTemplateClass : Post.self])
        let query = configurePostQueryWithPlace(place, addDate: true)
        _ = store?.query(withQuery: query, withCompletionBlock: { (downloadedData, errorOrNil) in
            if let error = errorOrNil {
                print("Error from downloading posts data only: \(error)")
            }
            else {
                print("Fetch \(downloadedData?.count) objects from Kinvey")
                self.handleDownloadedData(downloadedData as! [Post], place: place)
            }
            },
                             withProgressBlock: { (objects, percentComplete) in
        })
    }
    
    
    

    func handleDownloadedData(_ data:[Post], place:Place) {
        managedObjectContext.performAndWait {
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
    
    func fetchDataFromDataBase(_ place:Place) {
        countCoreData()
        everyonePostData = [Post]()
        friendsOnlyPostData = [Post]()

        managedObjectContext.performAndWait {
            let fetchRequest: NSFetchRequest<Post> = NSFetchRequest(entityName: "Post")
            let sortDescriptor = NSSortDescriptor(
                key: "postCreationDate",
                ascending: false,
                selector: #selector(NSString.localizedStandardCompare(_:))
            )
            fetchRequest.sortDescriptors = [sortDescriptor]
            let placeKeyPredicate = NSPredicate(format: "postBounceKey = %@", place.placeBounceKey!)
            fetchRequest.predicate = placeKeyPredicate
            
            
            do {
                let queryResults = try self.managedObjectContext.fetch(fetchRequest)
                for post in queryResults {
                    if post.postShareSetting == BOUNCEFRIENDSONLYSHARESETTING {
                        if !(self.friendsOnlyPostData?.contains(post))! {
                            self.friendsOnlyPostData?.append(post)
                            
                        }
                    }
                    if !(self.everyonePostData?.contains(post))! {
                        self.everyonePostData = queryResults
                    }
                }
                print("reloading from fetched database data")
                NotificationCenter.default.post(name: Notification.Name(rawValue: BOUNCETABLEDATAREADYNOTIFICATION), object: nil)
            } catch let error {
                print(error)
            }
        }
    }
    
    func deleteAllPostFromCoreDatabase() {
        let fetchRequest: NSFetchRequest<Post> = NSFetchRequest(entityName: "Post")
        do {
            let queryResults = try self.managedObjectContext.fetch(fetchRequest)
            print("Deleted \(queryResults.count) objects")
            for result in queryResults {
                managedObjectContext.delete(result)
            }
            
        } catch let error {
            print(error)
        }
    }
    
    func countCoreData(){
        managedObjectContext.perform {
            //let count = self.managedObjectContext.countForFetchRequest(NSFetchRequest(entityName:"Post"), error: nil)
            //print("There are: \(count) post in the data base")
        }
    }
    
    
    //  THIS IS THE UPDATE SECTION!
    //
    // downlods all objects that are old
    //
    
    func fetchUpdatedPostsForPlace(_ place: Place) {

        let collection = KCSCollection(from: BOUNCEPOSTCLASSNAME, of: Post.self)
        let store = KCSAppdataStore(collection: collection, options: nil)
        let query = configurePostQueryWithPlace(place, addDate: false)
        
        _ = store?.query(withQuery: query, withCompletionBlock: { (objectsOrNil, errorOrNil) in
            if errorOrNil == nil {
                print("Downloaded \(objectsOrNil?.count) posts to update")
                self.saveUpdatedDataToCoreData(objectsOrNil as! [Post], place: place)
            } else {
                print("error occurred: %@", errorOrNil)
            }
            
            }, withProgressBlock: nil)
    }
    
    func saveUpdatedDataToCoreData(_ data:[Post], place:Place) {
        
        let fetchRequest: NSFetchRequest<Post> = NSFetchRequest(entityName: "Post")
        print(data.count)
        for post in data {
            let predicate = NSPredicate(format: "postUniqueId == %@", post.postUniqueId!)
            fetchRequest.predicate = predicate
            do {
                let fetchedEntities = try self.managedObjectContext.fetch(fetchRequest)
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
    
    
    func fetchImageForPost(_ post: Post) {
        
        KCSFileStore.downloadData(
            post.postImageFileInfo,
            completionBlock: { (downloadedResources, error) in
                if error == nil {
                    let file = downloadedResources?[0] as! KCSFile
                    let fileData = file.data
                    post.postHasImage = true
                    post.postImageData = fileData
                    NotificationCenter.default.post(name: Notification.Name(rawValue: BOUNCETABLEDATAREADYNOTIFICATION), object: nil)
                    self.saveImageToCoreDataForPost(post)
                    print("fetched Image for post with message: \(post.postMessage!)")
                } else {
                    print("Error from fetching post image \(error)")
                }
            },
            progressBlock: { (objects, percentComplete) in
                //                print("Image Download: \(percentComplete * 100)%")
        })
    }
    
    func saveImageToCoreDataForPost(_ post: Post) {
        let predicate = NSPredicate(format: "postUniqueId == %@", post.postUniqueId!)
        
        let fetchRequest: NSFetchRequest<Post> = NSFetchRequest(entityName: "Post")
        fetchRequest.predicate = predicate
        
        do {
            let fetchedEntities = try self.managedObjectContext.fetch(fetchRequest)
            fetchedEntities.first?.postHasImage = post.postHasImage
            fetchedEntities.first?.postImageData = post.postImageData
            
        } catch {
        }
        
        do {
            try self.managedObjectContext.save()
        } catch {
        }
    }
    
    // 1. query kinvey for the top post for that place
    // 2. check if this post is already in core database 
    // 3. get the image from the data base or download the image from kinvey
    
    func downloadTopImageForPlace(_ place: Place) {
        downloadTopPostForPlace(place)
    }
    
    fileprivate func downloadTopPostForPlace(_ place: Place) {
        let query = configurePostQueryWithPlace(place, addDate: false)
        let dataSort = KCSQuerySortModifier(field: "score", in: KCSSortDirection.descending)
        query.addSortModifier(dataSort)
        query.limitModifer = KCSQueryLimitModifier(limit: 1)
        
        let store = KCSAppdataStore.withOptions([ KCSStoreKeyCollectionName : BOUNCEPOSTCLASSNAME, KCSStoreKeyCollectionTemplateClass : Post.self])
        _ = store?.query(withQuery: query, withCompletionBlock: { (downloadedData, errorOrNil) in
            if let error = errorOrNil {
                print("Error from downloading posts data only: \(error)")
            }
            else {
                if let topPost = downloadedData?[0] as? Post {
                    print("fetched top place")
                    self.fetchImageForTopPost(topPost, place: place)
                }
            }
            },
                             withProgressBlock: { (objects, percentComplete) in
        })
    }
    
    fileprivate func fetchImageForTopPost(_ post: Post, place: Place) {
        KCSFileStore.downloadData(
            post.postImageFileInfo,
            completionBlock: { (downloadedResources, error) in
                if error == nil {
                    print("fetched top place Image")

                    let file = downloadedResources?[0] as! KCSFile
                    self.topPlaceImageData[place.entityId!] = file.data
                    NotificationCenter.default.post(name: Notification.Name(rawValue: BOUNCETOPIMAGEDOWNLOADEDNOTIFICATION), object: nil)
                    } else {
                    print("Error from fetching place top image \(error)")
                }
            },
            progressBlock: { (objects, percentComplete) in
//                print(percentComplete * 100)
        })

    }
    
    
    
}
