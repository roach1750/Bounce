//
//  Post.swift
//  
//
//  Created by Andrew Roach on 4/24/16.
//
//

import Foundation
import CoreData


class Post: NSManagedObject {


    dynamic var postLocation: CLLocation?
    
    class func postWithPostInfo(_ post: Post, inManagedObjectContext context: NSManagedObjectContext) -> Post?
    {
        let request: NSFetchRequest<Post> = NSFetchRequest(entityName: "Post")
        request.predicate = NSPredicate(format: "postUniqueId = %@", post.postUniqueId!)
        
        if let existingPost = (try? context.fetch(request))?.first {
            return existingPost
        } else if let newPost = NSEntityDescription.insertNewObject(forEntityName: "Post", into: context) as? Post{
            newPost.postMessage = post.postMessage
            newPost.postImageFileInfo = post.postImageFileInfo
            newPost.postHasImage = post.postHasImage
            newPost.postLocation = post.postLocation
            newPost.postPlaceName = post.postPlaceName
            newPost.postScore = post.postScore
            newPost.postShareSetting = post.postShareSetting
            newPost.postBounceKey = post.postBounceKey
            newPost.postUploaderFacebookUserID = post.postUploaderFacebookUserID
            newPost.postUploaderKinveyUserID = post.postUploaderKinveyUserID
            newPost.postUploaderKinveyUserName = post.postUploaderKinveyUserName
            newPost.postCreationDate = post.postCreationDate
            newPost.postUniqueId = post.postUniqueId
            newPost.postReportedCount = post.postReportedCount
            newPost.postExpired = post.postExpired

        }
        return nil
    }
    

//    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
//        print("CoreData Object Initalized")
//        print(entity.propertiesByName["postUniqueId"])
//        
//        super.init(entity: entity, insertIntoManagedObjectContext: nil)
//    }
//
//    
    
    
    
    //Kinvey Stuff

    override func hostToKinveyPropertyMapping() -> [AnyHashable: Any]! {
        return [
            "postMessage" : BOUNCECOMMENTKEY,
            "postImageFileInfo" : BOUNCEKINVEYIMAGEFILEIDKEY,
            "postHasImage" : BOUNCEHASIMAGEKEY,
            "postLocation" : BOUNCEPOSTGEOLOCATIONKEY,
            "postPlaceName" : BOUNCELOCATIONNAMEKEY,
            "postScore" : BOUNCESCOREKEY,
            "postShareSetting" : BOUNCESHARESETTINGKEY,
            "postBounceKey" : BOUNCEKEY,
            "postUploaderFacebookUserID" : BOUNCEPOSTUPLOADERFACEBOOKUSERID,
            "postUploaderKinveyUserID" : BOUNCEPOSTUPLOADERKINVEYUSERID,
            "postUploaderKinveyUserName" : BOUNCEPOSTUPLOADERKINVEYUSERNAME,
            "postCreationDate" : BOUNCEPOSTCREATIONDATEKEY,
            "postReportedCount" :BOUNCEREPORTEDCOUNTKEY,
            "postExpired" : BOUNCEEXPIREDKEY,
            "postUniqueId" : KCSEntityKeyId, //the required _id field
        ]
    }
        
    internal override static func kinveyObjectBuilderOptions() -> [AnyHashable: Any]! {
        return [
            KCS_USE_DESIGNATED_INITIALIZER_MAPPING_KEY : true,
            KCS_REFERENCE_MAP_KEY : [ "post" : Post.self ]
        ]
    }
    
    override static func kinveyDesignatedInitializer(_ jsonDocument: [AnyHashable : Any]!) -> Any! {
        let existingID = jsonDocument[KCSEntityKeyId] as? String
        var obj: Post? = nil
        let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "Post", in: context)!
        if existingID != nil {
            let request: NSFetchRequest<Post> = NSFetchRequest(entityName: "Post")
            request.entity = entity
            let predicate = NSPredicate(format: "entityId = %@", existingID!)
            request.predicate = predicate
            
            
            do {
                let results = try context.fetch(request)
                if results.count > 0 {
                    obj = results.first!
                }
            } catch {
                print("error fetching results")
            }
            
        }
        if obj == nil {
            //fall back to creating a new if one if there is an error, or if it is new, DON'T SAVE TO MOC BECAUSE I'LL DO THE SAVING MY SELF IF I WANT TO SAVE IT,  NOT EVERY KINVEY OBJECT SHOULD BE SAVED!!!!
            obj = Post(entity: entity, insertInto: nil)
        }
        return obj
    }

    
    
    
    func clearData(){
        postMessage = nil
        postImageData = nil
    }
    
    
    
    
    
    
}
