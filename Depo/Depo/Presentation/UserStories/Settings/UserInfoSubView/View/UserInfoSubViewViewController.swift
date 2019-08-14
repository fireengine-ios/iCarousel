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

final class UserInfoSubViewViewController: ViewController, UserInfoSubViewViewInput {

    var output: UserInfoSubViewViewOutput!
    
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var userEmailLabel: UILabel!
    @IBOutlet private weak var userPhoneNumber: UILabel!
    @IBOutlet private weak var premiumButton: GradientPremiumButton!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var accountDetailsButton: UIButton!
    @IBOutlet private weak var accountDetailsLabel: UILabel!
    @IBOutlet private weak var userStorrageInformationLabel: UILabel!
    @IBOutlet private weak var usedAsPercentageLabel: UILabel!
    @IBOutlet private weak var circleProgressView: CircleProgressView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    
    weak var actionsDelegate: UserInfoSubViewViewControllerActionsDelegate?
    
    var userInfo: AccountInfoResponse?
    
    private var isPhotoLoaded = false
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDesign()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
        setupDesignByUserAuthority()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height * 0.5
    }
        
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
    
    func setUserInfo(userInfo: AccountInfoResponse) {
        self.userInfo = userInfo
        var string = ""
        if let name_ = userInfo.name {
            string = name_
        }
        
        if let surname = userInfo.surname, !surname.isEmpty {
            if let name = userInfo.name, !name.isEmpty {
                string = string + " "
            }
            
            string = string + surname
        }
        
        userNameLabel.text = string
        userEmailLabel.text = userInfo.email
        userPhoneNumber.text = userInfo.phoneNumber
        
        if let url = userInfo.urlForPhoto, !isPhotoLoaded {
            avatarImageView.sd_setImage(with: url) { [weak self] _, _, _, _ in
                self?.isPhotoLoaded = true
            }
        }
    }
    
    func setQuotaInfo(quotoInfo: QuotaInfoResponse) {
        guard let quotaBytes = quotoInfo.bytes, let usedBytes = quotoInfo.bytesUsed else { 
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
    
    // MARK: Utility methods
    
    private func setupDesignByUserAuthority() {
        premiumButton.titleEdgeInsets = UIEdgeInsetsMake(6, 14, 6, 14)
        premiumButton.setTitle(TextConstants.becomePremium, for: .normal)
        premiumButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        premiumButton.isHidden = output.isPremiumUser
        
        if output.isPremiumUser {
            statusLabel.text = TextConstants.premiumUser
        } else if output.isMiddleUser {
            statusLabel.text = TextConstants.midUser
        } else {
            statusLabel.text = TextConstants.standardUser
        }
        
        statusLabel.font = UIFont.TurkcellSaturaDemFont(size: 18)
        statusLabel.textColor = .black
    }
    
    private func setupDesign() {
        userNameLabel.textColor = ColorConstants.textGrayColor
        userNameLabel.font = UIFont.TurkcellSaturaMedFont(size: 18)
        
        userEmailLabel.textColor = ColorConstants.textGrayColor
        userEmailLabel.font = UIFont.TurkcellSaturaMedFont(size: 16)
        
        userPhoneNumber.textColor = ColorConstants.textGrayColor
        userPhoneNumber.font = UIFont.TurkcellSaturaMedFont(size: 16)
        
        accountDetailsLabel.textColor = ColorConstants.blueColor
        accountDetailsLabel.font = UIFont.TurkcellSaturaDemFont(size: 15)
        accountDetailsLabel.text = TextConstants.accountDetails
        
        userStorrageInformationLabel.textColor = ColorConstants.blueColor
        userStorrageInformationLabel.font = UIFont.TurkcellSaturaDemFont(size: 18)
        
        usedAsPercentageLabel.textColor = ColorConstants.blueColor
        usedAsPercentageLabel.font = UIFont.TurkcellSaturaDemFont(size: 16)
        
        circleProgressView.backWidth = NumericConstants.usageInfoProgressWidth
        circleProgressView.progressWidth = NumericConstants.usageInfoProgressWidth
        circleProgressView.progressRatio = 0.0
        circleProgressView.progressColor = .lrTealish
        circleProgressView.backColor = UIColor.lrTealish
            .withAlphaComponent(NumericConstants.progressViewBackgroundColorAlpha)
        circleProgressView.set(progress: 0, withAnimation: true)
        circleProgressView.backWidth = 8
        circleProgressView.progressWidth = 8
        circleProgressView.layoutIfNeeded()
        
        avatarImageView.layer.masksToBounds = true
    }

    // MARK: UserInfoSubViewViewInput
    func setupInitialState() {
    }
    
    // MARK: buttons actions
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
