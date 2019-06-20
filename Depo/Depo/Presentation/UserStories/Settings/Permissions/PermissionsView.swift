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
    func turnPermissionOn(isOn: Bool)
    func togglePermissionSwitch()
}

class PermissionsView: UIView, PermissionsViewProtocol, NibInit {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var permissionSwitch: UISwitch!
    
    weak var delegate: PermissionViewDelegate?
    
    var type: PermissionType! {
        didSet {
            switch type! {
            case .etk:
                titleLabel.text = TextConstants.etkPermissionTitleLabel
                descriptionLabel.text = TextConstants.etkPermissionDescriptionLabel
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction private func permissionSwitchValueChanged(_ sender: UISwitch) {
        delegate?.permissionsView(self, didChangeValue: sender.isOn)
    }
    
    // MARK: - Actions
    
    func turnPermissionOn(isOn: Bool) {
        permissionSwitch.isOn = isOn
    }
    
    func togglePermissionSwitch() {
        permissionSwitch.isOn = !permissionSwitch.isOn
    }
}
