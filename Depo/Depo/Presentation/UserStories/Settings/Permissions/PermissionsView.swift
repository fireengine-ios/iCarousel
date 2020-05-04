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
    var type: PermissionType? { get set }
    var urlString: String? { get set }
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
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    var type: PermissionType? {
        didSet {
            setupTitleAndDescription(type: type)
        }
    }
    var urlString: String?
    
    // MARK: - IBActions

    @IBAction func permissionSwitchTapped(_ sender: UISwitch) {
        switch type {
        case .mobilePayment:
            self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .openMobilePaymentPermission, eventLabel: .isOn(sender.isOn))
            sender.isOn = !sender.isOn
        default: break
        }
        delegate?.permissionsView(self, didChangeValue: sender.isOn)
    }
    
    // MARK: - Actions
        
    private func setupTitleAndDescription(type: PermissionType?) {
        guard let type = type else {
            return
        }
        var descriptionText = NSMutableAttributedString()
        var title: String?
        switch type {
        case .etk:
            title = TextConstants.etkPermissionTitleLabel
            descriptionText = NSMutableAttributedString(string: TextConstants.etkPermissionDescription,
                                                        attributes: [.font: UIFont.TurkcellSaturaFont(size: 16),
                                                                     .foregroundColor: UIColor.lrLightBrownishGrey])
            
            let rangeLink1 = descriptionText.mutableString.range(of: TextConstants.termsAndUseEtkLinkTurkcellAndGroupCompanies)
            descriptionText.addAttributes([.link: TextConstants.NotLocalized.termsAndUseEtkLinkTurkcellAndGroupCompanies], range: rangeLink1)

            let rangeLink2 = descriptionText.mutableString.range(of: TextConstants.termsAndUseEtkLinkCommercialEmailMessages)
            descriptionText.addAttributes([.link: TextConstants.NotLocalized.termsAndUseEtkLinkCommercialEmailMessages], range: rangeLink2)
        case .globalPermission:
            title = TextConstants.globalPermissionTitleLabel
            descriptionText = NSMutableAttributedString(string: TextConstants.globalPermissionDescriptionLabel,
                                                        attributes: [.font: UIFont.TurkcellSaturaFont(size: 16),
                                                                     .foregroundColor: UIColor.lrLightBrownishGrey])
        case .mobilePayment:
            title = TextConstants.mobilePaymentPermissionTitleLabel
            descriptionText = NSMutableAttributedString(string: TextConstants.mobilePaymentPermissionDescriptionLabel,
                                                        attributes: [.font: UIFont.TurkcellSaturaFont(size: 16),
                                                                     .foregroundColor: UIColor.lrLightBrownishGrey])
            
            let rangeLink = descriptionText.mutableString.range(of: TextConstants.mobilePaymentPermissionLink)
            descriptionText.addAttributes([.link: TextConstants.NotLocalized.mobilePaymentPermissionLink], range: rangeLink)
        }
        titleLabel.text = title ?? ""
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
        
        permissionSwitch.isOn = isOn
        permissionSwitch.isEnabled = (isPendingApproval == false)
        inProgressLabel.isHidden = (isPendingApproval == false)
    }
    
    func togglePermissionSwitch() {
        permissionSwitch.isOn.toggle()
    }
}

extension PermissionsView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return textviewDelegate?.tappedOnURL(url: URL) ?? true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return textviewDelegate?.tappedOnURL(url: URL) ?? true
    }
}
