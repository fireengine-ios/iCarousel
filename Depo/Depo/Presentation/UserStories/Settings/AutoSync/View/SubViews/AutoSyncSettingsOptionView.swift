//
//  AutosyncSettingsOptionView.swift
//  Depo
//
//  Created by Konstantin on 3/2/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol AutoSyncSettingsOptionViewDelegate: class {
    func didSelect(option: AutoSyncOption)
}


final class AutoSyncSettingsOptionView: UIView {
    weak var delegate: AutoSyncSettingsOptionViewDelegate?
    
    @IBOutlet private weak var button: UIButton! {
        didSet { button.titleLabel?.font = UIFont.TurkcellSaturaRegFont(size: 16.5) }
    }
    
    @IBOutlet private weak var checkboxImageView: UIImageView! {
        didSet {
            checkboxImageView.image = checkMarkImage
            checkboxImageView.alpha = 0.0
        }
    }
    
    private let checkMarkImage = UIImage(named: "checkmark")
    
    private var option: AutoSyncOption = .wifiOnly {
        willSet { button.setTitle(newValue.localizedText, for: .normal) }
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setColors()
    }

    
    // MARK: - Public
    
    func setup(with option: AutoSyncOption, isSelected: Bool) {
        self.option = option
        self.isSelected = isSelected
    }
    
    // MARK: - Private
    
    private func setColors() {
        let textColor = UIColor.darkGray
        button.setTitleColor(textColor, for: .normal)
        checkboxImageView.tintColor = UIColor.darkGray
    }
    
    private func setCheckmark(selected: Bool) {
        UIView.animate(withDuration: NumericConstants.fastAnimationDuration) {
            self.checkboxImageView.alpha = selected ? 1.0 : 0.0
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction private func buttonTapped() {
        isSelected = true
    }
    
}
