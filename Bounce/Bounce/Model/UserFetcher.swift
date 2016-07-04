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
            
            KCSUser.checkUsername(userName, withCompletionBlock: { (userName, alreadyTaken, error) in
                if alreadyTaken {
                    print("this user already exists...attempting to login")
                    KCSUser.loginWithUsername(
                        userName,
                        password: "bounce",
                        withCompletionBlock: { (user: KCSUser!, errorOrNil: NSError!, result: KCSUserActionResult) -> Void in
                            if errorOrNil == nil {
                                print("logged in with existing userName")
                                self.updateUserFriends()

                            } else {
                                print(errorOrNil.localizedDescription)
                            }
                        }
                    )
                }
                else {
                    print("creating a new kinvey user")
                    KCSUser.userWithUsername(
                        userName,
                        password: "bounce",
                        fieldsAndValues: [
                            "userReportedCount" : 0,
                            KCSUserAttributeGivenname : givenName,
                            KCSUserAttributeSurname : surname
                            ],
                        withCompletionBlock: { (user: KCSUser!, errorOrNil: NSError!, result: KCSUserActionResult) -> Void in
                            if errorOrNil == nil {
                                print("Created new user")
                                print(KCSUser.activeUser())
                                self.uploadFacebookUserID(userId)
                                self.updateUserFriends()
                            } else {
                                print(errorOrNil)
                            }
                        }
                    )
                }
                
            })
            

            
        }
        
    }
    
    func uploadFacebookUserID(id: String) {
        
        KCSUser.activeUser().setValue(id, forAttribute: "Facebook ID")
        KCSUser.activeUser().saveWithCompletionBlock({ (saveUser, error) in
            if error != nil {
                print(error)
            }
            else {
                print("User FB ID Uploaded")
            }
        })
    }
    
    
    func updateUserFriends(){
        let fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: ["fields": "id, first_name, last_name"])
        
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error == nil {
                var friendIDs = [String]()
                let friendObjects = result["data"] as! [NSDictionary]
                for friendObject in friendObjects {
//                    let firstName = friendObject.objectForKey("first_name") as! String
//                    let lastName = friendObject.objectForKey("last_name") as! String
                    let userID = friendObject.objectForKey("id") as! String
//                    print(firstName + " " + lastName + " " + userID)
                    friendIDs.append(userID)
                }
                
                KCSUser.activeUser().setValue(friendIDs, forAttribute: "Facebook Friends IDs")
                KCSUser.activeUser().saveWithCompletionBlock({ (saveUser, error) in
                    if error != nil {
                        print(error)
                    }
                    else {
                        print("user's friends updated on the server")
                        NSNotificationCenter.defaultCenter().postNotificationName(BOUNCEUSERLOGGEDIN, object: nil)
                    }
                })
                
            
            } else {
                
                print("Error Getting Friends \(error)");
                
            }
        }
    }
    

}
