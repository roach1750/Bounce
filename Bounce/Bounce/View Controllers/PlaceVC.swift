//
//  PlaceVC.swift
//  Bounce
//
//  Created by Andrew Roach on 1/26/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



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
        NotificationCenter.default.addObserver(self, selector: #selector(PlaceVC.reloadTable), name: NSNotification.Name(rawValue: BOUNCETABLEDATAREADYNOTIFICATION), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlaceVC.refreshComplete), name: NSNotification.Name(rawValue: BOUNCETABLEDATAREADYNOTIFICATION), object: nil)
        configureViewColors()
        super.viewDidLoad()
    }
    
    func configureViewColors() {
        //Navigation Bar Colors
        
        //Toolbar Colors
        shareSettingToolbar.backgroundColor = BOUNCEPRIMARYCOLOR
        shareSettingSegmentedControl.tintColor = BOUNCESECONDARYCOLOR
        
        //Remove Line under Navigation Bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
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
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor ( red: 0.7885, green: 0.8121, blue: 0.9454, alpha: 1.0 )
        
        //Pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PlaceVC.pullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func pullToRefresh() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        kinveyFetcher.fetchUpdatedPostsForPlace(place!)
        
    }
    
    func refreshComplete() {
        refreshControl.endRefreshing()
        reloadTable()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
    
    @IBAction func sortingMethodSwitched(_ sender: UISegmentedControl) {
        reloadTable()
    }
    
    @IBAction func moreButtonPressed(_ sender: AnyObject) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        let currentPost = posts![((indexPath as NSIndexPath?)?.section)!]
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "Report", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "reportPostSegue", sender: currentPost)
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(reportAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    func getDataForTable() {
        kinveyFetcher.fetchPostsForPlace(place!)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let placesPost = posts {
            let currentPost = placesPost[(indexPath as NSIndexPath).section]
            let identifier = getIdentifierForCell(currentPost)
            let cell:PlaceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: identifier) as! PlaceTableViewCell
            
            
            //Coment
            cell.postCommentLabel.text = currentPost.postMessage
            
            //Image
            if  ((currentPost.postHasImage?.boolValue) != nil) {
                //If there is already an image downloaded:
                if let imageData = currentPost.postImageData {
                    let image = UIImage(data: imageData as Data)
                    let IC = ImageConfigurer()
                    let rotatedImage = IC.rotateImage90Degress(image!)
                    cell.postImageView?.image = rotatedImage
                    cell.postImageView?.contentMode = .scaleAspectFit
//                    print("loading image for cell # \(indexPath.section)")
                    
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
            cell.postScoreLabel.text = String(describing: currentPost.postScore!)
            
            let userDefaults = UserDefaults.standard
            
            if let increment = userDefaults.object(forKey: currentPost.postUniqueId!) as? Int {
                switch increment {
                case 1:
                    cell.postPlusButton.setTitleColor(BOUNCEORANGE, for: UIControlState())
                    cell.postPlusButton.isEnabled = false
                    cell.postMinusButton.isEnabled = false
                case -1:
                    cell.postMinusButton.setTitleColor(BOUNCEORANGE, for: UIControlState())
                    cell.postPlusButton.isEnabled = false
                    cell.postMinusButton.isEnabled = false
                default:
                    break
                }
            }
            cell.layoutMargins = UIEdgeInsets.zero
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
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
    

    func getIdentifierForCell(_ post: Post) -> String {
        
        if post.postHasImage == NSNumber(value: true as Bool) && post.postMessage != nil{
            tableView.estimatedRowHeight = 515.0
            return "commentAndPhoto"
        }
        else if post.postHasImage == NSNumber(value: true as Bool) {
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
    
    func timeSinceObjectWasCreated(_ timeInSeconds: Double) -> String{
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
    
    func convertToProperTense(_ time: String) -> String {
        if time.substring(to: time.characters.index(after: time.startIndex)) == "1" {
            return time.substring(to: time.characters.index(before: time.endIndex))
        }
        else {
            return time
        }
    }
    
    //MARK: Score Buttons
    
    @IBAction func scoreButtonPressed(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        let cell = tableView.cellForRow(at: indexPath!) as! PlaceTableViewCell
        
        let buttonTitle = sender.currentTitle
        let increment: Int
        
        switch(buttonTitle!) {
        case "+" :
            increment = 1
            cell.postPlusButton.setTitleColor(BOUNCEORANGE, for: UIControlState())
        case "-" :
            increment = -1
            cell.postMinusButton.setTitleColor(BOUNCEORANGE, for: UIControlState())
        default:
            increment = 0
        }
        
        let currentPost = posts![((indexPath as NSIndexPath?)?.section)!]
        let kUP = KinveyUploader()
        kUP.changeScoreForPost(currentPost,place: place!,increment: increment)
        
        let newScore = Int(currentPost.postScore!) + increment
        cell.postScoreLabel.text = String(newScore)
        cell.postPlusButton.isEnabled = false
        cell.postMinusButton.isEnabled = false
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(increment, forKey: currentPost.postUniqueId!)
    }
    
    
    
    
    
    //MARK: Tableview customization
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if posts?.count > 0 {
                tableView.backgroundView = nil
                return posts!.count
        }
        else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            noDataLabel.text = "No Post for this place...pull to refresh"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
            
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 15
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 15))
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reportPostSegue" {
            let DV = segue.destination as! ReportPostVC
            if let reportedPost = sender as? Post {
                DV.selectedPost = reportedPost
            }
        }
    }
    
    
    
}
