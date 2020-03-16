//
//  AutoSyncSettingsTableViewCell.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 2/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit


protocol AutoSyncSettingsTableViewCellDelegate: class {
    func didChange(setting: AutoSyncSetting)
    func shouldChangeHeight(toExpanded: Bool, cellType: AutoSyncSettingsRowType)
}


final class AutoSyncSettingsTableViewCell: UITableViewCell {
    weak var delegate: AutoSyncSettingsTableViewCellDelegate?
    
    @IBOutlet private weak var optionsStackView: UIStackView!
    @IBOutlet private weak var dropDownArrow: UIImageView!
    @IBOutlet private weak var optionLabel: UILabel! 
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var expandButton: UIButton!
    @IBOutlet private var optionsViews: [AutoSyncSettingsOptionView]!
    
    @IBOutlet private var optionSeparators: [UIView]!
    @IBOutlet private weak var cellSeparator: UIView!
    
    
    private var autoSyncModel: AutoSyncModel?
    
    private var autoSyncSetting = AutoSyncSetting(syncItemType: .photo, option: .wifiOnly) {
        didSet {
            if autoSyncSetting != oldValue {
                autoSyncModel?.syncSetting = autoSyncSetting
                updateViews()
                delegate?.didChange(setting: autoSyncSetting)
            }
        }
    }
    
    private let options: [AutoSyncOption] = [.never, .wifiOnly, .wifiAndCellular]
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ///iPad, iOS < 10, prevent white color
        ///https://stackoverflow.com/questions/27551291/uitableview-backgroundcolor-always-white-on-ipad
        backgroundColor = contentView.backgroundColor
        updateViews()
        setColors()
    }

    
    // MARK: - Public
    
    func setup(with model: AutoSyncModel) {
        autoSyncModel = model
        if let setting = model.syncSetting {
            autoSyncSetting = setting
        }
        
        updateViews()
    }
    
    // MARK: - Private

    @IBAction func changeHeight(_ sender: Any) {
        guard let model = autoSyncModel else {
            return
        }
        
        model.isSelected = !model.isSelected
        delegate?.shouldChangeHeight(toExpanded: model.isSelected, cellType: model.cellType)
        updateViews()
    }
    
    private func updateViews() {
        let isSelected = autoSyncModel?.isSelected ?? false
        
        for (option, view) in zip(options, optionsViews) {
            view.setup(with: option, isSelected: autoSyncSetting.option == option)
            view.delegate = self
        }
        titleLabel.text = autoSyncSetting.syncItemType.localizedText
        optionLabel.text = isSelected ? TextConstants.autoSyncSettingsSelect : autoSyncSetting.option.localizedText
        optionsStackView.isHidden = !isSelected
    }
    
    private func setColors() {
        let textColor = ColorConstants.textGrayColor
        optionLabel.textColor = textColor
        cellSeparator.backgroundColor = textColor
        dropDownArrow.tintColor = textColor
        titleLabel.textColor = textColor
        
        for separator in optionSeparators {
            separator.backgroundColor = ColorConstants.lightGrayColor
        }
    }
    
}

extension AutoSyncSettingsTableViewCell: AutoSyncSettingsOptionViewDelegate {
    func didSelect(option: AutoSyncOption) {
        autoSyncSetting.option = option
        updateViews()
    }
}
