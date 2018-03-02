//
//  AutosyncSettingsOptionView.swift
//  Depo
//
//  Created by Konstantin on 3/2/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

enum AutoSyncSettingsOption {
    case wifiOnly
    case wifiAndCellular
    case never
    
    func text() -> String {
        switch self {
        case .never:
            return "Newer"
        case .wifiOnly:
            return "Wi-Fi"
        case .wifiAndCellular:
            return "Wi-Fi and Cellular"
        }
    }
}


protocol AutoSyncSettingsOptionViewDelegate: class {
    func didChange(isSelected: Bool, for option: AutoSyncSettingsOption)
}


final class AutoSyncSettingsOptionView: UIView {
    weak var delegate: AutoSyncSettingsOptionViewDelegate?
    
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var checkboxImageView: UIImageView!
    
    private var option: AutoSyncSettingsOption = .never {
        willSet { button.setTitle(newValue.text(), for: .normal) }
    }
    
    private var isSelected: Bool = false {
        willSet { setCheckmark(selected: newValue) }
        didSet { delegate?.didChange(isSelected: isSelected, for: option) }
    }

    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isSelected = false
    }
    
    
    //MARK: - Public
    
    func configure(with option: AutoSyncSettingsOption, isSelected: Bool) {
        self.option = option
        self.isSelected = isSelected
    }
    
    
    //MARK: - Private
    
    private func setCheckmark(selected: Bool) {
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.checkboxImageView.alpha = selected ? 1.0 : 0.0
        }
    }
    
    
    //MARK: - Actions
    
    @IBAction private func buttonTapped() {
        isSelected = !isSelected
    }
    
}






