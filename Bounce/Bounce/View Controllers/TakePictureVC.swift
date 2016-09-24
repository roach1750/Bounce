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
        denyPictureButton.isHidden = true
        acceptPictureButton.isHidden = true
    }

    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func takePictureButtonPressed(_ sender: AnyObject) {
        takePictureButton.isHidden = true
        denyPictureButton.isHidden = false
        acceptPictureButton.isHidden = false
        
    }
    
    @IBAction func acceptPictureButtonPressed(_ sender: UIButton) {
    }
    
    
    @IBAction func denyPictureButtonPressed(_ sender: UIButton) {
        takePictureButton.isHidden = false
        denyPictureButton.isHidden = true
        acceptPictureButton.isHidden = true
    }
    
    
    
    override var prefersStatusBarHidden : Bool {
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
