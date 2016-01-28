//
//  PlaceVC.swift
//  Bounce
//
//  Created by Andrew Roach on 1/26/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import Parse
class PlaceVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var place: Place? {
        didSet {
            self.title = place?.name
        }
    }
    
    override func viewDidLoad() {
        configureTableView()
        super.viewDidLoad()
    }
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor ( red: 0.9003, green: 0.5881, blue: 0.5432, alpha: 1.0 )
    }
    

    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let placesPost = place?.posts {
            let currentPost = placesPost[indexPath.section]
            let cell:PlaceTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("commentOnly") as! PlaceTableViewCell
            cell.placeCommentLabel.text = currentPost.postMessage
            
            return cell
        }
        
        
        return UITableViewCell()
    }
    
    //MARK: Tableview customization
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let placesPost = place?.posts {
            return placesPost.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 15
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 15))
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
}
