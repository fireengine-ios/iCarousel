//
//  UserInfoSubViewUserInfoSubViewViewController.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol UserInfoSubViewViewControllerActionsDelegate: class {
    func changePhotoPressed()
    func updateUserProfile(userInfo: AccountInfoResponse)
    func upgradeButtonPressed()
}

class UserInfoSubViewViewController: UIViewController, UserInfoSubViewViewInput {

    var output: UserInfoSubViewViewOutput!
    
    @IBOutlet weak var userlogoImageView: UIImageView!
    @IBOutlet weak var userIconImageView: LoadingImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userPhoneNumber: UILabel!
    @IBOutlet weak var userStorrageInformationLabel: UILabel!
    @IBOutlet weak var upgradeUserStorrageButton: UIButton!
    @IBOutlet weak var usersStorrageUssesProgress: RoundedProgressView!
    @IBOutlet weak var uplaodLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    weak var actionsDelegate: UserInfoSubViewViewControllerActionsDelegate?
    
    var userInfo: AccountInfoResponse?

    
    
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
        
        upgradeUserStorrageButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        upgradeUserStorrageButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        upgradeUserStorrageButton.setTitle(TextConstants.settingsUserInfoViewUpgradeButtonText, for: .normal)
        
        uplaodLabel.font = UIFont.TurkcellSaturaBolFont(size: 14)
        uplaodLabel.textColor = UIColor.lrTealish
        uplaodLabel.text = TextConstants.settingsViewUploadPhotoLabel
        
        usersStorrageUssesProgress.progressTintColor = ColorConstants.greenColor
        usersStorrageUssesProgress.trackTintColor = ColorConstants.lightGrayColor
        
        usersStorrageUssesProgress.setProgress(0, animated: false)
        
        userIconImageView.layer.cornerRadius = userIconImageView.frame.size.width * 0.5
        userIconImageView.layer.masksToBounds = true
        
        editButton.isHidden = true
        
        output.viewIsReady()
    }
    
    func reloadUserInfo() {
        output.reloadUserInfoRequered()
    }
    
    func showLoadingSpinner() {
        output.loadingIndicatorRequered()
    }
    
    func dismissLoadingSpinner() {
        output.loadingIndicatorDismissalRequered()
    }
    
    func setUserInfo(userInfo: AccountInfoResponse){
        self.userInfo = userInfo
        editButton.isHidden = false
        var string: String = ""
        if let name_ = userInfo.name{
            string = string + name_
        }
        
        if let surName_ = userInfo.surname{
            if (string.count > 0){
                string = string + " "
            }
            string = string + surName_
        }
        userNameLabel.text = string
        
        userEmailLabel.text = userInfo.email
        userPhoneNumber.text = userInfo.phoneNumber
        if let url = userInfo.urlForPhoto{
            userIconImageView.loadImageByURL(url: url)
        }
    }
    
    func setQuotaInfo(quotoInfo: QuotaInfoResponse){
        guard let quotaBytes = quotoInfo.bytes, let usedBytes = quotoInfo.bytesUsed else { return }
        usersStorrageUssesProgress.progress = 1 - Float(usedBytes)/Float(quotaBytes)
        
        let quotaString = quotaBytes.bytesString
        let remaindSize = (quotaBytes - usedBytes).bytesString
        userStorrageInformationLabel.text = String(format: TextConstants.usageInfoBytesRemained, remaindSize, quotaString)
        
        
        
//        let all = Float(quotoInfo.bytes ?? 0)
//        let used = Float(quotoInfo.bytesUsed ?? 1)
//        let persent = used/all
//
//        self.usersStorrageUssesProgress.progress = persent
//
//        let allSize = ByteCountFormatter.string(fromByteCount: quotoInfo.bytes ?? 0, countStyle: .binary)
//        let remaind = (quotoInfo.bytes ?? 0) - (quotoInfo.bytesUsed ?? 0)
//        let usedSize = ByteCountFormatter.string(fromByteCount: remaind, countStyle: .binary)
//
//        userStorrageInformationLabel.text = String(format: TextConstants.settingsUserInfoViewQuota, usedSize, allSize)
        
    }

    // MARK: UserInfoSubViewViewInput
    func setupInitialState() {
        
    }
    
    // MARK: buttons actions
    @IBAction func onEditUserInformationButton(){
        guard let userInfo_ = userInfo else{
            return
        }
        actionsDelegate?.updateUserProfile(userInfo: userInfo_)
    }
    
    @IBAction func onUpgradeUserStorrageButton(){
        actionsDelegate?.upgradeButtonPressed()
    }
    
    @IBAction func onUpdateUserPhoto(){
        actionsDelegate?.changePhotoPressed()
//        output.onChangeUserPhoto()
    }
}
