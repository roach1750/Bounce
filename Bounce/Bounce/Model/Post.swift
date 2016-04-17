//
//  Post.swift
//  Bounce
//
//  Created by Andrew Roach on 1/16/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit

class Post: NSObject {
    
    //Uploaded Properties
    dynamic var postMessage: String?
    
    dynamic var postImageData: NSData?
    dynamic var postHasImage: Bool = false
    
    dynamic var postLocation: CLLocation?
    dynamic var postPlaceName: String = ""
    
    dynamic var postScore = 0
    
    dynamic var postShareSetting: String = ""
    
    
    //FB User who uploaded post properties
    dynamic var postUploaderFacebookUserID: String = ""
    dynamic var postUploaderKinveyUserID: String = ""
    dynamic var postUploaderKinveyUserName: String = ""

    
    //Assigned Properties
    dynamic var postUniqueId: String? //Kinvey entity _id
    dynamic var postImageFileInfo: String?
    
    
    
    //Properties on device
    dynamic var postPlace: Place?

    
    class var sharedInstance: Post {
        struct Singleton {
            static let instance = Post()
        }
        return Singleton.instance
    }
    
    override func hostToKinveyPropertyMapping() -> [NSObject : AnyObject]! {
        return [
            
            
            
            "postMessage" : BOUNCECOMMENTKEY,
            "postImageFileInfo" : BOUNCEKINVEYIMAGEFILEIDKEY,
            "postHasImage" : BOUNCEHASIMAGEKEY,
            "postLocation" : BOUNCEPOSTGEOLOCATIONKEY,
            "postPlaceName" : BOUNCELOCATIONNAMEKEY,
            "postScore" : BOUNCESCOREKEY,
            "postShareSetting" : BOUNCESHARESETTINGKEY,
            
            
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
