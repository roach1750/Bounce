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
    
    override var description : String {
        return self.firstName + "," + self.lastName + "," + self.userID
    }
}
