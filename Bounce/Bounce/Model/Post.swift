//
//  Post.swift
//  Bounce
//
//  Created by Andrew Roach on 1/16/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import Parse

class Post: NSObject {

    class var sharedInstance: Post {
        struct Singleton {
            static let instance = Post()
        }
        return Singleton.instance
    }
    
    var postMessage: String?
    var postImage: UIImage?
    var postPlace: Place?

    
    
    func createPFObject(){
        //Create PFObject: 
        
        let object = PFObject(className:BOUNCECLASSNAME)
        
        //location
        let place = LocationFetcher.sharedInstance.selectedPlace
        let geopoint = PFGeoPoint(latitude: place!.latitude!, longitude: place!.longitude!)
        object[BOUNCELOCATIONGEOPOINTKEY] = geopoint
        
        //message
        object[BOUNCECOMMENTKEY] = postMessage
        
        //image
        if let postImage = postImage {
            let imageData = UIImagePNGRepresentation(postImage)
            let imageFile = PFFile(name: "image.png", data: imageData!)
            object[BOUNCEIMAGEKEY] = imageFile
        }
        
        object.saveInBackground()
        
        
    }
    
    
    
    
    
    func clearData(){
        postMessage = nil
        postImage = nil
    }
    
    
    
    
    
}
