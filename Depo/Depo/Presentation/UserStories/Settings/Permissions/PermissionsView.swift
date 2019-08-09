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

protocol PermissionViewTextViewDelegate: class {
    func tappedOnURL(url: URL) -> Bool
}

protocol PermissionsViewProtocol: class {
    var delegate: PermissionViewDelegate? { get set }
    var textviewDelegate: PermissionViewTextViewDelegate? { get set }
    var type: PermissionType! { get set }
    func turnPermissionOn(isOn: Bool, isPendingApproval: Bool)
    func togglePermissionSwitch()
}

class PermissionsView: UIView, PermissionsViewProtocol, NibInit {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var inProgressLabel: UILabel!
    @IBOutlet private weak var descriptionView: UITextView!
    @IBOutlet private weak var permissionSwitch: UISwitch!
    
    weak var delegate: PermissionViewDelegate?
    weak var textviewDelegate: PermissionViewTextViewDelegate?
    
    var type: PermissionType! {
        didSet {
            switch type! {
            case .etk:
                titleLabel.text = TextConstants.etkPermissionTitleLabel
                setupEtkDescription()
            case .globalPermission:
                titleLabel.text = TextConstants.globalPermissionTitleLabel
                setupGlobalPermissionDescription()
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction private func permissionSwitchValueChanged(_ sender: UISwitch) {
        delegate?.permissionsView(self, didChangeValue: sender.isOn)
    }
    
    // MARK: - Actions
    
    private func setupEtkDescription() {
        let descriptionText = NSMutableAttributedString(string: TextConstants.etkPermissionDescription,
                                                        attributes: [.font: UIFont.TurkcellSaturaFont(size: 16),
                                                                     .foregroundColor: UIColor.lrLightBrownishGrey])
        
        let rangeLink1 = descriptionText.mutableString.range(of: TextConstants.termsAndUseEtkLinkTurkcellAndGroupCompanies)
        descriptionText.addAttributes([.link: TextConstants.NotLocalized.termsAndUseEtkLinkTurkcellAndGroupCompanies], range: rangeLink1)

        let rangeLink2 = descriptionText.mutableString.range(of: TextConstants.termsAndUseEtkLinkCommercialEmailMessages)
        descriptionText.addAttributes([.link: TextConstants.NotLocalized.termsAndUseEtkLinkCommercialEmailMessages], range: rangeLink2)

        setup(attributedDescription: descriptionText, delegate: textviewDelegate)
    }
    
    private func setupGlobalPermissionDescription() {
        let descriptionText = NSMutableAttributedString(string: TextConstants.globalPermissionDescriptionLabel,
                                                        attributes: [.font: UIFont.TurkcellSaturaFont(size: 16),
                                                                     .foregroundColor: UIColor.lrLightBrownishGrey])
        
        setup(attributedDescription: descriptionText, delegate: textviewDelegate)
    }
    
    func setup(attributedDescription: NSMutableAttributedString?, delegate: PermissionViewTextViewDelegate?) {
        if let attributedDescription = attributedDescription {
            descriptionView.attributedText = attributedDescription
        }
        descriptionView.delegate = self
    }
    
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


extension PermissionsView: UITextViewDelegate {
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return textviewDelegate?.tappedOnURL(url: URL) ?? true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return textviewDelegate?.tappedOnURL(url: URL) ?? true
    }
}
