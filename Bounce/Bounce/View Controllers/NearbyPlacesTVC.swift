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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let placesArray = LocationFetcher.sharedInstance.placeArray {
            return placesArray.count
        }
        return 0
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("placeCell", forIndexPath: indexPath)
        if let placesArray = LocationFetcher.sharedInstance.placeArray {
            let place = placesArray[indexPath.row]
            cell.textLabel?.text = place.name
            
            let roundedDistance = 50 * Int(round(place.distanceFromUser! / 50.0))
            cell.detailTextLabel?.text = String(roundedDistance) + " feet away"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let placesArray = LocationFetcher.sharedInstance.placeArray {
            let place = placesArray[indexPath.row]
            LocationFetcher.sharedInstance.selectedPlace = place
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        navigationController?.popToRootViewControllerAnimated(true)
    }


}
