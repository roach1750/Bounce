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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportReason", for: indexPath)
        cell.textLabel?.text = reasonsArray[(indexPath as NSIndexPath).row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let kU = KinveyUploader()
        let reason = reasonsArray[(indexPath as NSIndexPath).row]
        kU.reportPost(selectedPost!, reason: reason)
        _ = navigationController?.popViewController(animated: true)

    }
    
}
