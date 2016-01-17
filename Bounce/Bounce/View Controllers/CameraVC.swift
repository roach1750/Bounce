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
    
    let captureSession: AVCaptureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        beginCameraSession()

    }
    
    func beginCameraSession(){
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: device) as AVCaptureDeviceInput
            captureSession.addInput(input)
            
        }
        catch let error as NSError {
            print(error)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = cameraPreviewImageView.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.cameraPreviewImageView.layer.addSublayer(previewLayer)
        captureSession.startRunning()
        
        
        
    }
    
    
    


    @IBAction func cancelButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
    }

    @IBAction func takePicture(sender: UIButton) {
    }

    
    
    
    
    
    
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        
    }


}
