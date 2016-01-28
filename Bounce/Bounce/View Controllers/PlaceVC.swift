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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTable", name: BOUNCETABLEDATAREADYNOTIFICATION, object: nil)
        super.viewDidLoad()
    }
    
    func reloadTable() {
        tableView.reloadData()
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
            let identifier = getIdentifierForCell(currentPost)
            print(identifier)
            let cell:PlaceTableViewCell = self.tableView.dequeueReusableCellWithIdentifier(identifier) as! PlaceTableViewCell
            cell.placeCommentLabel.text = currentPost.postMessage
            if currentPost.hasImage {
                if let imageData = currentPost.postImageData {
                    cell.imageView?.image = UIImage(data: imageData)
                }
                else {
                    let dm = DataModel()
                    dm.downloadImageForPost(currentPost)
                }
            }
            return cell
        }
        
        
        return UITableViewCell()
    }
    
    func getIdentifierForCell(post: Post) -> String {
        
        if post.hasImage == true && post.postMessage != nil{
            return "commentAndPhoto"
        }
        else if post.hasImage == true {
            return "photoOnly"
        }
        else if post.postMessage != nil {
            return "commentOnly"
        }
        else {
            return ""
        }
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
