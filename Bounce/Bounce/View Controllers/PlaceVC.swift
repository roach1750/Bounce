//
//  PlaceVC.swift
//  Bounce
//
//  Created by Andrew Roach on 1/26/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit


class PlaceVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shareSettingToolbar: UIToolbar!
    @IBOutlet weak var shareSettingSegmentedControl: UISegmentedControl!
    
    var refreshControl: UIRefreshControl!
    let kinveyFetcher = KinveyFetcher.sharedInstance
    
    
    var place: Place? {
        didSet {
            self.title = place?.placeName
            kinveyFetcher.fetchPostsForPlace(place!)
        }
    }
    
    var posts:[Post]?
    
    override func viewDidLoad() {
        tableView.dataSource = nil
        configureTableView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaceVC.reloadTable), name: BOUNCETABLEDATAREADYNOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaceVC.refreshComplete), name: BOUNCETABLEDATAREADYNOTIFICATION, object: nil)
        configureViewColors()
        super.viewDidLoad()
    }
    
    func configureViewColors() {
        //Navigation Bar Colors
        
        //Toolbar Colors
        shareSettingToolbar.backgroundColor = BOUNCEPRIMARYCOLOR
        shareSettingSegmentedControl.tintColor = BOUNCESECONDARYCOLOR
        
        //Remove Line under Navigation Bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func reloadTable() {
        tableView.dataSource = self
        switch shareSettingSegmentedControl.selectedSegmentIndex {
        case 0:
            posts = kinveyFetcher.friendsOnlyPostData
        case 1:
            posts = kinveyFetcher.everyonePostData
        default:
            return
        }
        tableView.reloadData()
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.reloadData()
    }
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor ( red: 0.7885, green: 0.8121, blue: 0.9454, alpha: 1.0 )
        
        //Pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PlaceVC.pullToRefresh), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func pullToRefresh() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        kinveyFetcher.fetchUpdatedPostsForPlace(place!)
        
    }
    
    func refreshComplete() {
        refreshControl.endRefreshing()
        reloadTable()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
    }
    
    
    @IBAction func sortingMethodSwitched(sender: UISegmentedControl) {
        reloadTable()
    }
    
    @IBAction func moreButtonPressed(sender: AnyObject) {
        let point = sender.convertPoint(CGPointZero, toView: tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        let currentPost = posts![(indexPath?.section)!]
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        let reportAction = UIAlertAction(title: "Report", style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("reportPostSegue", sender: currentPost)
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(reportAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    func getDataForTable() {
        kinveyFetcher.fetchPostsForPlace(place!)
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let placesPost = posts {
            let currentPost = placesPost[indexPath.section]
            let identifier = getIdentifierForCell(currentPost)
            let cell:PlaceTableViewCell = self.tableView.dequeueReusableCellWithIdentifier(identifier) as! PlaceTableViewCell
            
            
            //Coment
            cell.postCommentLabel.text = currentPost.postMessage
            
            //Image
            if  ((currentPost.postHasImage?.boolValue) != nil) {
                //If there is already an image downloaded:
                if let imageData = currentPost.postImageData {
                    let image = UIImage(data: imageData)
                    let IC = ImageConfigurer()
                    let rotatedImage = IC.rotateImage90Degress(image!)
                    cell.postImageView?.image = rotatedImage
                    cell.postImageView?.contentMode = .ScaleAspectFit
                    print("loading image for cell # \(indexPath.section)")
                    
                }
                else {
                    //There isn't an image downloaded yet
                    cell.postImageView.image = UIImage(named: "cameraImage")
                    //                    KinveyFetcher.sharedInstance.fetchImageForPost(currentPost)
                }
            }
            
            //Creation Date
            cell.postCreationDate.text = timeSinceObjectWasCreated(abs(currentPost.postCreationDate!.timeIntervalSinceNow))
            
            //Score
            cell.postScoreLabel.text = String(currentPost.postScore!)
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            if let increment = userDefaults.objectForKey(currentPost.postUniqueId!) as? Int {
                switch increment {
                case 1:
                    cell.postPlusButton.setTitleColor(BOUNCEORANGE, forState: .Normal)
                    cell.postPlusButton.enabled = false
                    cell.postMinusButton.enabled = false
                case -1:
                    cell.postMinusButton.setTitleColor(BOUNCEORANGE, forState: .Normal)
                    cell.postPlusButton.enabled = false
                    cell.postMinusButton.enabled = false
                default:
                    break
                }
            }
            cell.layoutMargins = UIEdgeInsetsZero
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
//            
//            print(cell.frame.width)
//            
//            if cell.frame.width != view.frame.width {
////                reloadTable()
//            }
//            
//            
            return cell
        }
        
        
        return UITableViewCell()
    }
    

    func getIdentifierForCell(post: Post) -> String {
        
        if post.postHasImage == NSNumber(bool: true) && post.postMessage != nil{
            tableView.estimatedRowHeight = 515.0
            return "commentAndPhoto"
        }
        else if post.postHasImage == NSNumber(bool: true) {
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
    
    @IBAction func scoreButtonPressed(sender: UIButton) {
        let point = sender.convertPoint(CGPointZero, toView: tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        let cell = tableView.cellForRowAtIndexPath(indexPath!) as! PlaceTableViewCell
        
        let buttonTitle = sender.currentTitle
        let increment: Int
        
        switch(buttonTitle!) {
        case "+" :
            increment = 1
            cell.postPlusButton.setTitleColor(BOUNCEORANGE, forState: .Normal)
        case "-" :
            increment = -1
            cell.postMinusButton.setTitleColor(BOUNCEORANGE, forState: .Normal)
        default:
            increment = 0
        }
        
        let currentPost = posts![(indexPath?.section)!]
        let kUP = KinveyUploader()
        kUP.changeScoreForPost(currentPost,increment: increment)
        
        let newScore = Int(currentPost.postScore!) + increment
        cell.postScoreLabel.text = String(newScore)
        cell.postPlusButton.enabled = false
        cell.postMinusButton.enabled = false
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(increment, forKey: currentPost.postUniqueId!)
    }
    
    
    
    
    
    //MARK: Tableview customization
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if posts?.count > 0 {
                tableView.backgroundView = nil
                return posts!.count
        }
        else {
            let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height))
            noDataLabel.text = "No Post for this place...pull to refresh"
            noDataLabel.textColor = UIColor.blackColor()
            noDataLabel.textAlignment = .Center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .None
            
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
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "reportPostSegue" {
            let DV = segue.destinationViewController as! ReportPostVC
            if let reportedPost = sender as? Post {
                DV.selectedPost = reportedPost
            }
        }
    }
    
    
    
}
