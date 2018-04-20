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
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet weak var switcher: CustomSwitch!
    
    var model: AutoSyncModel?
    
    var delegate: AutoSyncSwitcherTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        
        titleLabel.textColor = ColorConstants.whiteColor
        titleLabel.font = .TurkcellSaturaDemFont(size: 18)
        
        subTitleLabel.textColor = ColorConstants.whiteColor
        subTitleLabel.font = .TurkcellSaturaBolFont(size: 14)
        
        separatorView.isHidden = true
    }
    
    func setup(with model: AutoSyncModel, setting: AutoSyncSetting) {
        self.model = model
        switcher.isOn = model.isSelected
        separatorView.isHidden = !model.isSelected
        
        titleLabel.text = model.titleString
        subTitleLabel.text = model.subTitleString
        switcher.isSelected = model.isSelected
    }
    
    func setColors(isFromSettings: Bool) {
        titleLabel.textColor = isFromSettings ? ColorConstants.textGrayColor : ColorConstants.whiteColor
        subTitleLabel.textColor = isFromSettings ? ColorConstants.textGrayColor : ColorConstants.whiteColor
        separatorView.backgroundColor = isFromSettings ? ColorConstants.textGrayColor : ColorConstants.whiteColor
    }
    
    @IBAction func onSwitcherValueChanged() {
        guard let model = model else {
            return
        }
        
        model.isSelected = switcher.isOn
        separatorView.isHidden = !switcher.isOn
        delegate?.onValueChanged(model: model, cell: self)
    }

}
