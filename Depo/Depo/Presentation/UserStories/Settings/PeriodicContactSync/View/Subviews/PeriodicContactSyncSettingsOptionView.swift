//
//  PeriodicContactSyncSettingsOptionView.swift
//  Depo
//
//  Created by 12345 on 22.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol PeriodicContactsSyncSettingsOptionViewDelegate: AnyObject {
    func didSelect(option: PeriodicContactsSyncOption)
}

final class PeriodicContactsSyncSettingsOptionView: UIView {
    weak var delegate: PeriodicContactsSyncSettingsOptionViewDelegate?
    
    private let times: [PeriodicContactsSyncOption] = [.daily, .weekly, .monthly]
    
    
    @IBOutlet private weak var button: UIButton! {
        willSet {
            newValue.titleLabel?.font = .appFont(.medium, size: 14)
        }
    }
    
    @IBOutlet private weak var checkboxImageView: UIImageView! {
        didSet {
            checkboxImageView.image = checkMarkImage
            checkboxImageView.alpha = 0.0
        }
    }
    
    private let checkMarkImage = Image.iconCheckBlue.image
    
    private var option: PeriodicContactsSyncOption = .daily {
        willSet {
            button.setTitle(newValue.localizedText, for: .normal)
        }
    }
    
    private var isSelected: Bool = false {
        willSet {
            setCheckmark(selected: newValue)
        }
        didSet {
            if isSelected, isSelected != oldValue {
                delegate?.didSelect(option: option)
            }
        }
    }
    
    // MARK: - Public
    func setup(with option: PeriodicContactsSyncOption, isSelected: Bool) {
        self.option = option
        self.isSelected = isSelected
    }
    
    
    // MARK: - Private
    private func setCheckmark(selected: Bool) {
        UIView.animate(withDuration: NumericConstants.fastAnimationDuration) {
            self.checkboxImageView.alpha = selected ? 1.0 : 0.0
        }
    }
    
    // MARK: - Actions
    @IBAction private func buttonTapped() {
        isSelected = true
        
        if times.contains(option) {
            button.setTitleColor(AppColor.label.color, for: .normal)
        }
    }
}
