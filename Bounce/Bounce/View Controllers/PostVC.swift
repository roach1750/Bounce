//
//  PostVC.swift
//  Bounce
//
//  Created by Andrew Roach on 1/16/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import MBProgressHUD
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PostVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    var postImageDeleteButton: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
        configureTextview()
        configureLocationButton()
        NotificationCenter.default.addObserver(self, selector: #selector(PostVC.updateProgressIndicator(_:)), name: NSNotification.Name(rawValue: BOUNCEIMAGEUPLOADINPROGRESSNOTIFICATION), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostVC.showProgressIndicator), name: NSNotification.Name(rawValue: BOUNCEIMAGEUPLOADBEGANNOTIFICATION), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostVC.removeProgressIndicator), name: NSNotification.Name(rawValue: BOUNCEIMAGEUPLOADCOMPLETENOTIFICATION), object: nil)
        postButton.isEnabled = false
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        restoreDataIfApplicable()
    }
    override func viewWillAppear(_ animated: Bool) {
        configureLocationButton()
    }
    
    var loadingNotification: MBProgressHUD = MBProgressHUD()
    
    
    func showProgressIndicator() {
        loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.labelText = "Uploading"
        loadingNotification.mode = MBProgressHUDMode.annularDeterminate
        loadingNotification.dimBackground = true
    }
    
    func updateProgressIndicator(_ notification: Notification) {
        if let info = (notification as NSNotification).userInfo as? Dictionary<String,Double> {
            let percentComplete = info["progress"]!
            loadingNotification.progress = Float(percentComplete)
            print(percentComplete)            
        }
    }
    
    func removeProgressIndicator() {
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func restoreDataIfApplicable(){
        
        if appDelegate.tempPostImageData != nil {
            let IC = ImageConfigurer()
            postImageView.image = IC.rotateImage90Degress(UIImage(data: appDelegate.tempPostImageData!)!)
            addDeleteImageButton()
            postButton.isEnabled = true

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
        postImageDeleteButton.setTitle("x", for: UIControlState())
        postImageDeleteButton.addTarget(self, action: #selector(PostVC.deleteImagePressed), for: .touchUpInside)
        view.addSubview(postImageDeleteButton)
        view.bringSubview(toFront: postImageDeleteButton)
    }
    
    func removeDeleteImageButton(){
        postImageDeleteButton.isHidden = true
    }
    
    func deleteImagePressed(){
        removeDeleteImageButton()
        postButton.isEnabled = false
        appDelegate.tempPostImageData = nil
        
        postImageView.image = UIImage(named: "cameraImage")
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        postTextView.resignFirstResponder()
        appDelegate.tempPostImageData = nil
        appDelegate.tempPostMessage = nil
        dismiss(animated: true, completion: nil)
    }
    
    
    //Do I need to put a spinner here? or what happens if the person reloads?
    func configureLocationButton(){
        if let place = LocationFetcher.sharedInstance.selectedPlace {
            locationButton.setTitle(place.name, for: UIControlState())
        }
    }
    
    
    //MARK: Create Post:
    @IBAction func postButtonTapped(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Select Who Can See This Bounce", message:nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        let friendsOnlyAction = UIAlertAction(title: "Friends Only", style: .default) { (action) in
            self.createPost(BOUNCEFRIENDSONLYSHARESETTING)
        }
        let EveryoneAction = UIAlertAction(title: "Everyone", style: .default) { (action) in
            self.createPost(BOUNCEEVERYONESHARESETTING)
        }
        
        alertController.addAction(friendsOnlyAction)
        alertController.addAction(EveryoneAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) {
            
        }
        
        
    }
    
    
    
    
    @IBAction func goToCameraView(_ sender: UITapGestureRecognizer) {
        let camera: PrivateResource = .camera
        
        proposeToAccess( camera, agreed: {
            self.performSegue(withIdentifier: "showCamera", sender: self)
            
            }, rejected: {
                print("no camera permissions")
        })
        
    }
    
    
    //MARK: Create Post
    
    func createPost(_ shareSetting: String){
        
        
        let uploader = KinveyUploader()
        
        if let image = postImageView.image, let selectedPlace = LocationFetcher.sharedInstance.selectedPlace {
            
            let imageData = UIImagePNGRepresentation(image)
            
            uploader.createPostThenUpload(message: postTextView.text, image: imageData!, shareSetting: shareSetting, selectedPlace: selectedPlace)
        }
        
        appDelegate.tempPostImageData = nil
        
    }
    
    
    
    //MARK: Post Textview Stuff:
    func configureTextview(){
        postTextView.returnKeyType = UIReturnKeyType.done
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            if textView.text == "" {
                textView.text = "Enter caption for post"
            }
            postTextView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter caption for post" {
            textView.text = ""
        }
    }
    
    
    //MARK: Keyboard Animations
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(PostVC.keyboardWillChangeState(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    //WARNING: This is not perfect yet
    func keyboardWillChangeState(_ notification: Notification) {
        let keyboardBeginFrame = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue
        let keyboardEndFrame = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
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
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                var imageTransform = self.postImageView.transform
                imageTransform = imageTransform.translatedBy(x: 0, y: -imageTranslationsValue)
                imageTransform = imageTransform.scaledBy(x: imageScaleValue, y: imageScaleValue);
                
                var textTransform = self.postTextView.transform
                textTransform =  textTransform.translatedBy(x: 0, y: -textTranslationValue);
                
                self.postImageView.transform = imageTransform
                self.postTextView.transform = textTransform
                
            })
        }
        else {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.postImageView.transform = CGAffineTransform.identity
                self.postTextView.transform = CGAffineTransform.identity
            })
        }
        
        
    }
    
    
    
    
    
}
