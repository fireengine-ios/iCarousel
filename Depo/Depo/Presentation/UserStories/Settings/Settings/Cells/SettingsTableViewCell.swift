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
        self.backgroundColor = AppColor.secondaryBackground.color
        titleLabel.textColor = AppColor.label.color
        titleLabel.font = .appFont(.regular, size: 14)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //let bgView = UIView()
        if (selected) {
            titleLabel.font = .appFont(.regular, size: 14)
            backgroundColor = ColorConstants.selectedCellBlueColor
        } else {
            titleLabel.font = .appFont(.regular, size: 14)
            backgroundColor = AppColor.secondaryBackground.color
        }
        //backgroundView = bgView
        // Configure the view for the selected state
    }
    
    func setTextForLabel(titleText: String, needShowSeparator: Bool) {
        titleLabel.text = titleText
        separatorView.isHidden = !needShowSeparator
    }
    
}
