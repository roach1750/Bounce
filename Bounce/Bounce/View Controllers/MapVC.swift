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
import FBSDKCoreKit
import FBSDKLoginKit
import Fabric
import Crashlytics

class MapVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    //Outlets
    @IBOutlet weak var shareSettingSegmentControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var shareSettingToolbar: UIToolbar!
    @IBOutlet weak var fetchButton: UIBarButtonItem!
    @IBOutlet weak var composeButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    
    @IBOutlet weak var locationButton: UIButton!
    
    //Variables
    var selectedPlace: Place?
    var mapRegion: MKCoordinateRegion?
    var mapRegionChanged = false
    //Constants
    var locationManager: CLLocationManager?
    var colorDict = [NSNumber:UIColor]()
    var fetcher = KinveyFetcher()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        requestLocationData()
        configureViewColors()
        NotificationCenter.default.addObserver(self, selector: #selector(MapVC.createAnnotations), name: NSNotification.Name(rawValue: BOUNCEANNOTATIONSREADYNOTIFICATION), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MapVC.topImageForPlaceDownloaded), name: NSNotification.Name(rawValue: BOUNCETOPIMAGEDOWNLOADEDNOTIFICATION), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureViewForUserStatus()
    }
    
    //    override func viewWillDisappear(animated: Bool) {
    //        NSNotificationCenter.defaultCenter().removeObserver(self, forKeyPath: BOUNCETOPIMAGEDOWNLOADEDNOTIFICATION)
    //    }
    
    func configureViewColors() {
        //Navigation Bar Colors
        
        //Toolbar Colors
        shareSettingToolbar.barTintColor = BOUNCEPRIMARYCOLOR
        shareSettingSegmentControl.tintColor = BOUNCESECONDARYCOLOR
        
        //Remove Line under Navigation Bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @IBAction func composeButtonTapped(_ sender: UIBarButtonItem) {
        if FBSDKAccessToken.current() == nil || KCSUser.active() == nil {
            addAndShowAlertToGoToSettingsWithMessage("You need to login to go to create a post, click login below")
        }
        else {
            performSegue(withIdentifier: "createPostSegue", sender: self)
        }
    }
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        if FBSDKAccessToken.current() == nil || KCSUser.active() == nil {
            addAndShowAlertToGoToSettingsWithMessage("You need to login to go to create a post, click login below")
        }
        else {
            performSegue(withIdentifier: "showCamera", sender: self)
        }
        
    }
    
    @IBAction func fetchButtonTapped(_ sender: UIBarButtonItem) {
        
        fetcher = KinveyFetcher()
        fetcher.queryForAllPlaces()
        

        
        if mapRegionChanged {
        
            Answers.logCustomEvent(withName: "mapRegionSearch",
                                           customAttributes: [
                                            "latCenter": NSNumber(value: mapRegion!.center.latitude),
                                            "lonCenter": NSNumber(value: mapRegion!.center.longitude),
                                            "latDelta": NSNumber(value: mapRegion!.span.latitudeDelta),
                                            "lonDelta": NSNumber(value: mapRegion!.span.longitudeDelta)
                                        
                ])
        }
        
        
    }
    
    @IBAction func infoButtonPressed(_ sender: UIBarButtonItem) {
        
        print("\nUsername: \(KCSUser.active().username)")
        print("User ID: \(KCSUser.active().userId)")
        print("Facebook ID: \(KCSUser.active().getValueForAttribute("Facebook ID"))")
        print("Facebook Friends: \(KCSUser.active().getValueForAttribute("Facebook Friends IDs"))")
        
    }
    
    @IBAction func deleteCoreDatabase(_ sender: UIBarButtonItem) {
        let kF = KinveyFetcher()
        kF.deleteAllPostFromCoreDatabase()
        mapView.removeAnnotations(mapView.annotations)
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "showSettingsSegue", sender: self)
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        Answers.logCustomEvent(withName: "My First Custom Event",
                                       customAttributes: nil)
        Answers.logCustomEvent(withName: "Played Song",
                                       customAttributes: [:])
        
        mapView.userTrackingMode = .follow
        locationButton.setImage(UIImage(named: "LocationButtonSelected"), for: UIControlState())
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        if mode != .follow {
            locationButton.setImage(UIImage(named: "LocationButton"), for: UIControlState())
        }
    }
    
    
    @IBAction func sortingMethodSwitched(_ sender: UISegmentedControl) {
        if  currentShareSetting() == BOUNCEFRIENDSONLYSHARESETTING {
            if FBSDKAccessToken.current() == nil || KCSUser.active() == nil {
                addAndShowAlertToGoToSettingsWithMessage("You need to login see your friends posts, click login below")
                shareSettingSegmentControl.selectedSegmentIndex = 1
            }
            else {
                createAnnotations()
            }
        }
        else {
            createAnnotations()
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
                let color = colorDict[place.placeScore!]
                print(place.description)
                

                let coordinate = CLLocationCoordinate2D(latitude: (place.placeLocation?.coordinate.latitude)!, longitude: (place.placeLocation?.coordinate.longitude)!)
                let annotation = BounceAnnotation(title: place.placeName, subtitle: String(describing: place.placeScore!), coordinate: coordinate, place: place, color: color)
                mapView.addAnnotation(annotation)
                
            }
        }
    }
    

    fileprivate var mapChangedFromUserInteraction = false
    
    fileprivate func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizerState.began || recognizer.state == UIGestureRecognizerState.ended ) {
                    return true
                }
            }
        }
        return false
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
        if (mapChangedFromUserInteraction) {
            // user changed map region
        }
    }
    
       func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if (mapChangedFromUserInteraction) {
            // user changed map region
            
            
            let annotations = mapView.visibleAnnotations()
            var bounceAnnotations = [BounceAnnotation]()
            for annotation in annotations {
                if annotation.isKind(of: BounceAnnotation.self) {
                    bounceAnnotations.append(annotation as! BounceAnnotation)
                }
            }
            
            //recalculate pin colors for annotations on screen
            let pCG = PinColorGenerator()
            colorDict = pCG.pinColorPicker(bounceAnnotations)
            
            mapView.removeAnnotations(annotations)
            
            createAnnotations()
            
//            print("There are \(annotations.count) Visible Annotations")
        }
    }
    
    
    

    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation.isKind(of: MKUserLocation.self)
        {
            return nil
        }
        let bounceAnnotation = annotation as! BounceAnnotation
        if let place = bounceAnnotation.place {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: place.entityId!)

            pinAnnotationView.pinTintColor = bounceAnnotation.color
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return pinAnnotationView
        }
        return nil
    }

    
    func topImageForPlaceDownloaded() {
        print("reloading map data")
        if mapView.selectedAnnotations.count > 0 {
            let currentAnnotation = mapView.selectedAnnotations[0] as? BounceAnnotation
            let place = currentAnnotation?.place
            let currentPinAnotation = mapView.view(for: currentAnnotation!)
            if let imageData = KinveyFetcher.sharedInstance.topPlaceImageData[place!.entityId!] {
                let image = UIImage(data: imageData as Data)
                let IC = ImageConfigurer()
                let rotatedImage = IC.rotateImage90Degress(image!)
                let topPostImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
                topPostImageView.contentMode = .scaleAspectFit
                topPostImageView.image  = rotatedImage
                currentPinAnotation!.leftCalloutAccessoryView = topPostImageView
//                        print(currentPinAnotation!.leftCalloutAccessoryView?.frame)
            }
        }
        
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////when should this data be reloaded?
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let selectedAnnotation = mapView.selectedAnnotations[0] as? BounceAnnotation {
            if !selectedAnnotation.isKind(of: MKUserLocation.self)
            {
                let currentPinAnotation = mapView.view(for: selectedAnnotation)
                if currentPinAnotation?.leftCalloutAccessoryView == nil {
                    let place = selectedAnnotation.place
                    let kF = KinveyFetcher.sharedInstance
                    kF.downloadTopImageForPlace(place!)
                }
                print("clicked pin")
            }
        }
        
    }
    
    
    func mapView(_ MapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            
            
            let annoation = mapView.selectedAnnotations[0] as! BounceAnnotation
            selectedPlace = annoation.place
            
            Answers.logContentView(withName: "ViewPlace",
                                           contentType: "Place",
                                           contentId: selectedPlace?.entityId,
                                           customAttributes: [
                                            "score": String(describing: selectedPlace?.placeScore)])
            
            performSegue(withIdentifier: "showPosts", sender: self)
        }
    }
    
    //MARK: - Location Manager
    
    func requestLocationData() {
        let location: PrivateResource = .location(.whenInUse)
        
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("updated location")
            let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(1.0, 1.0))//MKCoordinateSpanMake(0.005, 0.005))
            LocationFetcher.sharedInstance.currentLocation = location
            mapView.setRegion(region, animated: true)
            locationManager!.stopUpdatingLocation()
            locationManager = nil
//            fetchButtonTapped(UIBarButtonItem())
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPosts" {
            let DV = segue.destination as! PlaceVC
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
            for: .any,
            barMetrics: .default)
        
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    
    
    //MARK: User Logged in view customization
    
    func configureViewForUserStatus() {
        if FBSDKAccessToken.current() == nil || KCSUser.active() == nil {
            //the user is not logged in
            changeViewStateToNotLoggedIn()
        }
        else {
            changeViewStateToLoggedIn()
        }
    }
    
    func changeViewStateToNotLoggedIn() {
        composeButton.tintColor = UIColor(white: 1.0, alpha: 0.3)
    }
    
    func changeViewStateToLoggedIn(){
        composeButton.tintColor = UIColor(white: 1.0, alpha: 1.0)
    }
    
    
    func addAndShowAlertToGoToSettingsWithMessage(_ message:String) {
        let alertController = UIAlertController(title: "Hey!", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in}
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Login", style: .default) { (action) in
            self.settingsButtonPressed(UIBarButtonItem())
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true) {
        }
        
    }
    
    
    
    
    
}

extension MKMapView {
    func visibleAnnotations() -> [MKAnnotation] {
        return self.annotations(in: self.visibleMapRect).map { obj -> MKAnnotation in return obj as! MKAnnotation }
    }
}


