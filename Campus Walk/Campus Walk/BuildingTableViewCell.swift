//
//  BuildingTableViewCell.swift
//  Campus Walk
//
//  Created by Kevin Ramsussen on 10/14/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit

class BuildingTableViewCell: UITableViewCell {

    @IBOutlet weak var builtLabel: UILabel!
    @IBOutlet weak var buildingName: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
