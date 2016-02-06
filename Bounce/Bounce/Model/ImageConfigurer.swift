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
        let filteredImage = addSepiaToneToImage(rotatedImage)
        image = filteredImage
        Post.sharedInstance.postImageData = UIImagePNGRepresentation(image!)
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName(BOUNCEIMAGEPROCESSEDNOTIFICATION, object: nil, userInfo: nil)
        }

    }
    
    
    func cropToSquare(originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage!)
        
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
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
                
        return image
    }
    
    func rotateImage90Degress(unrotatedImage: UIImage) -> UIImage {
        let rotatedImage = UIImage(CGImage: unrotatedImage.CGImage!, scale: 1.0, orientation: UIImageOrientation.Right)
        return rotatedImage
    }
    
    
    
    
    
    func reflectImage(image: UIImage) -> UIImage {
        let relfectedImageToReturn = UIImage(CGImage: image.CGImage!, scale: image.scale, orientation: .LeftMirrored)
        return relfectedImageToReturn
    }
    
    
    
    
    //Filter Methods
    
    func addSepiaToneToImage(inputImage: UIImage) -> UIImage {
        
        let context = CIContext(options: nil)
        
        if let currentFilter = CIFilter(name: "CISepiaTone") {
            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            currentFilter.setValue(0.5, forKey: kCIInputIntensityKey)
            
            if let output = currentFilter.outputImage {
                let cgimg = context.createCGImage(output, fromRect: output.extent)
                let processedImage = UIImage(CGImage: cgimg)
                return processedImage
                // do something interesting with the processed image
            }
        }
        
        return inputImage
    }
    
    
    
    
}
