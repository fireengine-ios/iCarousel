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
    
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var checkboxImageView: UIImageView!
    
    private var option: AutoSyncOption = .wifiOnly {
        willSet { button.setTitle(newValue.text(), for: .normal) }
    }
    
    private var isSelected: Bool = false {
        willSet { setCheckmark(selected: newValue) }
        didSet {
            if isSelected, isSelected != oldValue {
                delegate?.didSelect(option: option)
            }
        }
    }

    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkboxImageView.alpha = 0.0
    }
    
    
    //MARK: - Public
    
    func configure(with option: AutoSyncOption, isSelected: Bool) {
        self.option = option
        self.isSelected = isSelected
    }
    
    
    //MARK: - Private
    
    private func setCheckmark(selected: Bool) {
        UIView.animate(withDuration: NumericConstants.fastAnimationDuration) {
            self.checkboxImageView.alpha = selected ? 1.0 : 0.0
        }
    }
    
    
    //MARK: - Actions
    
    @IBAction private func buttonTapped() {
        isSelected = true
    }
    
}






