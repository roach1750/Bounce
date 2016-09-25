//
//  CameraVC.swift
//  Bounce
//
//  Created by Andrew Roach on 1/16/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import AVFoundation


class CameraVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var cameraPreviewImageView: UIImageView!
    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    //    let captureSession: AVCaptureSession = AVCaptureSession()
    var captureSession: AVCaptureSession = AVCaptureSession()
    
 
    var switchCameraButton: UIButton!
    
    override func viewDidLoad() {
        takePictureButton.setImage(UIImage(named: "Take Picture Button"), for: UIControlState())
        NotificationCenter.default.addObserver(self, selector: #selector(CameraVC.saveImage), name: NSNotification.Name(rawValue: BOUNCEIMAGEPROCESSEDNOTIFICATION), object: nil)
        addSwitchCameraButton()
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        beginCameraSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        saveButton.isHidden = true
    }
    
    func beginCameraSession(){
    }
    func switchCamera() {
        beginCameraSession()
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.tempPostImageData = nil
        appDelegate.tempPostMessage = nil
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func takePicture(_ sender: UIButton) {
    }
    
    
    func saveImage() {
        let IC = ImageConfigurer.sharedInstance
        if let configuredImage = IC.image {
            
            
            self.cameraPreviewImageView.image = configuredImage;
            self.takePictureButton.setImage(UIImage(named: "Delete Picture Button"), for: UIControlState())
            self.saveButton.isHidden = false
        }

        
    }
    
    
    
    // MARK: - UI Configuration
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func addSwitchCameraButton() {
        switchCameraButton = UIButton(frame: CGRect(x:  cameraPreviewImageView.frame.size.width - 70, y: 10 + cameraPreviewImageView.frame.origin.y, width: 50, height: 50))
        switchCameraButton.setImage(UIImage(named: "SwitchCamera"), for: UIControlState())
        switchCameraButton.addTarget(self, action: #selector(CameraVC.switchCamera), for: .touchUpInside)
        view.addSubview(switchCameraButton)
        view.bringSubview(toFront: switchCameraButton)
    }
    
    
}
