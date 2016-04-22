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
    
    var postImageDeleteButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
        configureTextview()
        configureLocationButton()
    }
    
    override func viewDidAppear(animated: Bool) {
        restoreDataIfApplicable()
    }
    override func viewWillAppear(animated: Bool) {
        configureLocationButton()
    }
    

    
    func restoreDataIfApplicable(){
        if Post.sharedInstance.postImageData != nil {
            let IC = ImageConfigurer()
            postImageView.image = IC.rotateImage90Degress(UIImage(data: Post.sharedInstance.postImageData!)!)
            addDeleteImageButton()

        }
        else {
            postImageView.image = UIImage(named: "cameraImage")
        }
        if Post.sharedInstance.postMessage != nil {
            postTextView.text = Post.sharedInstance.postMessage!
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
        Post.sharedInstance.postImageData = nil
        postImageView.image = UIImage(named: "cameraImage")
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        Post.sharedInstance.postImageData = nil
        Post.sharedInstance.postMessage = nil
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //Do I need to put a spinner here? or what happens if the person reloads?
    func configureLocationButton(){
        if let place = LocationFetcher.sharedInstance.selectedPlace {
            locationButton.setTitle(place.placeName, forState: UIControlState.Normal)
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
        
        let newPost = Post()
        
        //Message
        newPost.postMessage = postTextView.text
        
        //Image
        if let image = postImageView.image {
            newPost.postImageData = UIImagePNGRepresentation(image)
            newPost.postHasImage = true
        }
        
        //Place Name, Location and Key
        if let postPlace = LocationFetcher.sharedInstance.selectedPlace {
            newPost.postPlaceName = postPlace.placeName
            newPost.postLocation = postPlace.placeLocation
            newPost.postBounceKey = postPlace.placeName! + "," + String(postPlace.placeLocation?.coordinate.latitude) + "," + String(postPlace.placeLocation?.coordinate.longitude)
        }
        
        //Score
        newPost.postScore = 0
        
        //Share Setting
        newPost.postShareSetting = shareSetting
        
        
        //User's Properties
        newPost.postUploaderFacebookUserID = KCSUser.activeUser().getValueForAttribute("Facebook ID") as? String
        newPost.postUploaderKinveyUserName = KCSUser.activeUser().username
        newPost.postUploaderKinveyUserID = KCSUser.activeUser().userId
        
        
        let uploader = KinveyInteractor()
        uploader.uploadPost(newPost)
        
        Post.sharedInstance.postImageData = nil
        
        self.dismissViewControllerAnimated(true, completion: nil)
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
