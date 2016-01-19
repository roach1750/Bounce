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
        registerForKeyboardNotifications()
        configureTextview()
        configureLocationButton()
    }
    
    override func viewDidAppear(animated: Bool) {
        restoreDataIfApplicable()

    }
    
    func restoreDataIfApplicable(){
        if Post.sharedInstance.postImage != nil {
            postImageView.image = Post.sharedInstance.postImage!
        }
        if Post.sharedInstance.postMessage != nil {
            postTextView.text = Post.sharedInstance.postMessage!
        }
    }
    
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //Do I need to put a spinner here? or what happens if the person reloads?
    func configureLocationButton(){
        if let place = LocationFetcher.sharedInstance.selectedPlace {
            locationButton.setTitle(place.name!, forState: UIControlState.Normal)
        }
    }
    
    
    //MARK: Create Post:
    @IBAction func postButtonTapped(sender: UIBarButtonItem) {
        //Need to create post
        let newPost = Post()
        newPost.postMessage = postTextView.text
        newPost.postImage = postImageView.image
        newPost.postPlace = LocationFetcher.sharedInstance.selectedPlace
        newPost.createPFObject()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func goToCameraView(sender: UITapGestureRecognizer) {
        let camera: PrivateResource = .Camera
        
        proposeToAccess(camera, agreed: {
            self.performSegueWithIdentifier("showCamera", sender: self)
            
            }, rejected: {
                print("no camera permissions")
        })
    
    }

    
    //MARK: Post Textview Stuff: 
    func configureTextview(){
        postTextView.returnKeyType = UIReturnKeyType.Done
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            postTextView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    //MARK: Keyboard Animations
    func registerForKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeState:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    //WARNGING: This is not perfect yet
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
