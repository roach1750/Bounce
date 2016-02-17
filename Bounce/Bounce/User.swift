//
//  User.swift
//  Bounce
//
//  Created by Andrew Roach on 2/16/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
import FBSDKCoreKit
import FBSDKLoginKit


class User: Object {

    dynamic var firstName:String = ""
    dynamic var lastName:String = ""
    dynamic var userID:String = ""
    var friends = List<User>()
    
    func createUser() {

        
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in
            self.firstName = (result.objectForKey("first_name") as? String)!
            self.lastName = (result.objectForKey("last_name") as? String)!
            
        }
        
    }
    
    func updateUserFriends(){
        
        let fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil)
        
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error == nil {
                
                print("Friends are : \(result)")
                
            } else {
                
                print("Error Getting Friends \(error)");
                
            }
        }
    }
    
    
}
