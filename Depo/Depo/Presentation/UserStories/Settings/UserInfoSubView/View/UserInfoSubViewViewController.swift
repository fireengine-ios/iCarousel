//
//  UserInfoSubViewUserInfoSubViewViewController.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

protocol UserInfoSubViewViewControllerActionsDelegate: class {
    func changePhotoPressed()
    func upgradeButtonPressed(quotaInfo: QuotaInfoResponse?)
    func premiumButtonPressed()
}

final class UserInfoSubViewViewController: ViewController, NibInit {

    var output: UserInfoSubViewViewOutput!
    
    @IBOutlet private weak var userNameLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 16)
        }
    }
    
    @IBOutlet private weak var userEmailLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 15)
        }
    }
    
    @IBOutlet private weak var userPhoneNumber: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 15)
        }
    }
    
    @IBOutlet private weak var statusLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 15)
            newValue.textColor = .black
            if output.isPremiumUser {
                newValue.text = TextConstants.premiumUser
            } else if output.isMiddleUser {
                newValue.text = TextConstants.midUser
            } else {
                newValue.text = TextConstants.standardUser
            }
        }
    }
    
    @IBOutlet private weak var premiumButton: GradientPremiumButton! {
        willSet {
            newValue.titleEdgeInsets = UIEdgeInsetsMake(6, 14, 6, 14)
            newValue.setTitle(TextConstants.becomePremium, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 15)
            newValue.isHidden = output.isPremiumUser
        }
    }
    
    @IBOutlet private weak var accountDetailsButton: UIButton!
    
    @IBOutlet private weak var accountDetailsLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.blueColor
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 15)
            newValue.text = TextConstants.accountDetails
        }
    }
    
    @IBOutlet private weak var userStorrageInformationLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.blueColor
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
        }
    }
    
    @IBOutlet private weak var usedAsPercentageLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.blueColor
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 16)
        }
    }
    
    @IBOutlet private weak var circleProgressView: CircleProgressView! {
        willSet {
            newValue.backWidth = NumericConstants.usageInfoProgressWidth
            newValue.progressWidth = NumericConstants.usageInfoProgressWidth
            newValue.progressRatio = 0.0
            newValue.progressColor = .lrTealish
            newValue.backColor = UIColor.lrTealish
                .withAlphaComponent(NumericConstants.progressViewBackgroundColorAlpha)
            newValue.set(progress: 0, withAnimation: true)
            newValue.backWidth = 8
            newValue.progressWidth = 8
            newValue.layoutIfNeeded()
        }
    }
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height * 0.5
        self.view.frame.size.height = 201
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
    
    @IBAction private func onEditUserInformationButton(_ sender: UIButton) {
        actionsDelegate?.upgradeButtonPressed(quotaInfo: output.quotaInfo)
    }
    
    @IBAction private func onUpdateUserPhoto() {
        actionsDelegate?.changePhotoPressed()
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
        
        if let email = userInfo.email {
            userEmailLabel.text = email
            userEmailLabel.textColor = ColorConstants.switcherGrayColor
        } else {
            userEmailLabel.text = TextConstants.settingsUserInfoEmail
            userEmailLabel.textColor = ColorConstants.profileLightGray
        }
        
        if let phoneNumber = userInfo.phoneNumber {
            userPhoneNumber.text = phoneNumber
            userPhoneNumber.textColor = ColorConstants.switcherGrayColor
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
        let usagePercentage = CGFloat(usedBytes) / CGFloat(quotaBytes)
        circleProgressView.set(progress: usagePercentage, withAnimation: true)

        let percentage = (usagePercentage  * 100).rounded(.toNearestOrAwayFromZero)
        usedAsPercentageLabel.text = String(format: TextConstants.usagePercentage, percentage)

        let quotaString = quotaBytes.bytesString
        let usedString = usedBytes.bytesString
        userStorrageInformationLabel.text = String(format: TextConstants.leftSpace, usedString, quotaString)
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
