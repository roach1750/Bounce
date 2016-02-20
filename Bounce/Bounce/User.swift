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
    

    
    func createUser() {

        
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, id, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in
            self.firstName = result.objectForKey("first_name") as! String
            self.lastName = result.objectForKey("last_name") as! String
            self.userID = result.objectForKey("id") as! String
            print(self.userID)
            let dm = DataModel()
            dm.saveUser(self)
            self.updateUserFriends()
        }
        
    }
    
    func updateUserFriends(){
        
        let fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: ["fields": "id, first_name, last_name"])
        
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error == nil {
                let dm = DataModel()
                dm.deleteAllFriends()
                let friendIDs = List<Friend>()
                let friendObjects = result["data"] as! [NSDictionary]
                for friendObject in friendObjects {
                    let friend = Friend()
                    friend.firstName = friendObject.objectForKey("first_name") as! String
                    friend.lastName = friendObject.objectForKey("last_name") as! String
                    friend.userID = friendObject.objectForKey("id") as! String
                    friendIDs.append(friend)
                    dm.saveFriend(friend)
                }
                
            } else {
                
                print("Error Getting Friends \(error)");
                
            }
        }
    }
    

    

    
    
}
