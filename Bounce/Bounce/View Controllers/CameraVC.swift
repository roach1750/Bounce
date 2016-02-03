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
    
//    let captureSession: AVCaptureSession = AVCaptureSession()
    var captureSession: AVCaptureSession = AVCaptureSession()

    var stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var switchCameraButton: UIButton!
    var frontCamera: Bool = true
    
    override func viewDidLoad() {
        takePictureButton.setImage(UIImage(named: "Take Picture Button"), forState: .Normal)
        super.viewDidLoad()
    }
    override func viewDidAppear(animated: Bool) {
        beginCameraSession()
    }
    
    func beginCameraSession(){
        //remove old inputs, if necessary
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
                captureSession.sessionPreset = AVCaptureSessionPresetPhoto
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
        Post.sharedInstance.postImageData = nil
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
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Up)
                    self.captureSession.stopRunning()
                    let imageCropper = ImageResizer()
                    let croppedImage = imageCropper.cropToSquare(image)
                    let rotatedImage = imageCropper.rotateImage90Degress(croppedImage)
                    self.cameraPreviewImageView.image = rotatedImage;
                    Post.sharedInstance.postImageData = UIImagePNGRepresentation(rotatedImage)
                    self.takePictureButton.setImage(UIImage(named: "Delete Picture Button"), forState: .Normal)
                }
            })
        }
        }
        else {
            cameraPreviewImageView.image = nil
            takePictureButton.setImage(UIImage(named: "Take Picture Button"), forState: .Normal)
            beginCameraSession()
        }
    }
    
    
    

    
    
    // MARK: - UI Configuration
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func addSwitchCameraButton() {
        switchCameraButton = UIButton(frame: CGRect(x:  cameraPreviewImageView.frame.size.width - 70, y: 10 + cameraPreviewImageView.frame.origin.y, width: 50, height: 50))
        switchCameraButton.setImage(UIImage(named: "SwitchCamera"), forState: .Normal)
        switchCameraButton.addTarget(self, action: "switchCamera", forControlEvents: .TouchUpInside)
        view.addSubview(switchCameraButton)
        view.bringSubviewToFront(switchCameraButton)
    }
    
    
}
