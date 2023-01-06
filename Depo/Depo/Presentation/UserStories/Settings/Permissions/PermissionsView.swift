//
//  PermissionsView.swift
//  Depo
//
//  Created by Darya Kuliashova on 6/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol PermissionViewDelegate: AnyObject {
    func permissionsView(_ view: PermissionsView, didChangeValue isOn: Bool)
}

protocol PermissionViewTextViewDelegate: AnyObject {
    func tappedOnURL(url: URL) -> Bool
}

protocol PermissionsViewProtocol: AnyObject {
    var delegate: PermissionViewDelegate? { get set }
    var textviewDelegate: PermissionViewTextViewDelegate? { get set }
    var type: PermissionType? { get set }
    var urlString: String? { get set }
    func turnPermissionOn(isOn: Bool, isPendingApproval: Bool)
    func togglePermissionSwitch()
}

class PermissionsView: UIView, PermissionsViewProtocol, NibInit {
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 16)
        }
    }
    
    @IBOutlet private weak var inProgressLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 12)
            newValue.isHidden = true
        }
    }
    @IBOutlet weak var switchContentView: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.secondaryBackground.color
            newValue.addRoundedShadows(cornerRadius: 16, shadowColor: AppColor.drawerShadow.cgColor, opacity: 0.3, radius: 4)
        }
    }
    
    @IBOutlet private weak var descriptionView: IntrinsicEmptiableTextView!
    @IBOutlet private weak var permissionSwitch: UISwitch!
    @IBOutlet private weak var backView: UIView!
    
    weak var delegate: PermissionViewDelegate?
    weak var textviewDelegate: PermissionViewTextViewDelegate?
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    var type: PermissionType? {
        didSet {
            setupTitleAndDescription(type: type)
            setupBackView()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        backView.addRoundedShadows(cornerRadius: 16, shadowColor: AppColor.drawerShadow.cgColor, opacity: 0.3, radius: 4)
        backView.backgroundColor = AppColor.secondaryBackground.color
        
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
                                                        attributes: [.font: UIFont.appFont(.regular, size: 14),
                                                                     .foregroundColor: AppColor.label.color])
        case .globalPermission:
            title = TextConstants.globalPermissionTitleLabel
            descriptionText = NSMutableAttributedString(string: TextConstants.globalPermissionDescriptionLabel,
                                                        attributes: [.font: UIFont.appFont(.regular, size: 14),
                                                                     .foregroundColor: AppColor.label.color])
        case .mobilePayment:
            title = TextConstants.mobilePaymentPermissionTitleLabel
            descriptionText = NSMutableAttributedString(string: TextConstants.mobilePaymentPermissionDescriptionLabel,
                                                        attributes: [.font: UIFont.appFont(.regular, size: 14),
                                                                     .foregroundColor: AppColor.label.color])
            
            let rangeLink = descriptionText.mutableString.range(of: TextConstants.mobilePaymentPermissionLink)
            descriptionText.addAttributes([.link: TextConstants.NotLocalized.mobilePaymentPermissionLink], range: rangeLink)
        case .kvkk:
            title = localized(.kvkkToggleTitle)
            let description = String(format: localized(.kvkkToggleText), localized(.kvkkHyperlinkText))
            descriptionText = NSMutableAttributedString(string: description,
                                                        attributes: [.font: UIFont.appFont(.regular, size: 14),
                                                                     .foregroundColor: AppColor.label.color])
            
            
            let rangeLink = descriptionText.mutableString.range(of: localized(.kvkkHyperlinkText))
            descriptionText.addAttributes([.link: TextConstants.NotLocalized.permissionsPolicyLink,
                                           .font: UIFont.appFont(.regular, size: 14),
                                           .foregroundColor: AppColor.tint.color,
                                           .underlineColor: AppColor.tint.color,
                                           .underlineStyle: NSUnderlineStyle.single.rawValue], range: rangeLink)
        }
        titleLabel.text = title ?? ""
        
        setup(attributedDescription: descriptionText, delegate: textviewDelegate)
    }
    
    
    private func setupBackView(){
        backView.addRoundedShadows(cornerRadius: 16,
                                   shadowColor: AppColor.viewShadowLight.cgColor,
                                   opacity: 0.8, radius: 6.0)
        backView.backgroundColor = AppColor.secondaryBackground.color

    }
    
    func setup(attributedDescription: NSMutableAttributedString?, delegate: PermissionViewTextViewDelegate?) {
        if let attributedDescription = attributedDescription {
            descriptionView.attributedText = attributedDescription
            descriptionView.linkTextAttributes = [.foregroundColor: AppColor.tint.color,
                                                  .underlineColor: AppColor.tint.color,
                                                  .underlineStyle: NSUnderlineStyle.single.rawValue]
        }
        descriptionView.backgroundColor = AppColor.secondaryBackground.color
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
        if textviewDelegate?.tappedOnURL(url: URL) == true {
            return false
        }
        return defaultHandle(url: URL, interaction: interaction)
    }
}
