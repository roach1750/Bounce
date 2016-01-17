//
//  Post.swift
//  Bounce
//
//  Created by Andrew Roach on 1/16/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit

class Post: NSObject {

    class var sharedInstance: Post {
        struct Singleton {
            static let instance = Post()
        }
        return Singleton.instance
    }
    
    var postMessage: String?
    var postImage: UIImage?
    
    func clearData(){
        postMessage = nil
        postImage = nil
    }
    
    
    
}
