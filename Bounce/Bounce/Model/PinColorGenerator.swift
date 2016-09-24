//
//  PinColorGenerator.swift
//  Bounce
//
//  Created by Andrew Roach on 8/19/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit

class PinColorGenerator: NSObject {
    
    func roundToNearest(_ number: Double, toNearest: Double) -> Double {
        return round(number / toNearest) * toNearest
    }
    
    
    func pinColorPicker(_ pins:[BounceAnnotation]) -> [NSNumber:UIColor] {
        
        var scores = [Double]()
        var colorDict = [NSNumber:UIColor]()
        
        for pin in pins {
            let score = pin.place?.placeScore
            scores.append(Double(score!))
        }
        
        let maxScore = scores.max()
        let minScore = scores.min()
        
        var h = 0.0
        let s = 0.75
        let b = 1.0
        let a = 1.0
        
        let redStartAngle = 54.0
        let redEndAngle = 11.0
        
        //        let blueStartAngle = 59.0
        //        let blueEndAngle = 59.0
        
        let redAngle = redStartAngle - redEndAngle
        //        let blueAngle = blueStartAngle - blueEndAngle
        
        //        let totalAngle = redAngle + blueAngle
        
        
        for score in scores {
            
            let scorePercentage = (score - minScore!) / (maxScore! - minScore!)
            let colorSegmentAngle = redStartAngle - scorePercentage * redAngle
            
            
            h = roundToNearest(colorSegmentAngle/360,toNearest: 0.1)
            
            let color = UIColor(hue: CGFloat(Float(h)), saturation: CGFloat(Float(s)), brightness: CGFloat(Float(b)), alpha: CGFloat(Float(a)))
            
            colorDict[NSNumber(value: score as Double)] = color
        }
        //        //2 Color Segments
        //        for score in scores {
        //
        //            let absouteColorAngle: Double
        //
        //            let scorePercentage = (score - minScore!) / (maxScore! - minScore!)
        //            let colorSegmentAngle = scorePercentage * totalAngle
        //
        //            if colorSegmentAngle < blueAngle {
        //                absouteColorAngle = blueStartAngle - colorSegmentAngle
        //
        //            } else {
        //                absouteColorAngle = redStartAngle - (colorSegmentAngle - blueAngle)
        //            }
        //
        //            h = roundToNearest(absouteColorAngle/360,toNearest: 0.1)
        //
        //            let color = UIColor(hue: CGFloat(Float(h)), saturation: CGFloat(Float(s)), brightness: CGFloat(Float(b)), alpha: CGFloat(Float(a)))
        //            
        //            colorDict[NSNumber(double: score)] = color
        //        }
        
        return colorDict
    }
}
