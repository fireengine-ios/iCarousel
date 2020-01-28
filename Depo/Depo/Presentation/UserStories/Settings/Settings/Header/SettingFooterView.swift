//
//  SettingFooterView.swift
//  Depo
//
//  Created by Andrei Novikau on 1/24/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol SettingFooterViewDelegate: class {
    func didTappedLeaveFeedback()
}

final class SettingFooterView: UIView, NibInit {

    @IBOutlet private weak var leaveFeedbackButton: ButtonWithGrayCorner! {
        willSet {
            newValue.setTitle(TextConstants.settingsViewLeaveFeedback, for: .normal)
        }
    }
    
    @IBOutlet private weak var versionLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.lightText
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 16)
            
            if let version = UserDefaults.standard.string(forKey: AppConfigurator.SettingsBundleKeys.AppVersionKey),
                let build = UserDefaults.standard.string(forKey: AppConfigurator.SettingsBundleKeys.BuildVersionKey) {
                newValue.text = "\(version)_\(build)"
            }
        }
    }
    
    weak var delegate: SettingFooterViewDelegate?

    @IBAction private func onLeaveFeedbackButton(sender: UIButton) {
        delegate?.didTappedLeaveFeedback()
    }
}
