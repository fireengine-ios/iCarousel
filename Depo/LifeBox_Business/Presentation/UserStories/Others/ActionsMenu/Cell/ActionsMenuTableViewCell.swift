//
//  ActionsMenuTableViewCell.swift
//  Depo
//
//  Created by Oleg on 17.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class ActionsMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.textColor = ColorConstants.textGrayColor
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 19)
        separatorView.isHidden = !Device.isIpad
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if (selected) {
            titleLabel.textColor = ColorConstants.selectedBottomBarButtonColor
        } else {
            titleLabel.textColor = ColorConstants.textGrayColor
        }
    }
    
}
