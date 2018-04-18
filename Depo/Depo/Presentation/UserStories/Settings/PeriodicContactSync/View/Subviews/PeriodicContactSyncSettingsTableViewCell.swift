//
//  PeriodicContactSyncSettingsTableViewCell.swift
//  Depo
//
//  Created by Brothers Harhun on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol PeriodicContactSyncSettingsTableViewCellDelegate {
    func didChangeTime(setting: AutoSyncSetting)
    func onValueChanged(model: AutoSyncModel, cell: PeriodicContactSyncSettingsTableViewCell)    
}

class PeriodicContactSyncSettingsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var switcher: CustomSwitch!
    @IBOutlet private var optionsViews: [AutoSyncSettingsOptionView]!
    @IBOutlet private weak var optionsStackView: UIStackView!
    @IBOutlet private var optionSeparators: [UIView]!
    
    private let options: [AutoSyncOption] = [.daily, .weekly, .monthly]
    
    private var model: AutoSyncModel?
    
    private var isFromSettings: Bool = false
    
    var delegate: PeriodicContactSyncSettingsTableViewCellDelegate?
    
    private var autoSyncSetting = AutoSyncSetting(syncItemType: .time, option: .daily) {
        didSet {
            if autoSyncSetting != oldValue {
                updateViews()
                delegate?.didChangeTime(setting: autoSyncSetting)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        
        titleLabel.textColor = ColorConstants.whiteColor
        titleLabel.font = .TurkcellSaturaDemFont(size: 18)
        
        ///iPad, iOS < 10, prevent white color
        ///https://stackoverflow.com/questions/27551291/uitableview-backgroundcolor-always-white-on-ipad
        backgroundColor = contentView.backgroundColor
        updateViews()
    }
    
    func setup(with model: AutoSyncModel, setting: AutoSyncSetting) {
        self.model = model
        switcher.isOn = model.isSelected
        
        titleLabel.text = model.titleString
        switcher.isSelected = model.isSelected
        
        for view in optionsViews {
            view.setColors(isFromSettings: true)
        }
        
        optionsStackView.isHidden = !model.isSelected
        autoSyncSetting = setting
    }
    
    func setColors(isFromSettings: Bool) {
        self.isFromSettings = isFromSettings
        titleLabel.textColor = ColorConstants.textGrayColor
        
        for view in optionsViews {
            view.delegate = self
            view.setColors(isFromSettings: isFromSettings)
        }
        
        for separator in optionSeparators {
            separator.backgroundColor = ColorConstants.lightGrayColor
        }
    }
    
    private func updateViews() {
        for (option, view) in zip(options, optionsViews) {
            view.setup(with: option, isSelected: autoSyncSetting.option == option)
            view.delegate = self
            view.setColors(isFromSettings: isFromSettings)
        }
        
        optionsStackView.isHidden = !switcher.isOn
    }
    
    @IBAction private func onSwitcherValueChanged() {
        guard let model = model else {
            return
        }
        
        model.isSelected = switcher.isOn
        delegate?.onValueChanged(model: model, cell: self)
        optionsStackView.isHidden = !switcher.isOn
    }
    
}

// MARK: - AutoSyncSettingsOptionViewDelegate

extension PeriodicContactSyncSettingsTableViewCell: AutoSyncSettingsOptionViewDelegate {
    func didSelect(option: AutoSyncOption) {
        autoSyncSetting.option = option
        updateViews()
    }
}
