//
//  ReportPostVC.swift
//  Bounce
//
//  Created by Andrew Roach on 6/22/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit

class ReportPostVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var selectedPost: Post?
    let reasonsArray = ["I don't like this post.", "This post is inappropriate", "This post is spam"]
    
    override func viewDidLoad() {
        tableView.tableFooterView = UIView()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reportReason", forIndexPath: indexPath)
        cell.textLabel?.text = reasonsArray[indexPath.row]
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let kU = KinveyUploader()
        let reason = reasonsArray[indexPath.row]
        kU.reportPost(selectedPost!, reason: reason)
        navigationController?.popViewControllerAnimated(true)

    }
    
}
