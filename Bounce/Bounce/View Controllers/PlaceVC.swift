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
        tableView.backgroundColor = UIColor ( red: 0.7885, green: 0.8121, blue: 0.9454, alpha: 1.0 )

    }
    

    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let placesPost = place?.posts {
            let currentPost = placesPost[indexPath.section]
            let identifier = getIdentifierForCell(currentPost)
            let cell:PlaceTableViewCell = self.tableView.dequeueReusableCellWithIdentifier(identifier) as! PlaceTableViewCell

            
            //Coment
            cell.postCommentLabel.text = currentPost.postMessage
            
            //Image
            if currentPost.hasImage {
                if let imageData = currentPost.postImageData {
                    let image = UIImage(data: imageData)
//                    let imageCropper = ImageResizer()
//                    let rotatedImage = imageCropper.rotateImage90Degress(image!)
                    cell.postImageView?.image = image
                    cell.postImageView?.contentMode = .ScaleAspectFit

                }
                else {
                    let dm = DataModel()
                    dm.downloadImageForPost(currentPost)
                    cell.postImageView?.image = UIImage(named: "CameraImage")
                }
            }
            
            //Creation Date 
            cell.postCreationDate.text = timeSinceObjectWasCreated(abs(currentPost.postCreationDate.timeIntervalSinceNow))
            
            //Score
            cell.postScoreLabel.text = String(currentPost.postScore)
            
            
            cell.layoutMargins = UIEdgeInsetsZero
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
        
        
        return UITableViewCell()
    }
    
    func getIdentifierForCell(post: Post) -> String {
        
        if post.hasImage == true && post.postMessage != nil{
            tableView.estimatedRowHeight = 515.0
            return "commentAndPhoto"
        }
        else if post.hasImage == true {
            tableView.estimatedRowHeight = 415.0
            return "photoOnly"
        }
        else if post.postMessage != nil {
            tableView.estimatedRowHeight = 100.0
            return "commentOnly"
        }
        else {
            return ""
        }
    }
    
    func timeSinceObjectWasCreated(timeInSeconds: Double) -> String{
        let timeInMinutes = timeInSeconds / 60
        let timeInHours = timeInMinutes / 60
        
        if timeInSeconds >= 0 && timeInMinutes < 1{
            return convertToProperTense(String(format: "%0.0f", timeInSeconds) + " seconds")
        }
            
        else if timeInMinutes >= 1 && timeInMinutes < 60{
            return convertToProperTense(String(format: "%0.0f", timeInMinutes) + " minutes")
        }
            
        else {
            return convertToProperTense(String(format: "%0.0f", timeInHours) + " hours")
        }
        
    }
    
    func convertToProperTense(time: String) -> String {
        if time.substringToIndex(time.startIndex.successor()) == "1" {
            return time.substringToIndex(time.endIndex.predecessor())
        }
        else {
            return time
        }
    }
    
    //MARK: Score Buttons
    
    
    @IBAction func plusButtonPressed(sender: UIButton) {
        
        let point = sender.convertPoint(CGPointZero, toView: tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        if let currentPost = place?.posts[(indexPath?.row)!] {
            let dm = DataModel()
            dm.incrementScoreForObject(currentPost, amount: 1)
        }
        
        
        
    }
    
    
    @IBAction func minusButtonPressed(sender: UIButton) {
        
        
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
