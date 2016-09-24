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
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, id, picture.type(large)"]).start { (connection, result, error) -> Void in
            
            let resultObject = result as AnyObject
            let givenName = resultObject.object(forKey: "first_name") as! String
            let surname = resultObject.object(forKey: "last_name") as! String
            let userId = resultObject.object(forKey: "id") as! String

            let userName = givenName + "_" + surname + "_" + userId
            
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
                                self.uploadFacebookUserID(userId)
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
                let resultData = result as AnyObject
                let friendObjects = resultData["data"] as! [NSDictionary]
                for friendObject in friendObjects {
                    //                    let firstName = friendObject.objectForKey("first_name") as! String
                    //                    let lastName = friendObject.objectForKey("last_name") as! String
                    let userID = friendObject.object(forKey: "id") as! String
                    //                    print(firstName + " " + lastName + " " + userID)
                    friendIDs.append(userID)
                }
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
