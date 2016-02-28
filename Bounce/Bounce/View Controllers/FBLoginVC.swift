//
//  FBLoginVC.swift
//  Bounce
//
//  Created by Andrew Roach on 2/15/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import RealmSwift
import Realm

class FBLoginVC: UIViewController, FBSDKLoginButtonDelegate {

    
    @IBOutlet weak var profilePictureView: FBSDKProfilePictureView!
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = ""
        if FBSDKAccessToken.currentAccessToken() == nil {
            print("Not Login")
            
        }
        else {
            print("Already Logged in")
            //user is already logged in, check if the user has any new friends on bounce
            let userFetcher = UserFetcher()
            userFetcher.updateUserFriends()
        }

        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.center = self.view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        self.continueButton.setTitle("Continue", forState: .Normal)
    }

    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        print("fetching user")
        let userFetcher = UserFetcher()
        userFetcher.createUser()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
        let dm = DataModel()
        dm.deleteUser()

    }
    
    
    
    
    
    
    

}
