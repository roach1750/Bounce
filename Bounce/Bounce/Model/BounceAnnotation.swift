//
//  BounceAnnotation.swift
//  Bounce
//
//  Created by Andrew Roach on 1/25/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import MapKit

class BounceAnnotation: NSObject, MKAnnotation
{
    let title:String?
    let subtitle:String?
    let coordinate: CLLocationCoordinate2D
    let place: Place?
    
    
    init(title: String?, subtitle:String?, coordinate: CLLocationCoordinate2D, place: Place?)
    {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.place = place
        super.init()
    }
}