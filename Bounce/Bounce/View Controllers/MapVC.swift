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
import Parse
import Realm
import RealmSwift

class MapVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    //Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //Variables
    var selectedPlace: Place?
    //Constants
    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestLocationData()
        print(Realm.Configuration.defaultConfiguration.path!)
        
        let realm = try! Realm()
        try! realm.write{
            realm.deleteAll()
        }

    }
    
    @IBAction func composeButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("createPostSegue", sender: self)
    }

    @IBAction func fetchButtonTapped(sender: UIBarButtonItem) {
        let fetcher = ParseFetcher()
        fetcher.fetchData()
    }

    
    //MARK: - MapView Delegate Methods 
    
    
    func configureMapView(){
        mapView.showsUserLocation = true
        mapView.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "createAnnotations", name: BOUNCEANNOTATIONSREADYNOTIFICATION, object: nil)
    }
    
    func createAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        let dm = DataModel()
        let objects = dm.fetchAllPlaces()
        for place in objects {
            let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            let annotation = BounceAnnotation(title: place.name, subtitle: String(place.score), coordinate: coordinate)
            
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation.isKindOfClass(MKUserLocation)
        {
            return nil
        }
        
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationIdentifier")
        
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        pinAnnotationView.pinTintColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
        
        
        pinAnnotationView.canShowCallout = true
        pinAnnotationView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        return pinAnnotationView
    }
    

    
    func mapView(MapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //good idea to create place key here then look that up in the realm database? 
        
        if control == annotationView.rightCalloutAccessoryView {
            let annoation = mapView.selectedAnnotations[0] as! BounceAnnotation
            let key = "\(String(annoation.title!))" + "," + "\(String(annoation.coordinate.latitude))" + "," + "\(String(annoation.coordinate.longitude))"
            let dm = DataModel()
            selectedPlace = dm.fetchPlaceWithKey(key)
            performSegueWithIdentifier("showPosts", sender: self)
            }
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
            }
        }
    }
    
}



