//
//  PlaceTableViewCell.swift
//  Bounce
//
//  Created by Andrew Roach on 1/27/16.
//  Copyright © 2016 Andrew Roach. All rights reserved.
//

import UIKit


class PlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var postCommentLabel: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var postCreationDate: UILabel!
    
    @IBOutlet weak var postPlusButton: UIButton!
    
    @IBOutlet weak var postMinusButton: UIButton!
    
    @IBOutlet weak var postScoreLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
