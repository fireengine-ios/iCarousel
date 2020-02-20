//
//  SettingsTableViewSwitchCell.swift
//  Depo_LifeTech
//
//  Created by Aleksandr on 11/28/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol SettingsTableViewSwitchCellDelegate: class {
    func switchToggled(cell: SettingsTableViewSwitchCell)
}

final class SettingsTableViewSwitchCell: UITableViewCell {
    
    typealias SettingsTableViewSwitchCellParam = (key: CellType, value: Bool)

    enum CellType {
        case twoFactorAuth
        case securityPasscode
        case securityAutologin
        
        var title: String {
            switch self {
            case .securityPasscode:
                return TextConstants.settingsViewCellTurkcellPassword
            case .securityAutologin:
                return TextConstants.settingsViewCellTurkcellAutoLogin
            case .twoFactorAuth:
                return TextConstants.settingsViewCellTwoFactorAuth
            }
        }
        
        var description: String {
            switch self {
            case .securityPasscode:
                return TextConstants.loginSettingsSecurityPasscodeDescription
            case .securityAutologin:
                return TextConstants.loginSettingsSecurityAutologinDescription
            case .twoFactorAuth:
                return TextConstants.loginSettingsTwoFactorAuthDescription
            }
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = UIColor.black
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 18)
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.textDisabled
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 15)
            newValue.numberOfLines = 0
        }
    }

    @IBOutlet private weak var stateSwitch: UISwitch!
    @IBOutlet private weak var separator: UIView!
    
    private weak var actionDelegate: SettingsTableViewSwitchCellDelegate?
    
    var toggle: Bool {
        set {
            self.stateSwitch.setOn(newValue, animated: false)
        }
        
        get {
            return stateSwitch.isOn
        }
    }
    
    var type: CellType?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        stateSwitch.addTarget(self, action: #selector(swichChanged), for: .touchUpInside)//valueChanged)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellGotTouched)))
    }
    
    func setup(params: SettingsTableViewSwitchCellParam, delegate: SettingsTableViewSwitchCellDelegate, needShowSeparator: Bool = true) {
        type = params.key
        
        titleLabel.text = params.key.title
        descriptionLabel.text = params.key.description
        toggle = params.value
        
        actionDelegate = delegate
        separator.isHidden = !needShowSeparator
    }
    
    @objc func swichChanged() {
        debugPrint("swichChanged SettingsTableViewSwitchCells")
        actionDelegate?.switchToggled(cell: self)
    }
    
    @objc func cellGotTouched() {
        toggle.toggle()
        swichChanged()
    }
    
}
