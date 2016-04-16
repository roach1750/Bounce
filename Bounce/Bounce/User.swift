//
//  User.swift
//  Bounce
//
//  Created by Andrew Roach on 2/16/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit

import FBSDKCoreKit
import FBSDKLoginKit


class User: NSObject {

    var firstName:String = ""
    var lastName:String = ""
    var userID:String = ""
    var friends: [String]?
    
    override var description : String {
        return self.firstName + "," + self.lastName + "," + self.userID
    }
}
