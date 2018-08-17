//
//  CustomDetailsViewCell.swift
//  GeoTenX
//
//  Created by saadhvi on 8/14/18.
//  Copyright © 2018 Joshila. All rights reserved.
//

import UIKit

class CustomDetailsViewCell: UITableViewCell {

    @IBOutlet weak var ItemBkg: UIView!
   
    @IBOutlet weak var ItemDescription: UITextView!
    @IBOutlet weak var ItemName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
