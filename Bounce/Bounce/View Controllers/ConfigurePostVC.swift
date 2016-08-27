//
//  ConfigurePostVC.swift
//  Bounce
//
//  Created by Andrew Roach on 8/27/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit

class ConfigurePostVC: UIViewController {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postSharSettingSegmentedControl: UISegmentedControl!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    @IBAction func backButtonPressed(sender: UIButton) {
                dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func postButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func morePlacesButtonPressed(sender: UIButton) {
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
