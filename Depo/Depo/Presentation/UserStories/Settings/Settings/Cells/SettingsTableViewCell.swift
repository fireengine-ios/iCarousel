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
        
//        self.addRoundedShadows(cornerRadius: 16,
//                               shadowColor: AppColor.viewShadowLight.cgColor,
//                               opacity: 0.8, radius: 6.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //let bgView = UIView()
        if (selected) {
            titleLabel.font = .appFont(.bold, size: 18)
            backgroundColor = ColorConstants.selectedCellBlueColor
        } else {
            titleLabel.font = .appFont(.regular, size: 18)
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
