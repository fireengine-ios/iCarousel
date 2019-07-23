//
//  PermissionsView.swift
//  Depo
//
//  Created by Darya Kuliashova on 6/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol PermissionViewDelegate: class {
    func permissionsView(_ view: PermissionsView, didChangeValue isOn: Bool)
}

protocol PermissionsViewProtocol: class {
    
    var delegate: PermissionViewDelegate? { get set }
    var type: PermissionType! { get set }
    func turnPermissionOn(isOn: Bool, isPendingApproval: Bool)
    func togglePermissionSwitch()
}

class PermissionsView: UIView, PermissionsViewProtocol, NibInit {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var permissionSwitch: UISwitch!
    @IBOutlet private weak var inProgressLabel: UILabel!
    
    weak var delegate: PermissionViewDelegate?
    
    var type: PermissionType! {
        didSet {
            switch type! {
            case .etk:
                titleLabel.text = TextConstants.etkPermissionTitleLabel
                descriptionLabel.text = TextConstants.etkPermissionDescriptionLabel
            case .globalPermission:
                titleLabel.text = TextConstants.globalPermissionTitleLabel
                descriptionLabel.text = TextConstants.globalPermissionDescriptionLabel
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction private func permissionSwitchValueChanged(_ sender: UISwitch) {
        delegate?.permissionsView(self, didChangeValue: sender.isOn)
    }
    
    // MARK: - Actions
    
    func turnPermissionOn(isOn: Bool, isPendingApproval: Bool) {
        /// change switch status according to user actions
        if isPendingApproval {
            permissionSwitch.isOn = !isOn
            permissionSwitch.isEnabled = false
            inProgressLabel.isHidden = false
        } else {
            permissionSwitch.isOn = isOn
            permissionSwitch.isEnabled = true
            inProgressLabel.isHidden = true
        }
    }
    
    func togglePermissionSwitch() {
        permissionSwitch.isOn = !permissionSwitch.isOn
    }
}
