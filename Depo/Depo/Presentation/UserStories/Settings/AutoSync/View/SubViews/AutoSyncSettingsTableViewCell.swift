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
    func didChangeHeight()
}


final class AutoSyncSettingsTableViewCell: UITableViewCell {
    weak var delegate: AutoSyncSettingsTableViewCellDelegate?
    
    @IBOutlet weak var expandHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var optionsStackView: UIStackView!
    @IBOutlet private weak var dropDownArrow: UIImageView!
    @IBOutlet private weak var optionLabel: UILabel!
    @IBOutlet private weak var expandButton: UIButton!
    @IBOutlet private var optionsViews: [AutoSyncSettingsOptionView]!
    
    @IBOutlet private var optionSeparators: [UIView]!
    @IBOutlet private weak var cellSeparator: UIView!
    
    
    private var isFullHeight: Bool = false {
        didSet {
            if isFullHeight != oldValue {
                updateViews()
                delegate?.didChangeHeight()
            }
        }
    }
    
    private var autoSyncSetting = AutoSyncSetting(syncItemType: .photo, option: .wifiOnly) {
        didSet {
            if autoSyncSetting != oldValue {
                updateViews()
                delegate?.didChange(setting: autoSyncSetting)
            }
        }
    }
    
    private let options: [AutoSyncOption] = [.never, .wifiOnly, .wifiAndCellular]
    
    
    private var expandHeight: CGFloat {
        return isFullHeight ? 167.5 : 0.0
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ///iPad, iOS < 10, prevent white color
        ///https://stackoverflow.com/questions/27551291/uitableview-backgroundcolor-always-white-on-ipad
        backgroundColor = contentView.backgroundColor
        updateViews()
    }

    
    // MARK: - Public
    
    override func prepareForReuse() {
        isFullHeight = false
    }
    
    func setup(with setting: AutoSyncSetting) {
        autoSyncSetting = setting
    }
    
    func setColors(isFromSettings: Bool) {
        let textColor = isFromSettings ? ColorConstants.textGrayColor : ColorConstants.whiteColor
        optionLabel.textColor = textColor
        expandButton.setTitleColor(textColor, for: .normal)
        for view in optionsViews {
            view.setColors(isFromSettings: isFromSettings)
        }
        
        for separator in optionSeparators {
            separator.backgroundColor = isFromSettings ? ColorConstants.lightGrayColor : ColorConstants.whiteColor
        }
        
        cellSeparator.backgroundColor = isFromSettings ? ColorConstants.textGrayColor : ColorConstants.whiteColor
        
        dropDownArrow.tintColor = isFromSettings ? ColorConstants.textGrayColor : ColorConstants.whiteColor
    }
    
    
    // MARK: - Private

    @IBAction func changeHeight(_ sender: Any) {
        isFullHeight = !isFullHeight
    }
    
    private func updateViews() {
        for (option, view) in zip(options, optionsViews) {
            view.setup(with: option, isSelected: autoSyncSetting.option == option)
            view.delegate = self
        }
        expandButton.setTitle(autoSyncSetting.syncItemType.text(), for: .normal)
        optionLabel.text = isFullHeight ? TextConstants.autoSyncSettingsSelect : autoSyncSetting.option.text()
        optionsStackView.isHidden = !isFullHeight
        expandHeightConstraint.constant = expandHeight
    }
    
    
}


extension AutoSyncSettingsTableViewCell: AutoSyncSettingsOptionViewDelegate {
    func didSelect(option: AutoSyncOption) {
        autoSyncSetting.option = option
        updateViews()
    }
}
