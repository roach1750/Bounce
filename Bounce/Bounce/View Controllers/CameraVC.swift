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
    
    var stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var switchCameraButton: UIButton!
    var frontCamera: Bool = true
    
    override func viewDidLoad() {
        takePictureButton.setImage(UIImage(named: "Take Picture Button"), forState: .Normal)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CameraVC.saveImage), name: BOUNCEIMAGEPROCESSEDNOTIFICATION, object: nil)
        addSwitchCameraButton()
        super.viewDidLoad()
    }
    override func viewDidAppear(animated: Bool) {
        beginCameraSession()
    }
    
    override func viewWillAppear(animated: Bool) {
        saveButton.hidden = true
    }
    
    func beginCameraSession(){
        captureSession = AVCaptureSession()
        
        //pick camera
        var camera: AVCaptureDevice?
        if frontCamera == true {
            camera = cameraWithPosition(.Front)
        }
        else {
            camera = cameraWithPosition(.Back)
        }
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: camera!)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        if error == nil && captureSession.canAddInput(input) {
            captureSession.addInput(input)
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewLayer.frame = cameraPreviewImageView.bounds
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                captureSession.sessionPreset = AVCaptureSessionPresetMedium
                self.cameraPreviewImageView.layer.addSublayer(previewLayer)
                captureSession.startRunning()
                addSwitchCameraButton()
            }
        }
    }
    
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device  in devices {
            if device.position == position {
                return device as! AVCaptureDevice
            }
        }
        return AVCaptureDevice()
    }
    
    func switchCamera() {
        frontCamera = !frontCamera
        beginCameraSession()
    }
    
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.tempPostImageData = nil
        appDelegate.tempPostMessage = nil
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func takePicture(sender: UIButton) {
        if cameraPreviewImageView.image == nil {
            if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo){
                videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
                stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                    if (sampleBuffer != nil) {
                        
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                            
                            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                            
                            let dataProvider = CGDataProviderCreateWithCFData(imageData)
                            let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                            var image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Up)
                            self.captureSession.stopRunning()
                            let IC = ImageConfigurer.sharedInstance
                            if self.frontCamera == true {
                                
                                image = UIImage(CGImage: image.CGImage!, scale: 1.0, orientation: .UpMirrored)
                                
                                //reflect the image 
                                print("front camera")
                            }
                            
                            
                            
                            IC.image = image
                            IC.processImage()
                        }
                    }
                })
            }
        }
        else {
            cameraPreviewImageView.image = nil
            takePictureButton.setImage(UIImage(named: "Take Picture Button"), forState: .Normal)
            self.saveButton.hidden = true
            
            beginCameraSession()
        }
    }
    
    
    func saveImage() {
        let IC = ImageConfigurer.sharedInstance
        if let configuredImage = IC.image {
            
            
            self.cameraPreviewImageView.image = configuredImage;
            self.takePictureButton.setImage(UIImage(named: "Delete Picture Button"), forState: .Normal)
            self.saveButton.hidden = false
        }

        
    }
    
    
    
    // MARK: - UI Configuration
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func addSwitchCameraButton() {
        switchCameraButton = UIButton(frame: CGRect(x:  cameraPreviewImageView.frame.size.width - 70, y: 10 + cameraPreviewImageView.frame.origin.y, width: 50, height: 50))
        switchCameraButton.setImage(UIImage(named: "SwitchCamera"), forState: .Normal)
        switchCameraButton.addTarget(self, action: #selector(CameraVC.switchCamera), forControlEvents: .TouchUpInside)
        view.addSubview(switchCameraButton)
        view.bringSubviewToFront(switchCameraButton)
    }
    
    
}
