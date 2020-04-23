//
//  AutoSyncSettingsTableViewCell.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 2/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit


protocol AutoSyncSettingsTableViewCellDelegate: AutoSyncCellDelegate {
    func didChange(setting: AutoSyncSetting)
}

final class AutoSyncSettingsTableViewCell: AutoSyncTableViewCell {
    
    private let options: [AutoSyncOption] = [.never, .wifiOnly, .wifiAndCellular]
    
    @IBOutlet private weak var optionsStackView: UIStackView!
    @IBOutlet private var optionsViews: [AutoSyncSettingsOptionView]!
    
    @IBOutlet private var optionSeparators: [UIView]!
    
    private weak var delegate: AutoSyncSettingsTableViewCellDelegate?
    private var model: AutoSyncSettingModel?
    
    //MARK: - AutoSyncCell
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .white
        optionSeparators.forEach { $0.backgroundColor = ColorConstants.profileGrayColor }
    }
    
    func setup(with model: AutoSyncModel, delegate: AutoSyncCellDelegate?) {
        self.model = model as? AutoSyncSettingModel
        self.delegate = delegate as? AutoSyncSettingsTableViewCellDelegate
        updateViews()
    }

    private func updateViews() {
        guard let setting = model?.setting else {
            return
        }
        
        for (option, view) in zip(options, optionsViews) {
            view.setup(with: option, isSelected: setting.option == option)
            view.delegate = self
        }
    }
    
    func didSelect() { }
}

//MARK: - AutoSyncSettingsOptionViewDelegate

extension AutoSyncSettingsTableViewCell: AutoSyncSettingsOptionViewDelegate {
    func didSelect(option: AutoSyncOption) {
        model?.setting?.option = option
        updateViews()
        
        if let setting = model?.setting {
            delegate?.didChange(setting: setting)
        }
    }
}
