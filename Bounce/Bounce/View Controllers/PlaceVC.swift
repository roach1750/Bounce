//
//  PlaceVC.swift
//  Bounce
//
//  Created by Andrew Roach on 1/26/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit

class PlaceVC: UIViewController {

    var place: Place? {
        didSet {
            self.title = place?.name
        }
    }
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
    }


    



}
