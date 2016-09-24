//
//  NearbyPlacesTVC.swift
//  Bounce
//
//  Created by Andrew Roach on 1/18/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit

class NearbyPlacesTVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let placesArray = LocationFetcher.sharedInstance.placeArray {
            return placesArray.count
        }
        return 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)
        if let placesArray = LocationFetcher.sharedInstance.placeArray {
            let place = placesArray[(indexPath as NSIndexPath).row]
            cell.textLabel?.text = place.name
            
            let roundedDistance = 50 * Int(round(place.distanceFromUser! / 50.0))
            cell.detailTextLabel?.text = String(roundedDistance) + " feet away"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let placesArray = LocationFetcher.sharedInstance.placeArray {
            let place = placesArray[(indexPath as NSIndexPath).row]
            LocationFetcher.sharedInstance.selectedPlace = place
        }
        tableView.deselectRow(at: indexPath, animated: true)
        _ = navigationController?.popToRootViewController(animated: true)
    }


}
