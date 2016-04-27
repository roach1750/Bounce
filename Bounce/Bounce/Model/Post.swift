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
            
            "postUniqueId" : KCSEntityKeyId, //the required _id field
        ]
    }
        
    
    func clearData(){
        postMessage = nil
        postImageData = nil
    }
    
    
    
    
    
    
}
