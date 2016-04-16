//
//  MapVC.swift
//  Bounce
//
//  Created by Andrew Roach on 1/14/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class MapVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    //Outlets
    @IBOutlet weak var shareSettingSegmentControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var shareSettingToolbar: UIToolbar!
    @IBOutlet weak var fetchButton: UIBarButtonItem!
    @IBOutlet weak var composeButton: UIBarButtonItem!
        
    
    
    //Variables
    var selectedPlace: Place?
    //Constants
    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        requestLocationData()

        configureViewColors()
    }
    
    func configureViewColors() {
        //Navigation Bar Colors
        
        //Toolbar Colors
        shareSettingToolbar.backgroundColor = BOUNCEPRIMARYCOLOR
        shareSettingSegmentControl.tintColor = BOUNCESECONDARYCOLOR
        
        //Remove Line under Navigation Bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @IBAction func composeButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("createPostSegue", sender: self)
    }
    
    @IBAction func fetchButtonTapped(sender: UIBarButtonItem) {
//        let fetcher = ParseFetcher()
//        fetcher.fetchData()
    }
    
    @IBAction func infoButtonPressed(sender: UIBarButtonItem) {
        print(KCSUser.activeUser().username)
        print(KCSUser.activeUser().userId)


        
    }
    @IBAction func settingsButtonPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("showSettingsSegue", sender: self)

    }
    
    
    @IBAction func sortingMethodSwitched(sender: UISegmentedControl) {
        createAnnotations()
    }
    
    //MARK: - MapView Delegate Methods
    func configureMapView(){
        mapView.showsUserLocation = true
        mapView.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapVC.createAnnotations), name: BOUNCEANNOTATIONSREADYNOTIFICATION, object: nil)
        
    }
    
    func createAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
//        let dm = DataModel()
////        if let objects = dm.fetchPlacesForShareSetting(currentShareSetting()) {
////            for place in objects {
////                let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
////                let annotation = BounceAnnotation(title: place.name, subtitle: String(place.score), coordinate: coordinate, place: place)
////                mapView.addAnnotation(annotation)
////                
////            }
////        }
    }
    
    func currentShareSetting() -> String {
        switch (shareSettingSegmentControl.selectedSegmentIndex) {
        case 0:
            return BOUNCEFRIENDSONLYSHARESETTING
        case 1:
            return BOUNCEEVERYONESHARESETTING
        default:
            return ""
        }
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation.isKindOfClass(MKUserLocation)
        {
            return nil
        }
        
        let bounceAnnotation = annotation as! BounceAnnotation
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationIdentifier")
        if let place = bounceAnnotation.place {
            let score = place.score
            if score <= BOUNCEDARKBLUESCORE {
                pinAnnotationView.pinTintColor = BOUNCEDARKBLUE
            }
            else if (score > BOUNCEDARKBLUESCORE && score <= BOUNCELIGHTBLUESCORE){
                pinAnnotationView.pinTintColor = BOUNCELIGHTBLUE
            }
            else if (score > BOUNCELIGHTBLUESCORE && score <= BOUNCEGREENSCORE){
                pinAnnotationView.pinTintColor = BOUNCEGREEN
            }
            else if (score > BOUNCEGREENSCORE && score <= BOUNCEYELLOWSCORE){
                pinAnnotationView.pinTintColor = BOUNCEYELLOW
            }
            else if (score > BOUNCEYELLOWSCORE && score <= BOUNCEORANGESCORE){
                pinAnnotationView.pinTintColor = BOUNCEORANGE
            }
            else {
                pinAnnotationView.pinTintColor = BOUNCERED
            }
        }
        
        
        
        
        
        pinAnnotationView.canShowCallout = true
        pinAnnotationView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        return pinAnnotationView
    }
    
    
    
    func mapView(MapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        
//        if control == annotationView.rightCalloutAccessoryView {
//            let annoation = mapView.selectedAnnotations[0] as! BounceAnnotation
//            let key = "\(String(annoation.title!))" + "," + "\(String(annoation.coordinate.latitude))" + "," + "\(String(annoation.coordinate.longitude))"
////            let dm = DataModel()
////            selectedPlace = dm.fetchPlaceWithKey(key)
//            performSegueWithIdentifier("showPosts", sender: self)
//        }
    }
    
    //MARK: - Location Manager
    
    func requestLocationData() {
        let location: PrivateResource = .Location(.WhenInUse)
        
        proposeToAccess(location, agreed: {
            self.locationManager = CLLocationManager()
            self.locationManager!.delegate = self
            self.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager!.startUpdatingLocation()
            self.configureMapView()
            }, rejected: {
                print("Location denied")
        })
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("updated location")
            let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(0.005, 0.005))
            LocationFetcher.sharedInstance.currentLocation = location
            mapView.setRegion(region, animated: true)
            locationManager!.stopUpdatingLocation()
            locationManager = nil
            fetchButtonTapped(UIBarButtonItem())
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.description)
    }
    
    //MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPosts" {
            let DV = segue.destinationViewController as! PlaceVC
            if let place = selectedPlace {
                DV.place = place
                configureViewColors()
            }
        }
    }
    
    //MARK: View customization
    
    func configureNavBar(){
        UINavigationBar.appearance().setBackgroundImage(
            UIImage(),
            forBarPosition: .Any,
            barMetrics: .Default)
        
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    

    
    
}



