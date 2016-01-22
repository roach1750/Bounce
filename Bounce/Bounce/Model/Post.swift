//
//  Post.swift
//  Bounce
//
//  Created by Andrew Roach on 1/16/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import Parse
import Realm
import RealmSwift


class Post: Object {

    class var sharedInstance: Post {
        struct Singleton {
            static let instance = Post()
        }
        return Singleton.instance
    }
    
    var postMessage: String?
    var postImageData: NSData?
    var postPlace: Place?
    var postKey: String?
    var postPlaceName: String?
    
    
    func createPFObject(){
        //Create PFObject: 
        
        let object = PFObject(className:BOUNCECLASSNAME)
        
        //location
        let place = LocationFetcher.sharedInstance.selectedPlace
        let geopoint = PFGeoPoint(latitude: place!.latitude!, longitude: place!.longitude!)
        object[BOUNCELOCATIONGEOPOINTKEY] = geopoint
        
        //message
        if let comment = postMessage {
            object[BOUNCECOMMENTKEY] = comment
        }
        
        //image
        if let postImageData = postImageData {
            let imageFile = PFFile(name: "image.png", data: postImageData)
            object[BOUNCEIMAGEKEY] = imageFile
        }
        
        //place name
        object[BOUNCELOCATIONNAME] = postPlace!.name
        
        //Key
        postKey = ("\(String(place!.name!))" + "," + "\(String(place!.latitude!))" + "," + "\(String(place!.longitude!))"  )
        print(postKey)
        object[BOUNCELOCATIONIDENTIFIER] = postKey!
        
        object.saveInBackground()
        
        
    }
    

    
    
    func clearData(){
        postMessage = nil
        postImageData = nil
    }
    
    
    
    
    
}
