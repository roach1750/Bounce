//
//  PostVC.swift
//  Bounce
//
//  Created by Andrew Roach on 1/16/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit

class PostVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var locationButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }


    @IBAction func postButtonTapped(sender: UIBarButtonItem) {
        //Need to create post
    }

}
