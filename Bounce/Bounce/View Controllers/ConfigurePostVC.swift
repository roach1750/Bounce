//
//  ConfigurePostVC.swift
//  Bounce
//
//  Created by Andrew Roach on 8/27/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import MapKit

class ConfigurePostVC: UIViewController, UITextViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postSharSettingSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var mapView: MKMapView!
    var postImage: UIImage?
    var locationManager: CLLocationManager?
    var placesArray: [FourSquarePlace]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if postImage != nil {
            postImageView.image = postImage
        }
        requestLocationData()

        NotificationCenter.default.addObserver(self, selector: #selector(ConfigurePostVC.createAnnotations), name: NSNotification.Name(rawValue: BOUNCEFOURSQUAREPLACESDONENOTIFICATION), object: nil)

    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
                dismiss(animated: false, completion: nil)
    }
    
    @IBAction func postButtonPressed(_ sender: AnyObject) {
    }
    
    @IBAction func morePlacesButtonPressed(_ sender: UIButton) {
    }
    
    
    //MARK: - Location Manager
    
    func requestLocationData() {
        let location: PrivateResource = .location(.whenInUse)
        
        proposeToAccess(location, agreed: {
            self.locationManager = CLLocationManager()
            self.locationManager!.delegate = self
            self.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager!.startUpdatingLocation()
            }, rejected: {
                print("Location denied")
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("updated location")
            let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(0.05, 0.05))
            LocationFetcher.sharedInstance.currentLocation = location
            mapView.setRegion(region, animated: true)
            locationManager!.stopUpdatingLocation()
            locationManager = nil
        }
    }
    
    func createAnnotations() {
        
        if let placesArray = LocationFetcher.sharedInstance.placeArray {
            print(placesArray)
            
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    
    
}
