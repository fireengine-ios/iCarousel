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
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var notificationCount: UILabel!
    

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
        
        if Device.isIpad, selected {
            backgroundColor = ColorConstants.selectedCellBlueColor
        }
        //backgroundView = bgView
        // Configure the view for the selected state
    }
    
    func setTextForLabel(titleText: String, needShowSeparator: Bool, background: UIColor? = nil) {
        titleLabel.text = titleText
        separatorView.isHidden = !needShowSeparator
        self.backgroundColor = background ?? AppColor.secondaryBackground.color
    }
    
    func configureNotification(isHidden: Bool, notifCount: Int) {
        notificationImage.isHidden = isHidden || notifCount == 0
        notificationCount.isHidden = isHidden || notifCount == 0
        notificationCount.text = "\(notifCount)"
    }
}
