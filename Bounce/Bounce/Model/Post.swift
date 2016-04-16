//
//  Post.swift
//  Bounce
//
//  Created by Andrew Roach on 1/16/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit

class Post: NSObject {
    
    dynamic var postMessage: String?
    dynamic var postImageData: NSData?
    dynamic var postPlace: Place?
    dynamic var postKey: String = ""
    dynamic var postID: String = ""
    dynamic var postPlaceName: String = ""
    dynamic var postLatitude: Double = 0
    dynamic var postLongitude: Double = 0
    dynamic var hasImage: Bool = false
    dynamic var postCreationDate: NSDate = NSDate()
    dynamic var postScore = 0
    dynamic var postShareSetting: String = ""
    dynamic var postUserID: String = ""
    dynamic var postEntityId: String? //Kinvey entity _id
    dynamic var postImageFileInfo: String?
    
    class var sharedInstance: Post {
        struct Singleton {
            static let instance = Post()
        }
        return Singleton.instance
    }
    
    override func hostToKinveyPropertyMapping() -> [NSObject : AnyObject]! {
        return [
            BOUNCEKINVEYID : KCSEntityKeyId, //the required _id field
            BOUNCECOMMENTKEY : "postMessage",
            BOUNCEIMAGEKEY : "postImageData",
            BOUNCEKEY : "postKey",
            BOUNCEID : "postID",
            BOUNCELOCATIONNAME : "postPlaceName",
            BOUNCEPOSTGEOLOCATION : "PostLocation",
            BOUNCESHARESETTING : "postShareSetting",
            BOUNCEUSERIDKEY : "postUserID",
            BOUNCEKINVEYIMAGEFILEID : "postImageFileInfo"
        ]
    }
    
    func clearData(){
        postMessage = nil
        postImageData = nil
    }
    
    
    
    
    
}
