//
//  UserFetcher.swift
//  Bounce
//
//  Created by Andrew Roach on 2/25/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class UserFetcher: NSObject {

    func createUser() {
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, id, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in
            
            
            let givenName = result.objectForKey("first_name") as! String
            let surname = result.objectForKey("last_name") as! String
            let userId = result.objectForKey("id") as! String
            
            let userName = givenName + "_" + surname + "_" + userId
            
            print(userName)
            

            
            KCSUser.userWithUsername(
                userName,
                password: "bounce",
                fieldsAndValues: nil,
                withCompletionBlock: { (user: KCSUser!, errorOrNil: NSError!, result: KCSUserActionResult) -> Void in
                    if errorOrNil == nil {
                        //user is created
                    } else {
                        print(errorOrNil)
                        //there was an error with the create
                    }
                }
            )
            
        }
        
    }
    
    func updateUserFriends(){
        let fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: ["fields": "id, first_name, last_name"])
        
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error == nil {
                let dm = DataModel()
                let friendObjects = result["data"] as! [NSDictionary]
                for friendObject in friendObjects {
                    let friend = Friend()
                    friend.firstName = friendObject.objectForKey("first_name") as! String
                    friend.lastName = friendObject.objectForKey("last_name") as! String
                    friend.userID = friendObject.objectForKey("id") as! String
//                    friendIDs.append(friend)
//                    dm.saveFriend(friend)
                }
                if let userAsFriend = self.addUserToUsersFriendsList() {
//                    dm.saveFriend(userAsFriend)
                }
                
            } else {
                
                print("Error Getting Friends \(error)");
                
            }
        }
    }
    
    func addUserToUsersFriendsList() -> Friend? {
//        let dm = DataModel()
//        if let user = dm.getUser() {
//            let friend = Friend()
//            friend.firstName = user.firstName
//            friend.lastName = user.lastName
//            friend.userID = user.userID
//            return friend
//        }
        return nil
    }

}
