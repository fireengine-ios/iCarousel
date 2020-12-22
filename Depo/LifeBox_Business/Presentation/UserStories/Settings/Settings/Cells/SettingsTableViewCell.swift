//
//  SettingsTableViewCell.swift
//  Depo
//
//  Created by Oleg on 07.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.textColor = ColorConstants.textGrayColor
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //let bgView = UIView()
        if (selected) {
            titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
            backgroundColor = ColorConstants.selectedCellBlueColor
        } else {
            titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
            backgroundColor = ColorConstants.whiteColor
        }
        //backgroundView = bgView
        // Configure the view for the selected state
    }
    
    func setTextForLabel(titleText: String, needShowSeparator: Bool) {
        titleLabel.text = titleText
        separatorView.isHidden = !needShowSeparator
    }
    
}
