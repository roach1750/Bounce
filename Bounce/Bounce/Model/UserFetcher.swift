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
import SwiftyJSON


class UserFetcher: NSObject {

    func createUser() {
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, id, picture.type(large)"]).start { (connection, result, error) -> Void in
            
            
            let resultsJSON = JSON(result).dictionaryValue
            
            let givenName = resultsJSON["first_name"]?.rawString()
            let surname = resultsJSON["last_name"]?.rawString()
            let userId = resultsJSON["id"]?.rawString()

            let userName = givenName! + "_" + surname! + "_" + userId!
            
            KCSUser.checkUsername(userName, withCompletionBlock: { (userName, alreadyTaken, error) in
                if alreadyTaken {
                    print("this user already exists...attempting to login")
                    
                    KCSUser.login(withUsername: userName, password: "bounce", withCompletionBlock: { (user, error, resultAction) in
                        if user != nil {
                            print("logged in with existing userName")
                            self.updateUserFriends()
                            
                        } else if let error = error as? NSError {
                            print(error.localizedDescription)
                        }
                    })
                }
                else {
                    print("creating a new kinvey user")
                    
                    KCSUser.user(withUsername: userName, password: "bounce", fieldsAndValues: [
                        "userReportedCount" : 0,
                        KCSUserAttributeGivenname : givenName,
                        KCSUserAttributeSurname : surname],
                        
                        withCompletionBlock: { (user, error, resultAction) in
                            if error == nil {
                                print("Created new user")
                                print(KCSUser.active())
                                self.uploadFacebookUserID(userId!)
                                self.updateUserFriends()
                            } else {
                                print(error)
                            }
                    })
                    }
            })
        }
        
    }
    
    func uploadFacebookUserID(_ id: String) {
        
        KCSUser.active().setValue(id, forAttribute: "Facebook ID")
        KCSUser.active().save(completionBlock: { (saveUser, error) in
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
        

        _ = fbRequest?.start(completionHandler: { (connection, result, error) in
            if error == nil {
                var friendIDs = [String]()
                
                let resultsJSON = JSON(result).dictionaryValue

                for friendObject in resultsJSON["data"]! {

                    let userID = friendObject.1["id"].rawString()
                    friendIDs.append(userID!)
                }
                print(friendIDs)
                
                KCSUser.active().setValue(friendIDs, forAttribute: "Facebook Friends IDs")
                KCSUser.active().save(completionBlock: { (saveUser, error) in
                    if error != nil {
                        print(error)
                    }
                    else {
                        print("user's friends updated on the server")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: BOUNCEUSERLOGGEDIN), object: nil)
                    }
                })
            }
            else {
                print("Error Getting Friends \(error)");
            }
        })
    }

}
