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
    
    var place: Place? {
        didSet {
            self.title = place?.placeName
            let kF = KinveyFetcher.sharedInstance
            kF.fetchPostsForPlace(place!)
        }
    }
    
    var posts:[Post]?
    
    override func viewDidLoad() {
        configureTableView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaceVC.reloadTable), name: BOUNCETABLEDATAREADYNOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaceVC.refreshComplete), name: BOUNCETABLEDATARELOADCOMPLETE, object: nil)
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
        posts = KinveyFetcher.sharedInstance.postsData
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
        //        let pf = ParseFetcher()
        //        pf.fetchPostForPlace(place!)
    }
    
    func refreshComplete() {
        refreshControl.endRefreshing()
        reloadTable()
    }
    
    
    @IBAction func sortingMethodSwitched(sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            getDataForTable(BOUNCEFRIENDSONLYSHARESETTING)
            break
        case 1:
            getDataForTable(BOUNCEEVERYONESHARESETTING)
            break
        default:
            break
        }
    }
    
    
    func getDataForTable(shareSetting: String) {
        //        let dm = DataModel()
        //        posts = dm.fetchPostsForPlaceWithShareSetting(shareSetting, place: place!)
        //        reloadTable()
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
                    
                }
                else {
                    //There isn't an image downloaded yet
                    cell.postImageView.image = UIImage(named: "cameraImage")
                    //                    KinveyFetcher.sharedInstance.fetchImageForPost(currentPost)
                }
            }
            
            //Creation Date
            //            cell.postCreationDate.text = timeSinceObjectWasCreated(abs(currentPost.postCreationDate.timeIntervalSinceNow))
            cell.postCreationDate.text = "error"
            
            //Score
            cell.postScoreLabel.text = String(currentPost.postScore!)
            
            
            cell.layoutMargins = UIEdgeInsetsZero
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            
            if cell.frame.width != view.frame.width {
                reloadTable()
            }
            
            
            return cell
        }
        
        
        return UITableViewCell()
    }
    
    func getIdentifierForCell(post: Post) -> String {
        
        if post.postHasImage == true && post.postMessage != nil{
            tableView.estimatedRowHeight = 515.0
            return "commentAndPhoto"
        }
        else if post.postHasImage == true {
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
        
        let buttonTitle = sender.currentTitle
        let increment: Int
        
        switch(buttonTitle!) {
        case "+" : increment = 1
        case "-" : increment = -1
        default: increment = 0
        }
        
        let point = sender.convertPoint(CGPointZero, toView: tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        let currentPost = posts![(indexPath?.row)!]
        
        let kUP = KinveyUploader()
        kUP.changeScoreForPost(currentPost,increment: increment)
        

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentPost = posts![indexPath.row]
        let kF = KinveyFetcher()
        kF.fetchScoreForPost(currentPost)
    }
    

    
    //MARK: Tableview customization
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let allPost = posts {
            return allPost.count
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
