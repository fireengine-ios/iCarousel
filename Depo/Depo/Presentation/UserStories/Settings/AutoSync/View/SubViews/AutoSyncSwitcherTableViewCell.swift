//
//  AutoSyncSwitcherTableViewCell.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol AutoSyncSwitcherTableViewCellDelegate {
    
    func onValueChanged(model: AutoSyncModel, cell: AutoSyncSwitcherTableViewCell)
    
}

class AutoSyncSwitcherTableViewCell: UITableViewCell {
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var switcher: CustomSwitch!
    var model: AutoSyncModel?
    
    var delegate: AutoSyncSwitcherTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        
        titleLabel.textColor = ColorConstants.whiteColor
        titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 18)
        
        subTitleLabel.textColor = ColorConstants.whiteColor
        subTitleLabel.font = UIFont.TurkcellSaturaBolFont(size: 14)
        
        separatorView.isHidden = true
    }
    
    func configurateCellWith(model: AutoSyncModel) {
        self.model = model
        switcher.isOn = model.isSelected
        
        titleLabel.text = model.titleString
        subTitleLabel.text = model.subTitleString
        switcher.isSelected = model.isSelected
    }
    
    func setColors(isFromSettings: Bool) {
        titleLabel.textColor = isFromSettings ? ColorConstants.textGrayColor : ColorConstants.whiteColor
        subTitleLabel.textColor = isFromSettings ? ColorConstants.textGrayColor : ColorConstants.whiteColor
    }
    
    @IBAction func onSwitcherValueChanged() {
        let newModel = AutoSyncModel(model: self.model!, selected: self.switcher.isOn)
        model = newModel
        delegate?.onValueChanged(model: model!, cell: self)
    }

}
