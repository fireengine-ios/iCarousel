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
    func updateUserProfile(userInfo: AccountInfoResponse)
    func upgradeButtonPressed()
    func premiumButtonPressed()
}

class UserInfoSubViewViewController: ViewController, UserInfoSubViewViewInput {

    var output: UserInfoSubViewViewOutput!
    
    @IBOutlet weak var userlogoImageView: UIImageView!
    @IBOutlet weak var userIconImageView: LoadingImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userPhoneNumber: UILabel!
    @IBOutlet weak var userStorrageInformationLabel: UILabel!
    @IBOutlet weak var upgradeUserStorrageButton: InsetsButton!
    @IBOutlet weak var usersStorrageUssesProgress: RoundedProgressView!
    @IBOutlet weak var uplaodLabel: UILabel!
    @IBOutlet private weak var premiumButton: GradientPremiumButton!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var premiumView: UIView!
    @IBOutlet weak var editButton: UIButton!
    weak var actionsDelegate: UserInfoSubViewViewControllerActionsDelegate?
    
    var userInfo: AccountInfoResponse?
    
    private var isPhotoLoaded = false
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameLabel.textColor = ColorConstants.textGrayColor
        userNameLabel.font = UIFont.TurkcellSaturaMedFont(size: 18)
        
        userEmailLabel.textColor = ColorConstants.textGrayColor
        userEmailLabel.font = UIFont.TurkcellSaturaMedFont(size: 14)
        
        userPhoneNumber.textColor = ColorConstants.textGrayColor
        userPhoneNumber.font = UIFont.TurkcellSaturaMedFont(size: 14)
        
        userStorrageInformationLabel.textColor = ColorConstants.textGrayColor
        userStorrageInformationLabel.font = UIFont.TurkcellSaturaMedFont(size: 14)
        userStorrageInformationLabel.text = ""
        
        upgradeUserStorrageButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        upgradeUserStorrageButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        upgradeUserStorrageButton.setTitle(TextConstants.settingsUserInfoViewUpgradeButtonText, for: .normal)
        let inset: CGFloat = 5
        upgradeUserStorrageButton.insets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        uplaodLabel.font = UIFont.TurkcellSaturaBolFont(size: 14)
        uplaodLabel.textColor = UIColor.lrTealish
        uplaodLabel.text = TextConstants.settingsViewUploadPhotoLabel
        
        usersStorrageUssesProgress.progressTintColor = UIColor.lrTealish
        usersStorrageUssesProgress.trackTintColor = UIColor.lrTealish.withAlphaComponent(0.25)
        
        usersStorrageUssesProgress.setProgress(0, animated: false)
        
        userIconImageView.layer.cornerRadius = userIconImageView.frame.size.width * 0.5
        userIconImageView.layer.masksToBounds = true
        
        editButton.isHidden = true
        
        userIconImageView.sd_setShowActivityIndicatorView(true)
        userIconImageView.sd_setIndicatorStyle(.gray)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
        setupDesignByUserAuthority()
    }

    private func setupDesignByUserAuthority() {
        premiumButton.titleEdgeInsets = UIEdgeInsetsMake(5, 7, 5, 7)
        premiumButton.setTitle(TextConstants.becomePremium, for: .normal)
        premiumButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        premiumButton.isHidden = output.isPremiumUser
        premiumView.isHidden = output.isPremiumUser

        if output.isPremiumUser {
            statusLabel.text = TextConstants.premiumUser
        } else if output.isMiddleUser {
            statusLabel.text = TextConstants.midUser
        } else {
            statusLabel.text = TextConstants.standardUser
        }
        
        statusLabel.font = UIFont.TurkcellSaturaDemFont(size: 16)
        statusLabel.textColor = ColorConstants.textGrayColor
    }
        
    func reloadUserInfo() {
        output.reloadUserInfoRequired()
    }
    
    func updatePhoto(image: UIImage) {
        userIconImageView.image = image
        if let url = userInfo?.urlForPhoto {
            SDImageCache.shared().removeImage(forKey: url.absoluteString, withCompletion: nil)
        }
        
        dismissLoadingSpinner()
        uplaodLabel.isHidden = true
    }
    
    func showLoadingSpinner() {
        output.loadingIndicatorRequired()
    }
    
    func dismissLoadingSpinner() {
        output.loadingIndicatorDismissalRequired()
    }
    
    func setUserInfo(userInfo: AccountInfoResponse) {
        self.userInfo = userInfo
        editButton.isHidden = false
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
            userIconImageView.sd_setImage(with: url) { [weak self] _, _, _, _ in
                self?.isPhotoLoaded = true
                self?.uplaodLabel.isHidden = true
            }
        }
    }
    
    func setQuotaInfo(quotoInfo: QuotaInfoResponse) {
        guard let quotaBytes = quotoInfo.bytes, let usedBytes = quotoInfo.bytesUsed else { 
            return
        }
        usersStorrageUssesProgress.progress = Float(usedBytes) / Float(quotaBytes)
        
        let quotaString = quotaBytes.bytesString
        let usedString = usedBytes.bytesString
        userStorrageInformationLabel.text = String(format: TextConstants.usedAndLeftSpace, usedString, quotaString)
    }

    // MARK: UserInfoSubViewViewInput
    func setupInitialState() {
    }
    
    // MARK: buttons actions
    @IBAction func onEditUserInformationButton(_ sender: UIButton) {
        sender.isEnabled = false
        guard let userInfo_ = userInfo else {
            return
        }
        actionsDelegate?.updateUserProfile(userInfo: userInfo_)
        sender.isEnabled = true
    }
    
    @IBAction func onUpgradeUserStorrageButton() {
        actionsDelegate?.upgradeButtonPressed()
    }
    
    @IBAction func onUpdateUserPhoto() {
        actionsDelegate?.changePhotoPressed()
    }
    
    @IBAction private func onBecomePremiumTap(_ sender: Any) {
        actionsDelegate?.premiumButtonPressed()
    }
}
