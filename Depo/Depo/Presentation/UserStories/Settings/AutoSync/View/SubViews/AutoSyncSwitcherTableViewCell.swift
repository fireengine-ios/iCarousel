//
//  AutoSyncSwitcherTableViewCell.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol AutoSyncSwitcherTableViewCellDelegate: class {
    func onValueChanged(model: AutoSyncModel)
}

class AutoSyncSwitcherTableViewCell: UITableViewCell {
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet weak var switcher: CustomSwitch!
    
    var model: AutoSyncModel?
    
    weak var delegate: AutoSyncSwitcherTableViewCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        
        titleLabel.font = .TurkcellSaturaDemFont(size: 18)
        subTitleLabel.font = .TurkcellSaturaBolFont(size: 14)
        
        separatorView.isHidden = true
        
        setColors()
    }
    
    func setup(with model: AutoSyncModel, setting: AutoSyncSetting) {
        self.model = model
        switcher.isOn = model.isSelected
        separatorView.isHidden = !model.isSelected
        
        titleLabel.text = model.titleString
        subTitleLabel.text = model.subTitleString
        switcher.isSelected = model.isSelected
    }
    
    // MARK: Private
    
    private func setColors() {
        titleLabel.textColor = ColorConstants.textGrayColor
        subTitleLabel.textColor = ColorConstants.textGrayColor
        separatorView.backgroundColor = ColorConstants.textGrayColor
    }
    
    @IBAction func onSwitcherValueChanged() {
        guard let model = model else {
            return
        }
        
        model.isSelected = switcher.isOn
        separatorView.isHidden = !switcher.isOn
        delegate?.onValueChanged(model: model)
    }

}
