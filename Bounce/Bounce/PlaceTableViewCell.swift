//
//  PlaceTableViewCell.swift
//  Bounce
//
//  Created by Andrew Roach on 1/27/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class PlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var placeCommentLabel: UILabel!
    
    @IBOutlet weak var placeImageView: PFImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
