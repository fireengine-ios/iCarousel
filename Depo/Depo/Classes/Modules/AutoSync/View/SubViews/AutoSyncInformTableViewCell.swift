//
//  AutoSyncInformTableViewCell.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class AutoSyncInformTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    class func reUseID()-> String{
        return "AutoSyncInformTableViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor.clear
        
        titleLabel.textColor = ColorConstants.whiteColor
        titleLabel.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 14)
    }
    
    func configurateCellWith(model: AutoSyncModel){
        titleLabel.text = model.titleString
        if (model.isSelected){
            iconImageView.image = UIImage(named: "AutoSyncIcon")
        }else{
            iconImageView.image = nil
        }
    }
    
}
