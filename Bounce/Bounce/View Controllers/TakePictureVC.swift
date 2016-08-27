//
//  TakePictureVC.swift
//  Bounce
//
//  Created by Andrew Roach on 8/24/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit

class TakePictureVC: UIViewController {

    
    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var denyPictureButton: UIButton!
    @IBOutlet weak var acceptPictureButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        denyPictureButton.hidden = true
        acceptPictureButton.hidden = true
    }

    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func takePictureButtonPressed(sender: AnyObject) {
        takePictureButton.hidden = true
        denyPictureButton.hidden = false
        acceptPictureButton.hidden = false
        
    }
    
    @IBAction func acceptPictureButtonPressed(sender: UIButton) {
    }
    
    
    @IBAction func denyPictureButtonPressed(sender: UIButton) {
        takePictureButton.hidden = false
        denyPictureButton.hidden = true
        acceptPictureButton.hidden = true
    }
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
