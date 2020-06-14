//
//  BlogTableViewCell.swift
//  Millionare
//
//  Created by Michael Chan on 13/11/2019.
//  Copyright © 2019 EE4304. All rights reserved.
//

import UIKit

class BlogTableViewCell: UITableViewCell {

    @IBOutlet var userIcon: UIImageView!
    @IBOutlet var blogTitle: UILabel!
    @IBOutlet var blogIcon: UIImageView!
    @IBOutlet var username: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
