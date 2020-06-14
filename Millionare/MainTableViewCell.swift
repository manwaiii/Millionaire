//
//  MainTableViewCell.swift
//  Millionare
//
//  Created by Michael Chan on 26/11/2019.
//  Copyright © 2019 EE4304. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet var value: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var categoryName: UILabel!
    @IBOutlet var categoryImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
