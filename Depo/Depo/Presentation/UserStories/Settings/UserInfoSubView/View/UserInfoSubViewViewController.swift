//
//  UserInfoSubViewUserInfoSubViewViewController.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

protocol UserInfoSubViewViewControllerActionsDelegate: AnyObject {
    func changePhotoPressed(quotaInfo: QuotaInfoResponse?)
    func upgradeButtonPressed(quotaInfo: QuotaInfoResponse?)
    func premiumButtonPressed()
    func freeUpCardRemoved()
}

final class UserInfoSubViewViewController: ViewController, NibInit {

    var output: UserInfoSubViewViewOutput!
    
    @IBOutlet private weak var outerStackView: UIStackView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var userNameLabel: UILabel! {
        willSet {
            newValue.font = UIFont.appFont(.medium, size: 14.0)
        }
    }
    
    @IBOutlet private weak var userEmailLabel: UILabel! {
        willSet {
            newValue.font = UIFont.appFont(.medium, size: 12.0)
        }
    }
    
    @IBOutlet private weak var userPhoneNumber: UILabel! {
        willSet {
            newValue.font = UIFont.appFont(.medium, size: 12.0)
        }
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        headerBackView.addRoundedShadows(cornerRadius: 16,
                                   shadowColor: AppColor.viewShadowLight.cgColor,
                                   opacity: 0.8, radius: 6.0)
        headerBackView.backgroundColor = AppColor.secondaryBackground.color
        stackView.layer.cornerRadius = 16
        stackView.backgroundColor = AppColor.secondaryBackground.color
    }
    
    
    @IBAction private func accountDetailsButton(_ sender: Any) {
        actionsDelegate?.upgradeButtonPressed(quotaInfo: output.quotaInfo)

    }
    
    
    @IBOutlet private weak var premiumButton: GradientPremiumButton! {
        willSet {
            newValue.setTitle(TextConstants.becomePremium, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 15)
            newValue.isHidden = output.isPremiumUser
        }
    }
    
    @IBOutlet private weak var headerBackView: UIView!
    
    
    @IBOutlet private weak var avatarImageView: UIImageView! {
        willSet {
            newValue.layer.masksToBounds = true
        }
    }
    
    weak var actionsDelegate: UserInfoSubViewViewControllerActionsDelegate?
    
    var userInfo: AccountInfoResponse?
    
    private var isPhotoLoaded = false
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appendFreeUpSpace()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height * 0.5
    }

    private func appendFreeUpSpace() {
        let view = FreeUpSpacePopUp.initFromNib()
        view.configurateWithType(viewType: .freeAppSpace)
        view.backgroundColor = AppColor.tint.color
        view.popupDelegate = self
        stackView.addArrangedSubview(view)
        view.layer.cornerRadius = 16.0
    }
}

// MARK: FreeUpSpacePopupDelegate
extension UserInfoSubViewViewController: FreeUpSpacePopupDelegate {
    func removeCard() {
        DispatchQueue.main.async {
            self.stackView.isHidden = true
            self.actionsDelegate?.freeUpCardRemoved()
        }
    }
}

// MARK: SettingsViewController Input
extension UserInfoSubViewViewController {
    
    func reloadUserInfo() {
        output.reloadUserInfoRequired()
    }
    
    func updatePhoto(image: UIImage) {
        avatarImageView.image = image
        if let url = userInfo?.urlForPhoto {
            SDImageCache.shared().removeImage(forKey: url.absoluteString, withCompletion: nil)
        }
    }
    
    func showLoadingSpinner() {
        output.loadingIndicatorRequired()
    }
    
    func dismissLoadingSpinner() {
        output.loadingIndicatorDismissalRequired()
    }
    
}

// MARK: Interface Builder Actions
extension UserInfoSubViewViewController {

    
    @IBAction private func onUpdateUserPhoto() {
        actionsDelegate?.changePhotoPressed(quotaInfo: output.quotaInfo)
    }
    
    @IBAction private func onBecomePremiumTap(_ sender: Any) {
        actionsDelegate?.premiumButtonPressed()
    }
    
}

// MARK: - UserInfoSubViewViewInput
extension UserInfoSubViewViewController: UserInfoSubViewViewInput {
    
    func setupInitialState() {}
    
    func setUserInfo(userInfo: AccountInfoResponse) {
        self.userInfo = userInfo
        
        userNameLabel.text = getFullUserName(userInfo: userInfo)
        
        if
            let email = userInfo.email,
            !email.isEmpty {
            userEmailLabel.text = email
            userEmailLabel.textColor = .lrBrownishGrey
        } else {
            userEmailLabel.text = TextConstants.settingsUserInfoEmail
            userEmailLabel.textColor = ColorConstants.profileLightGray
        }
        
        if
            let phoneNumber = userInfo.phoneNumber,
            !phoneNumber.isEmpty {
            userPhoneNumber.text = phoneNumber
            userPhoneNumber.textColor = .lrBrownishGrey
        } else {
            userPhoneNumber.text = TextConstants.settingsUserInfoPhone
            userPhoneNumber.textColor = ColorConstants.profileLightGray
        }
        
        if
            let url = userInfo.urlForPhoto,
            !isPhotoLoaded {
            avatarImageView.sd_setImage(with: url) { [weak self] _, _, _, _ in
                self?.isPhotoLoaded = true
            }
        }
    }
    
    func setQuotaInfo(quotoInfo: QuotaInfoResponse) {
        guard
            let quotaBytes = quotoInfo.bytes,
            let usedBytes = quotoInfo.bytesUsed
        else {
            return
        }
    }
    
    // MARK: - UserInfoSubViewViewInput Private Utility Methods
    
    private func getFullUserName(userInfo: AccountInfoResponse) -> String {
        var fullName = ""
        if let name = userInfo.name {
            fullName += name
        }
        if let surname = userInfo.surname {
            fullName.isEmpty ? (fullName += surname) : (fullName = fullName + " " + surname)
        }
        guard !fullName.isEmpty else {
            userNameLabel.textColor = ColorConstants.profileLightGray
            return TextConstants.settingsUserInfoNameSurname
        }
        userNameLabel.textColor = ColorConstants.textGrayColor
        return fullName
    }
    
}
