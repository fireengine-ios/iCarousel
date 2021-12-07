//
//  DarkModeSwitchView.swift
//  Depo
//
//  Created by Burak Donat on 6.12.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import UIKit

enum DarkModeOption: Int, CaseIterable {
    case dark = 0
    case light = 1
    case defaultOption = 2
}

protocol DarkModeOptionsViewDelegate: AnyObject {
    func appearanceDidSelected(with option: DarkModeOption)
}

class DarkModeOptionsView: UIView, NibInit {

    weak var delegate: DarkModeOptionsViewDelegate?
    lazy var storageVars: StorageVars = factory.resolve()
    private let checkmarkImage = UIImage(named: "backupCheckmark")

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    @IBOutlet weak private var titleLabel: UILabel! {
        willSet {
            newValue.text = "Mod"
            newValue.font = .TurkcellSaturaBolFont(size: 22)
            newValue.textColor = ColorConstants.textGrayColor
        }
    }

    @IBOutlet weak private var darkModeLabel: UILabel! {
        willSet {
            newValue.text = "Dark"
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.textColor = ColorConstants.textGrayColor
        }
    }

    @IBOutlet weak private var lightModeLabel: UILabel! {
        willSet {
            newValue.text = "Light"
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.textColor = ColorConstants.textGrayColor
        }
    }

    @IBOutlet weak private var defaultModeLabel: UILabel! {
        willSet {
            newValue.text = "Default"
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.textColor = ColorConstants.textGrayColor
        }
    }

    @IBOutlet weak private var selectDarkModeButton: UIButton! {
        willSet {
            newValue.tag = DarkModeOption.dark.rawValue
        }
    }

    @IBOutlet weak private var selectLightModeButton: UIButton! {
        willSet {
            newValue.tag = DarkModeOption.light.rawValue
        }
    }

    @IBOutlet weak private var selectDefaultModeButton: UIButton! {
        willSet {
            newValue.tag = DarkModeOption.defaultOption.rawValue
        }
    }

    @IBOutlet var selectionButtons: [UIButton]!

    @IBAction func selectionButtonTapped(_ sender: UIButton) {
        configureOptions(with: sender.tag)

        for option in DarkModeOption.allCases {
            if option.rawValue == sender.tag {
                delegate?.appearanceDidSelected(with: option)
            }
        }
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
