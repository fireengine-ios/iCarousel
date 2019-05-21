//
//  PeriodicContactSyncSettingsTableViewCell.swift
//  Depo
//
//  Created by Brothers Harhun on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol PeriodicContactSyncSettingsTableViewCellDelegate: class {
    func didChangeTime(setting: PeriodicContactsSyncSetting)
    func onValueChanged(cell: PeriodicContactSyncSettingsTableViewCell)
}

class PeriodicContactSyncSettingsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var switcher: CustomSwitch!
    @IBOutlet private var optionsViews: [PeriodicContactsSyncSettingsOptionView]!
    @IBOutlet private weak var optionsStackView: UIStackView!
    @IBOutlet private var optionSeparators: [UIView]!
    @IBOutlet private weak var separatorView: UIView!
    
    private let options: [PeriodicContactsSyncOption] = [.daily, .weekly, .monthly]
    
    private var model: PeriodContactsSyncModel?
    
    private var isFromSettings: Bool = false
    
    weak var delegate: PeriodicContactSyncSettingsTableViewCellDelegate?
    
    private var periodicContactSyncSetting = PeriodicContactsSyncSetting(option: .daily) {
        didSet {
            if periodicContactSyncSetting != oldValue {
                updateViews()
                delegate?.didChangeTime(setting: periodicContactSyncSetting)
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
    
    func setup(with model: PeriodContactsSyncModel, setting: PeriodicContactsSyncSetting) {
        self.model = model
        switcher.isOn = model.isSelected
        
        titleLabel.text = model.titleString
        switcher.isSelected = model.isSelected
        
        for view in optionsViews {
            view.setColors()
        }
        
        optionsStackView.isHidden = !model.isSelected
        separatorView.isHidden = !model.isSelected
        periodicContactSyncSetting = setting
    }
    
    func setColors(isFromSettings: Bool) {
        self.isFromSettings = isFromSettings
        titleLabel.textColor = ColorConstants.textGrayColor
        
        for view in optionsViews {
            view.delegate = self
            view.setColors()
        }
        
        for separator in optionSeparators {
            separator.backgroundColor = ColorConstants.lightGrayColor
        }
    }
    
    private func updateViews() {
        for (option, view) in zip(options, optionsViews) {
            view.setup(with: option, isSelected: periodicContactSyncSetting.option == option)
            view.delegate = self
            view.setColors()
        }
        
        optionsStackView.isHidden = !switcher.isOn
    }
    
    @IBAction private func onSwitcherValueChanged() {
        guard let model = model else {
            return
        }
        
        model.isSelected = switcher.isOn
        delegate?.onValueChanged(cell: self)
        optionsStackView.isHidden = !switcher.isOn
        separatorView.isHidden = !switcher.isOn
    }
    
}

// MARK: - AutoSyncSettingsOptionViewDelegate

extension PeriodicContactSyncSettingsTableViewCell: PeriodicContactsSyncSettingsOptionViewDelegate {
    func didSelect(option: PeriodicContactsSyncOption) {
        periodicContactSyncSetting.option = option
        updateViews()
    }
}
