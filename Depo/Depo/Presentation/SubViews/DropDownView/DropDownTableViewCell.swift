//
//  DropDownTableViewCell.swift
//  Depo
//
//  Created by Oleg on 05.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class DropDownTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleTextLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
        titleTextLabel.textColor = ColorConstants.darkBlueColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
