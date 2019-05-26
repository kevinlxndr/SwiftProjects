//
//  ParkTableViewCell.swift
//  Parks
//
//  Created by Kevin Ramsussen on 9/29/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit

class ParkTableViewCell: UITableViewCell {


    
    @IBOutlet weak var parkCaptionLabel: UILabel!
    @IBOutlet weak var parkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
