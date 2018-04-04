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
    @IBOutlet private var optionsViews: [AutoSyncSettingsOptionView]!
    @IBOutlet private weak var optionsStackView: UIStackView!
    @IBOutlet private var optionSeparators: [UIView]!
    
    private let options: [AutoSyncOption] = [.daily, .weekly, .monthly]
    
    var model: AutoSyncModel?
    
    var delegate: AutoSyncSwitcherTableViewCellDelegate?
    
    private var autoSyncSetting = AutoSyncSetting(syncItemType: .time, option: .daily) {
        didSet {
            if autoSyncSetting != oldValue {
                updateViews()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        
        titleLabel.textColor = ColorConstants.whiteColor
        titleLabel.font = .TurkcellSaturaDemFont(size: 18)
        
        subTitleLabel.textColor = ColorConstants.whiteColor
        subTitleLabel.font = .TurkcellSaturaBolFont(size: 14)
        
        separatorView.isHidden = true
        
        updateViews()
    }
    
    func setup(with model: AutoSyncModel) {
        self.model = model
        switcher.isOn = model.isSelected
        separatorView.isHidden = !model.isSelected
        
        titleLabel.text = model.titleString
        subTitleLabel.text = model.subTitleString
        switcher.isSelected = model.isSelected
        
        optionsStackView.isHidden = !model.isSelected
    }
    
    func setColors(isFromSettings: Bool) {
        titleLabel.textColor = isFromSettings ? ColorConstants.textGrayColor : ColorConstants.whiteColor
        subTitleLabel.textColor = isFromSettings ? ColorConstants.textGrayColor : ColorConstants.whiteColor
        separatorView.backgroundColor = isFromSettings ? ColorConstants.textGrayColor : ColorConstants.whiteColor
        
        for view in optionsViews {
            view.delegate = self
            view.setColors(isFromSettings: isFromSettings)
        }
        
        for separator in optionSeparators {
            separator.backgroundColor = isFromSettings ? ColorConstants.lightGrayColor : ColorConstants.whiteColor
        }
    }
    
    @IBAction func onSwitcherValueChanged() {
        guard let model = model else {
            return
        }
        
        model.isSelected = switcher.isOn
        separatorView.isHidden = !switcher.isOn
        delegate?.onValueChanged(model: model, cell: self)
    }
    
    func updateViews() {
        for (option, view) in zip(options, optionsViews) {
            view.setup(with: option, isSelected: autoSyncSetting.option == option)
            view.delegate = self
        }
        
        optionsStackView.isHidden = !switcher.isOn
    }

}

// MARK: - AutoSyncSettingsOptionViewDelegate

extension AutoSyncSwitcherTableViewCell: AutoSyncSettingsOptionViewDelegate {
    func didSelect(option: AutoSyncOption) {
        autoSyncSetting.option = option
        updateViews()
    }
}

