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
    @IBOutlet weak var postButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    var postImage: UIImage?
    var postImageData: Data?
    var locationManager: CLLocationManager?
    var placesArray: [FourSquarePlace]?
    var selectedFourSquarePlace: FourSquarePlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if postImage != nil {
            postImageView.image = postImage
        }
        requestLocationData()
        postButton.isEnabled = false
        postButton.alpha = 0.2
        NotificationCenter.default.addObserver(self, selector: #selector(ConfigurePostVC.createAnnotations), name: NSNotification.Name(rawValue: BOUNCEFOURSQUAREPLACESDONENOTIFICATION), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConfigurePostVC.uploadDone), name: NSNotification.Name(rawValue: BOUNCEIMAGEUPLOADCOMPLETENOTIFICATION), object: nil)

    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
                dismiss(animated: false, completion: nil)
    }
    
    @IBAction func postButtonPressed(_ sender: AnyObject) {
        
        var shareSetting: String!
        switch postSharSettingSegmentedControl.selectedSegmentIndex {
        case 0:
            shareSetting = BOUNCEFRIENDSONLYSHARESETTING
        default:
            shareSetting = BOUNCEEVERYONESHARESETTING
        }
        

        
        let kU = KinveyUploader()
        
        
        kU.createPostThenUpload(message: postTextView.text, image: postImageData!, shareSetting:shareSetting , selectedPlace: selectedFourSquarePlace!)
        
    }
    
    @IBAction func morePlacesButtonPressed(_ sender: UIButton) {
    }
    
    func uploadDone() {
        self.backButtonPressed(UIButton())
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
            let region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(0.002, 0.002))
            LocationFetcher.sharedInstance.currentLocation = location
            mapView.setRegion(region, animated: true)
            locationManager!.stopUpdatingLocation()
            locationManager = nil
        }
    }
    
    func createAnnotations() {
        
        if let placesArray = LocationFetcher.sharedInstance.placeArray {
            mapView.removeAnnotations(mapView.annotations)
            
            for fourSquarePlace in placesArray {
                let coordinate = CLLocationCoordinate2D(latitude: (fourSquarePlace.location?.coordinate.latitude)!, longitude: (fourSquarePlace.location?.coordinate.longitude)!)
                let annotation = BounceAnnotation(title: fourSquarePlace.name, subtitle: nil, coordinate: coordinate, place: nil, color: UIColor.blue)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    //MARK: Mapview stuff: 
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let selectedAnnotation = mapView.selectedAnnotations[0] as? BounceAnnotation {
            if !selectedAnnotation.isKind(of: MKUserLocation.self)
            {
                postButton.isEnabled = true
                postButton.alpha = 1.0
                selectedFourSquarePlace = FourSquarePlace()
                selectedFourSquarePlace?.name = selectedAnnotation.title
                selectedFourSquarePlace?.location = CLLocation(latitude: selectedAnnotation.coordinate.latitude, longitude: selectedAnnotation.coordinate.longitude)

            }
        }
        
    }
    
    //MARK: Post Textview Stuff:
    func configureTextview(){
        postTextView.returnKeyType = UIReturnKeyType.done
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            if textView.text == "" {
                textView.text = "Enter caption for post"
            }
            postTextView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter caption for post" {
            textView.text = ""
        }
    }
    

    
    
}
