//
//  ImageResizer.swift
//  Bounce
//
//  Created by Andrew Roach on 1/31/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit

class ImageConfigurer: NSObject {

    class var sharedInstance: ImageConfigurer {
        struct Singleton {
            static let instance = ImageConfigurer()
        }
        return Singleton.instance
    }
    
    var image: UIImage?
    
    func processImage(){
        let croppedImage = cropToSquare(image!)
        let rotatedImage = rotateImage90Degress(croppedImage)
//        let filteredImage = addSepiaToneToImage(rotatedImage)
        image = rotatedImage
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.tempPostImageData = UIImagePNGRepresentation(image!)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: BOUNCEIMAGEPROCESSEDNOTIFICATION), object: nil, userInfo: nil)
        }

    }
    
    
    
    func cropToSquare(_ originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(cgImage: originalImage.cgImage!)
        
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: width, height: height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
                
        return image
    }
    
    func rotateImage90Degress(_ unrotatedImage: UIImage) -> UIImage {
        let rotatedImage = UIImage(cgImage: unrotatedImage.cgImage!, scale: 1.0, orientation: UIImageOrientation.right)
        return rotatedImage
    }
    
    
    
    
    
    func reflectImage(_ image: UIImage) -> UIImage {
        let relfectedImageToReturn = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
        return relfectedImageToReturn
    }
    
    func resizeImageTo60x60(_ image: UIImage) -> UIImage {
        let size = image.size
        let targetSize = CGSize(width: 60, height: 60)
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    //Filter Methods
    
//    func addSepiaToneToImage(inputImage: UIImage) -> UIImage {
//        
//        let context = CIContext(options: nil)
//        
//        if let currentFilter = CIFilter(name: "CISepiaTone") {
//            let beginImage = CIImage(image: inputImage)
//            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
//            currentFilter.setValue(0.5, forKey: kCIInputIntensityKey)
//            
//            if let output = currentFilter.outputImage {
//                let cgimg = context.createCGImage(output, fromRect: output.extent)
//                let processedImage = UIImage(CGImage: cgimg)
//                return processedImage
//                // do something interesting with the processed image
//            }
//        }
//        
//        return inputImage
//    }
//    
    
    
    
}
