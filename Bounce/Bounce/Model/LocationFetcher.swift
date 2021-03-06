//
//  LocationFetcher.swift
//  Bounce
//
//  Created by Andrew Roach on 1/14/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


//API KEY = AIzaSyCuFv4j7KQGLzZZDl-4T6SeT-Vjow2wgyU

class LocationFetcher: NSObject, URLSessionDelegate {
    
    class var sharedInstance: LocationFetcher {
        struct Singleton {
            static let instance = LocationFetcher()
        }
        return Singleton.instance
    }
    
    var selectedPlace: FourSquarePlace?
    
    var placeArray: [FourSquarePlace]?
    
    var currentLocation: CLLocation? {
        didSet {
            //fetchGooglePlaces()
            fetchFourSquarePlaces()
        }
    }
    
    func fetchFourSquarePlaces(){
        print("Fetching Four Square Places")
        if let location = currentLocation {
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let urlString = "https://api.foursquare.com/v2/venues/search" +
                "?client_id=BHHFITGZBBFHH0A5NFVVAKRZENHIH4LJBWLBBC41ELKQHTIQ" +
                "&client_secret=JAKWMQU3LZLTIJ3O2Q3MSNL4N3EVZSGDQOH3DYA1YYYJX5OG" +
                "&v=20130815" +
                "&ll=" + latitude + "," + longitude
            
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            let url = URL(string: urlString)
            let request = URLRequest(url: url!)
            
            session.dataTask(with: request, completionHandler: { (data, response, error)in
                
                if let error = error {
                    print(error)
                }
                if let _ = response {
//                    let httpResponse = response as! NSHTTPURLResponse
//                    print("response code = \(httpResponse.statusCode)")
                    //configure JSON
                    do{
                        let resultsJSON = JSON(data: data!)
                        self.placeArray = [FourSquarePlace]()
                        self.selectedPlace = nil
                        for i in 0..<resultsJSON["response"]["venues"].count {
                            let place = FourSquarePlace()
                            place.name = resultsJSON["response"]["venues"][i]["name"].string!
                            let latitude = resultsJSON["response"]["venues"][i]["location"]["lat"].double!
                            let longitude = resultsJSON["response"]["venues"][i]["location"]["lng"].double!
                            place.location = CLLocation(latitude: latitude, longitude: longitude)
                            
                            let point = CGPoint(x: latitude, y: longitude)
                            let currentLocationCoordinate = self.currentLocation?.coordinate
                            let currentLocationPoint = CGPoint(x: (currentLocationCoordinate?.latitude)!, y: (currentLocationCoordinate?.longitude)!)
                            place.distanceFromUser = self.distanceBetweenPoints(point, point2: currentLocationPoint)
//                            print(place.name!)
                            self.placeArray?.append(place)
                        }
                        self.placeArray?.sort(by: {$0.distanceFromUser < $1.distanceFromUser})
                        
                        self.selectedPlace = self.placeArray?[0]
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: BOUNCEFOURSQUAREPLACESDONENOTIFICATION), object: nil)
                        
                        print("Foursquare Done")
                    }
                }
            }).resume()
        }
    }
    
    

    
    
    
    
    
    //Calculates the distance between to CGPoints and returns a double in feet
    func distanceBetweenPoints(_ point1:CGPoint, point2:CGPoint) -> Double {
        let xDist = point2.x - point1.x
        let yDist = point2.y - point1.y
        let coordDistance = Double(sqrt(pow(xDist,2) + pow(yDist,2)))
        let R = 6371000.0 //This is converting lat/long to meter
        let metersDistance = coordDistance * R
        let feetDistance = metersDistance / 3.28084 //this is ft to meter
        return feetDistance
    }
    
    
    func fetchGooglePlaces() {
        if let location = currentLocation {
            
            
            let searchRadius = "100" //This is in meters
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let urlString = "https://maps.googleapis.com/maps/api/place/search/json?location=" + latitude + "," + longitude + "&radius=" + searchRadius + "&key=AIzaSyCuFv4j7KQGLzZZDl-4T6SeT-Vjow2wgyU" + "&sensor=true"
            
            let session = URLSession.shared
            let url = URL(string: urlString)
            let request = URLRequest(url: url!)
            
            let dataTask = session.dataTask(with: request, completionHandler: { (data:Data?, response:URLResponse?, error:NSError?) -> Void in
                if let error = error {
                    print(error)
                }
                if let response = response {
                    print("url = \(response.url!)")
                    print("response = \(response)")
                    let httpResponse = response as! HTTPURLResponse
                    print("response code = \(httpResponse.statusCode)")
                    
                    //if you response is json do the following
                    do{
                        let resultJSON = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions())
                        print(resultJSON)
                        
                        
                    }catch _{
                        print("Received not-well-formatted JSON")
                    }
                    
                }
            } as! (Data?, URLResponse?, Error?) -> Void) 
            dataTask.resume()
            
        }
        
        
        
        
        
        
        
        
        
        
        
    }
    
    
    
}

