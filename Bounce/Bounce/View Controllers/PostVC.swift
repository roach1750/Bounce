//
//  PostVC.swift
//  Bounce
//
//  Created by Andrew Roach on 1/16/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import MBProgressHUD

class PostVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    var postImageDeleteButton: UIButton!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
        configureTextview()
        configureLocationButton()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostVC.updateProgressIndicator(_:)), name: BOUNCEIMAGEUPLOADINPROGRESSNOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostVC.showProgressIndicator), name: BOUNCEIMAGEUPLOADBEGANNOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostVC.removeProgressIndicator), name: BOUNCEIMAGEUPLOADCOMPLETENOTIFICATION, object: nil)
        postButton.enabled = false
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        restoreDataIfApplicable()
    }
    override func viewWillAppear(animated: Bool) {
        configureLocationButton()
    }
    
    var loadingNotification: MBProgressHUD = MBProgressHUD()
    
    
    func showProgressIndicator() {
        loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.labelText = "Uploading"
        loadingNotification.mode = MBProgressHUDMode.AnnularDeterminate
        loadingNotification.dimBackground = true
    }
    
    func updateProgressIndicator(notification: NSNotification) {
        if let info = notification.userInfo as? Dictionary<String,Double> {
            let percentComplete = info["progress"]!
            loadingNotification.progress = Float(percentComplete)
            print(percentComplete)            
        }
    }
    
    func removeProgressIndicator() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func restoreDataIfApplicable(){
        
        if appDelegate.tempPostImageData != nil {
            let IC = ImageConfigurer()
            postImageView.image = IC.rotateImage90Degress(UIImage(data: appDelegate.tempPostImageData!)!)
            addDeleteImageButton()
            postButton.enabled = true

        }
        else {
            postImageView.image = UIImage(named: "cameraImage")
        }
        if appDelegate.tempPostMessage != nil {
            postTextView.text = appDelegate.tempPostMessage!
        }
    }
    
    
    func addDeleteImageButton(){
        postImageDeleteButton = UIButton(frame: CGRect(x: 10, y: 10 + postImageView.frame.origin.y, width: 30, height: 30))
        postImageDeleteButton.setTitle("x", forState: .Normal)
        postImageDeleteButton.addTarget(self, action: #selector(PostVC.deleteImagePressed), forControlEvents: .TouchUpInside)
        view.addSubview(postImageDeleteButton)
        view.bringSubviewToFront(postImageDeleteButton)
    }
    
    func removeDeleteImageButton(){
        postImageDeleteButton.hidden = true
    }
    
    func deleteImagePressed(){
        removeDeleteImageButton()
        postButton.enabled = false
        appDelegate.tempPostImageData = nil
        
        postImageView.image = UIImage(named: "cameraImage")
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        postTextView.resignFirstResponder()
        appDelegate.tempPostImageData = nil
        appDelegate.tempPostMessage = nil
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //Do I need to put a spinner here? or what happens if the person reloads?
    func configureLocationButton(){
        if let place = LocationFetcher.sharedInstance.selectedPlace {
            locationButton.setTitle(place.name, forState: UIControlState.Normal)
        }
    }
    
    
    //MARK: Create Post:
    @IBAction func postButtonTapped(sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Select Who Can See This Bounce", message:nil, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        
        let friendsOnlyAction = UIAlertAction(title: "Friends Only", style: .Default) { (action) in
            self.createPost(BOUNCEFRIENDSONLYSHARESETTING)
        }
        let EveryoneAction = UIAlertAction(title: "Everyone", style: .Default) { (action) in
            self.createPost(BOUNCEEVERYONESHARESETTING)
        }
        
        alertController.addAction(friendsOnlyAction)
        alertController.addAction(EveryoneAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) {
            
        }
        
        
    }
    
    
    
    
    @IBAction func goToCameraView(sender: UITapGestureRecognizer) {
        let camera: PrivateResource = .Camera
        
        proposeToAccess(camera, agreed: {
            self.performSegueWithIdentifier("showCamera", sender: self)
            
            }, rejected: {
                print("no camera permissions")
        })
        
    }
    
    
    //MARK: Create Post
    
    func createPost(shareSetting: String){
        
        
        let uploader = KinveyUploader()
        
        if let image = postImageView.image, selectedPlace = LocationFetcher.sharedInstance.selectedPlace {
            
            let imageData = UIImagePNGRepresentation(image)
            
            uploader.createPostThenUpload(postTextView.text, image: imageData!, shareSetting: shareSetting, selectedPlace: selectedPlace)
        }
        
        appDelegate.tempPostImageData = nil
        
    }
    
    
    
    //MARK: Post Textview Stuff:
    func configureTextview(){
        postTextView.returnKeyType = UIReturnKeyType.Done
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            if textView.text == "" {
                textView.text = "Enter caption for post"
            }
            postTextView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "Enter caption for post" {
            textView.text = ""
        }
    }
    
    
    //MARK: Keyboard Animations
    func registerForKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostVC.keyboardWillChangeState(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    //WARNING: This is not perfect yet
    func keyboardWillChangeState(notification: NSNotification) {
        let keyboardBeginFrame = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue
        let keyboardEndFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
        //        print("Begin Frame: \(keyboardBeginFrame!)")
        //        print("End Frame: \(keyboardEndFrame!)")
        
        let keyboardHeight = keyboardEndFrame!.size.height
        let viewHeight = view.frame.size.height
        
        //The keyboard is about to show, we need to:
        // 1: Move postTextView up
        // 2: Scale the image
        // 3: Move the Image up
        if keyboardBeginFrame!.origin.y > keyboardEndFrame?.origin.y {
            let imageScaleValue = (viewHeight - keyboardHeight - postTextView.frame.size.height) / postImageView.frame.size.height
            let textTranslationValue = keyboardHeight - locationButton.frame.size.height
            let imageTranslationsValue = textTranslationValue / 2
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                var imageTransform = self.postImageView.transform
                imageTransform = CGAffineTransformTranslate(imageTransform, 0, -imageTranslationsValue)
                imageTransform = CGAffineTransformScale(imageTransform, imageScaleValue, imageScaleValue);
                
                var textTransform = self.postTextView.transform
                textTransform =  CGAffineTransformTranslate(textTransform, 0, -textTranslationValue);
                
                self.postImageView.transform = imageTransform
                self.postTextView.transform = textTransform
                
            })
        }
        else {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.postImageView.transform = CGAffineTransformIdentity
                self.postTextView.transform = CGAffineTransformIdentity
            })
        }
        
        
    }
    
    
    
    
    
}
