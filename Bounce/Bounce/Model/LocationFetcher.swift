//
//  LocationFetcher.swift
//  Bounce
//
//  Created by Andrew Roach on 1/14/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import CoreLocation

//API KEY = AIzaSyCuFv4j7KQGLzZZDl-4T6SeT-Vjow2wgyU

class LocationFetcher: NSObject {
    
    class var sharedInstance: LocationFetcher {
        struct Singleton {
            static let instance = LocationFetcher()
        }
        return Singleton.instance
    }
    
    var selectedPlace: Place?
    
    var placeArray: [Place]?
    
    var currentLocation: CLLocation? {
        didSet {
            //fetchGooglePlaces()
            fetchFourSquarePlaces()
        }
    }
    
    func fetchFourSquarePlaces(){
        if let location = currentLocation {
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let urlString = "https://api.foursquare.com/v2/venues/search" +
                "?client_id=BHHFITGZBBFHH0A5NFVVAKRZENHIH4LJBWLBBC41ELKQHTIQ" +
                "&client_secret=JAKWMQU3LZLTIJ3O2Q3MSNL4N3EVZSGDQOH3DYA1YYYJX5OG" +
                "&v=20130815" +
                "&ll=" + latitude + "," + longitude
            
            let session = NSURLSession.sharedSession()
            let url = NSURL(string: urlString)
            let request = NSURLRequest(URL: url!)
            let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                if let error = error {
                    print(error)
                }
                if let _ = response {
//                    let httpResponse = response as! NSHTTPURLResponse
//                    print("response code = \(httpResponse.statusCode)")
                    //configure JSON
                    do{
                        let resultsJSON = JSON(data: data!)
                        self.placeArray = [Place]()
                        self.selectedPlace = nil
                        for (var i = 0; i < resultsJSON["response"]["venues"].count; i++) {
                            let currentPlace = Place()
                            currentPlace.name = resultsJSON["response"]["venues"][i]["name"].string!
                            currentPlace.latitude = resultsJSON["response"]["venues"][i]["location"]["lat"].double!
                            currentPlace.longitude = resultsJSON["response"]["venues"][i]["location"]["lng"].double!
                            let point = CGPointMake(CGFloat(currentPlace.latitude), CGFloat(currentPlace.longitude))
                            let currentLocationPoint = CGPointMake(CGFloat((self.currentLocation?.coordinate.latitude)!), CGFloat((self.currentLocation?.coordinate.longitude)!))
                            currentPlace.distanceFromUser = self.distanceBetweenPoints(point, point2: currentLocationPoint)
                            // print(currentPlace.description)
                            self.placeArray?.append(currentPlace)
                        }
                        self.placeArray?.sortInPlace({$0.distanceFromUser < $1.distanceFromUser})
                        
                        self.selectedPlace = self.placeArray?[0]
                        print("Foursquare Done")
                    }
                }
            }
            dataTask.resume()
        }
    }
    
    
    //Calculates the distance between to CGPoints and returns a double in feet
    func distanceBetweenPoints(point1:CGPoint, point2:CGPoint) -> Double {
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
            
            let session = NSURLSession.sharedSession()
            let url = NSURL(string: urlString)
            let request = NSURLRequest(URL: url!)
            
            let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                if let error = error {
                    print(error)
                }
                if let response = response {
                    print("url = \(response.URL!)")
                    print("response = \(response)")
                    let httpResponse = response as! NSHTTPURLResponse
                    print("response code = \(httpResponse.statusCode)")
                    
                    //if you response is json do the following
                    do{
                        let resultJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions())
                        print(resultJSON)
                        
                        
                    }catch _{
                        print("Received not-well-formatted JSON")
                    }
                    
                }
            }
            dataTask.resume()
            
        }
        
        
        
        
        
        
        
        
        
        
        
    }
    
    
    
}

