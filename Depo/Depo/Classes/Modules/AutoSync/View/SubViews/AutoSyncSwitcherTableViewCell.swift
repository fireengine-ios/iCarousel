//
//  AutoSyncSwitcherTableViewCell.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class AutoSyncSwitcherTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var switcher: UISwitch!

    class func reUseID()-> String{
        return "AutoSyncSwitcherTableViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        
        titleLabel.textColor = ColorConstants.whiteColor
        titleLabel.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 18)
        
        subTitleLabel.textColor = ColorConstants.whiteColor
        subTitleLabel.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 14)
        
        switcher.onTintColor = ColorConstants.switcherGreenColor
        switcher.tintColor = ColorConstants.switcherGrayColor
        switcher.layer.cornerRadius = 16
        switcher.backgroundColor = ColorConstants.switcherGrayColor
    }
    
    func configurateCellWith(model: AutoSyncModel){
        titleLabel.text = model.titleString
        subTitleLabel.text = model.subTitleString
        switcher.isSelected = model.isSelected
    }

}
