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
    
    //constants
    var fetcher = KinveyFetcher()
    
    
    //Variables
    var selectedPlace: Place?
    //Constants
    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        requestLocationData()
        configureViewColors()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapVC.createAnnotations), name: BOUNCEANNOTATIONSREADYNOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapVC.topImageForPlaceDownloaded), name: BOUNCETOPIMAGEDOWNLOADEDNOTIFICATION, object: nil)
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
        
        fetcher = KinveyFetcher()
        fetcher.queryForAllPlaces()
    }
    
    @IBAction func infoButtonPressed(sender: UIBarButtonItem) {
        
        print("\nUsername: \(KCSUser.activeUser().username)")
        print("User ID: \(KCSUser.activeUser().userId)")
        print("Facebook ID: \(KCSUser.activeUser().getValueForAttribute("Facebook ID"))")
        print("Facebook Friends: \(KCSUser.activeUser().getValueForAttribute("Facebook Friends IDs"))")
        
    }
    
    @IBAction func deleteCoreDatabase(sender: UIBarButtonItem) {
        let kF = KinveyFetcher()
        kF.deleteAllPostFromCoreDatabase()
        mapView.removeAnnotations(mapView.annotations)
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
        
    }
    
    func createAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        
        var data: [Place]?
        if currentShareSetting() == BOUNCEFRIENDSONLYSHARESETTING {
            data = fetcher.friendsOnlyPlaceData
        }
        else {
            data = fetcher.everyonePlaceData
            
        }
        
        if let objects = data {
            for place in objects {
                let coordinate = CLLocationCoordinate2D(latitude: (place.placeLocation?.coordinate.latitude)!, longitude: (place.placeLocation?.coordinate.longitude)!)
                let annotation = BounceAnnotation(title: place.placeName, subtitle: String(place.placeScore!), coordinate: coordinate, place: place)
                mapView.addAnnotation(annotation)
                
            }
        }
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
        if let place = bounceAnnotation.place {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: place.entityId!)
            let score = Int(place.placeScore!)
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

            
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            return pinAnnotationView
        }
        return nil
    }
    
    func topImageForPlaceDownloaded() {
        print("reloading map data")
        let currentAnnotation = mapView.selectedAnnotations[0] as? BounceAnnotation
        let place = currentAnnotation?.place
        let currentPinAnotation = mapView.viewForAnnotation(currentAnnotation!)
        if let imageData = KinveyFetcher.sharedInstance.topPlaceImageData[place!.entityId!] {
            let image = UIImage(data: imageData)
            let IC = ImageConfigurer()
            let rotatedImage = IC.rotateImage90Degress(image!)
            let topPostImageView = UIImageView(frame: CGRectMake(0, 0, 60, 60))
            topPostImageView.contentMode = .ScaleAspectFit
            topPostImageView.image  = rotatedImage
            currentPinAnotation!.leftCalloutAccessoryView = topPostImageView
            //        print(pinAnnotationView.leftCalloutAccessoryView?.frame)
        }
        
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let selectedAnnotation = mapView.selectedAnnotations[0] as? BounceAnnotation {
            if !selectedAnnotation.isKindOfClass(MKUserLocation)
            {
                let place = selectedAnnotation.place
                let kF = KinveyFetcher.sharedInstance
                kF.downloadTopImageForPlace(place!)
                print("clicked pin")
            }
        }
        
    }
    
    
    func mapView(MapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            let annoation = mapView.selectedAnnotations[0] as! BounceAnnotation
            selectedPlace = annoation.place
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
    
    
    //This animated the pin drop see: http://stackoverflow.com/questions/1857160/how-can-i-create-a-custom-pin-drop-animation-using-mkannotationview
    
    //    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
    //        for aV in views {
    //            if aV.isKindOfClass(MKUserLocation)
    //            {
    //                continue
    //            }
    //
    //            let endFrame = aV.frame
    //
    //            aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - view.frame.size.height, aV.frame.size.width, aV.frame.size.height)
    //
    //            UIView.animateWithDuration(0.5, delay: 0.04, options: .CurveLinear, animations: {
    //                aV.frame = endFrame
    //                }, completion: { finished in
    //                    if finished {
    //                        UIView.animateWithDuration(0.05, animations: {
    //                            aV.transform = CGAffineTransformMakeScale(1.0, 0.8)
    //                            }, completion: { finished in
    //                                if finished {
    //                                    UIView.animateWithDuration(0.1, animations: {
    //                                        aV.transform = CGAffineTransformIdentity
    //                                    })
    //                                }
    //                        })
    //                    }
    //
    //            })
    //
    //
    //        }
    //    }
    
    
    
    
    
    
    
}



