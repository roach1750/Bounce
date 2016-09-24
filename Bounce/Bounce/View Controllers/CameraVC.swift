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
        captureSession = AVCaptureSession()
        
        //pick camera
        var camera: AVCaptureDevice?
        if frontCamera == true {
            camera = cameraWithPosition(.front)
        }
        else {
            camera = cameraWithPosition(.back)
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
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                previewLayer.frame = cameraPreviewImageView.bounds
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                captureSession.sessionPreset = AVCaptureSessionPresetMedium
                self.cameraPreviewImageView.layer.addSublayer(previewLayer)
                captureSession.startRunning()
                addSwitchCameraButton()
            }
        }
    }
    
    func cameraWithPosition(_ position: AVCaptureDevicePosition) -> AVCaptureDevice {
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        for device  in devices! {
            if (device as AnyObject).position == position {
                return device as! AVCaptureDevice
            }
        }
        return AVCaptureDevice()
    }
    
    func switchCamera() {
        frontCamera = !frontCamera
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
        if cameraPreviewImageView.image == nil {
            if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo){
                videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
                stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                    if (sampleBuffer != nil) {
                        
                        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                            
                            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                            
                            let dataProvider = CGDataProvider(data: imageData as! CFData)
                            let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                            var image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.up)
                            self.captureSession.stopRunning()
                            let IC = ImageConfigurer.sharedInstance
                            if self.frontCamera == true {
                                
                                image = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .upMirrored)
                                
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
            takePictureButton.setImage(UIImage(named: "Take Picture Button"), for: UIControlState())
            self.saveButton.isHidden = true
            
            beginCameraSession()
        }
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
