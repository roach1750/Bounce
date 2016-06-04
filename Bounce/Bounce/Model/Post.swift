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

// Insert code here to add functionality to your managed object subclass

    dynamic var postLocation: CLLocation?


    override func hostToKinveyPropertyMapping() -> [NSObject : AnyObject]! {
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

            "postUniqueId" : KCSEntityKeyId, //the required _id field
        ]
    }
        
    internal override static func kinveyObjectBuilderOptions() -> [NSObject : AnyObject]! {
        return [
            KCS_USE_DESIGNATED_INITIALIZER_MAPPING_KEY : true,
            KCS_REFERENCE_MAP_KEY : [ "post" : Post.self ]
        ]
    }
    
    internal override static func kinveyDesignatedInitializer(jsonDocument: [NSObject : AnyObject]!) -> AnyObject! {
        let existingID = jsonDocument[KCSEntityKeyId] as? String
        var obj: Post? = nil
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context)!
        if existingID != nil {
            let request = NSFetchRequest()
            request.entity = entity
            let predicate = NSPredicate(format: "entityId = %@", existingID!)
            request.predicate = predicate
            
            
            do {
                let results = try context.executeFetchRequest(request)
                if results.count > 0 {
                    obj = results.first as? Post
                }
            } catch {
                print("error fetching results")
            }
            
        }
        if obj == nil {
            //fall back to creating a new if one if there is an error, or if it is new
            obj = Post(entity: entity, insertIntoManagedObjectContext: context)
        }
        return obj
    }

    
    
    
    
    func clearData(){
        postMessage = nil
        postImageData = nil
    }
    
    
    
    
    
    
}
