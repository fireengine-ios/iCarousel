//
//  SettingFooterView.swift
//  Depo
//
//  Created by Andrei Novikau on 1/24/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit
import Foundation

enum DarkModeOption: Int, CaseIterable {
    case dark = 0
    case light = 1
    case defaultOption = 2
}

protocol DarkModeOptionsViewDelegate: AnyObject {
    func appearanceDidSelected(with option: DarkModeOption)
}

protocol SettingFooterViewDelegate: AnyObject {
    func didTappedLogOut()
}

final class SettingFooterView: UIView, NibInit {
    weak var delegate: SettingFooterViewDelegate?
    weak var darkModeDelegate: DarkModeOptionsViewDelegate?
    lazy var storageVars: StorageVars = factory.resolve()
    private var checkmarkImage: UIImage? { Image.iconDisplaySelected.image }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    @IBOutlet var selectionButtons: [UIButton]!
    @IBOutlet weak var logoutButton: WhiteButton! {
        willSet {
            newValue.setTitle(TextConstants.settingsViewCellLogout, for: .normal)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        
        lightModeBackView.addRoundedShadows(cornerRadius: 16, shadowColor: AppColor.viewShadowLight.cgColor, opacity: 0.5, radius: 24, offset: CGSize(width: 0, height: 6))
        lightModeBackView.backgroundColor = AppColor.secondaryBackground.color
        
    }
    
    @IBOutlet weak var lightModeBackView: UIView!
    @IBOutlet weak var lightModeImageView: UIImageView! {
        willSet {
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.borderLightGray.cgColor
            newValue.layer.cornerRadius = newValue.frame.height * 0.5
        }
    }
    
    @IBOutlet weak var darkModeImageView: UIImageView! {
        willSet {
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.borderLightGray.cgColor
            newValue.layer.cornerRadius = newValue.frame.height * 0.5
        }
    }
    
    @IBOutlet weak var automaticModeImageView: UIImageView! {
        willSet {
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.borderLightGray.cgColor
            newValue.layer.cornerRadius = newValue.frame.height * 0.5
        }
    }
    
    @IBOutlet weak var lightModelLabel: UILabel! {
        willSet {
            newValue.text = localized(.darkModeLightText)
            newValue.font = .appFont(.medium, size: 14.0)
            newValue.textColor = AppColor.label.color
        }
    }
    
    @IBOutlet weak var darkModelLabel: UILabel! {
        willSet {
            newValue.text = localized(.darkModeDarkText)
            newValue.font = .appFont(.medium, size: 14.0)
            newValue.textColor = AppColor.label.color
        }
    }
    
    @IBOutlet weak var automaticModelLabe: UILabel! {
        willSet {
            newValue.text = localized(.darkModeDefaultText)
            newValue.font = .appFont(.medium, size: 14.0)
            newValue.textColor = AppColor.label.color
        }
    }
    
    @IBOutlet weak private var selectLightModeButton: UIButton! {
        willSet {
            newValue.tag = DarkModeOption.light.rawValue
            newValue.setTitle("", for: .normal)
        }
    }
    
    
    @IBOutlet weak private var selectDarkModeButton: UIButton! {
        willSet {
            newValue.tag = DarkModeOption.dark.rawValue
            newValue.setTitle("", for: .normal)
        }
    }

    @IBOutlet weak private var selectDefaultModeButton: UIButton! {
        willSet {
            newValue.tag = DarkModeOption.defaultOption.rawValue
            newValue.setTitle("", for: .normal)
        }
    }
    
    @IBAction func selectionButtonTapped(_ sender: UIButton) {
        for option in DarkModeOption.allCases where option.rawValue == sender.tag {
            appearanceDidSelected(with: option)
        }

        configureOptions(with: sender.tag)
    }
    
    @IBAction private func onLeaveFeedbackButton(sender: UIButton) {
        delegate?.didTappedLogOut()
    }
    
    private func setup() {
        if let isDarkModeEnabled = storageVars.isDarkModeEnabled {
            isDarkModeEnabled ? selectDarkModeButton.setImage(checkmarkImage, for: .normal) :
                                selectLightModeButton.setImage(checkmarkImage, for: .normal)
        } else {
            selectDefaultModeButton.setImage(checkmarkImage, for: .normal)
        }
    }

    private func configureOptions(with tag: Int) {
        for button in selectionButtons {
            if button.tag == tag {
                button.setImage(checkmarkImage, for: .normal)
            } else {
                button.setImage(UIImage(), for: .normal)
            }
        }
    }
}

//MARK: -DarkModeOptionsViewDelegate
extension SettingFooterView: DarkModeOptionsViewDelegate {
    func appearanceDidSelected(with option: DarkModeOption) {
        if #available(iOS 13.0, *) {
            switch option {
            case .dark:
                storageVars.isDarkModeEnabled = true
            case .light:
                storageVars.isDarkModeEnabled = false
            case .defaultOption:
                storageVars.isDarkModeEnabled = nil
            }
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.overrideApplicationThemeStyle()
        }
    }
}
