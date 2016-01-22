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
    
    let captureSession: AVCaptureSession = AVCaptureSession()
    var stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        takePictureButton.layer.cornerRadius = 0.5 * takePictureButton.bounds.size.width
    }
    
    override func viewDidAppear(animated: Bool) {
        beginCameraSession()

    }
    
    func beginCameraSession(){
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
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
                self.cameraPreviewImageView.layer.addSublayer(previewLayer)
                captureSession.startRunning()
            }
        }

    }
    
    
    


    @IBAction func cancelButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func takePicture(sender: UIButton) {
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    self.captureSession.stopRunning()
                    self.cameraPreviewImageView.image = image;
                    Post.sharedInstance.postImageData = UIImagePNGRepresentation(image)
                }
            })
        }
    }

    
    
    
    
    
    
    
    
    // MARK: - Navigation
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }



}
