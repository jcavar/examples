//
//  CustomTableViewCell.swift
//  GenericTableView
//
//  Created by Josip Cavar on 18/04/15.
//  Copyright (c) 2015 Josip Cavar. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
