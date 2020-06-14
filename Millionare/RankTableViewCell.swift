//
//  RankTableViewCell.swift
//  Millionare
//
//  
//  Copyright © 2019 EE4304. All rights reserved.
//

import UIKit

class RankTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var rankLabel: UILabel!
    
    @IBOutlet var UserIcon: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
