//
//  ProfileCell.swift
//  Depo_LifeTech
//
//  Created by Vyacheslav Bakinskiy on 30.03.21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class ProfileCell: UITableViewCell {
    
    //MARK: - @IBOutlets
    
    @IBOutlet private weak var containerView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
        }
    }
    @IBOutlet private weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var nameSurnameLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.profileNameSurname
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 12)
            newValue.textColor = ColorConstants.Text.textFieldText
        }
    }
    
    @IBOutlet private weak var userNameSurnameLabel: UILabel! {
        willSet {
            let initials = (SingletonStorage.shared.accountInfo?.name ?? "") + " " +  (SingletonStorage.shared.accountInfo?.surname ?? "")
            newValue.text = initials
            newValue.font = UIFont.GTAmericaStandardMediumFont(size: 14)
            newValue.textColor = ColorConstants.Text.labelTitle
        }
    }
    
    @IBOutlet private weak var emailLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.profileEmail
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 12)
            newValue.textColor = ColorConstants.Text.textFieldText
        }
    }
    
    @IBOutlet private weak var userEmailLabel: UILabel! {
        willSet {
            newValue.text = SingletonStorage.shared.accountInfo?.email ?? ""
            newValue.font = UIFont.GTAmericaStandardMediumFont(size: 14)
            newValue.textColor = ColorConstants.Text.labelTitle
        }
    }
    
    @IBOutlet private weak var userAvatarImageView: UIImageView! {
        willSet {
            newValue.layer.cornerRadius = 5
            newValue.contentMode = .scaleAspectFit
            newValue.clipsToBounds = true
        }
    }
    
    @IBOutlet private weak var userAvatarPlaceholder: UIButton! {
        willSet {
            let initials = (SingletonStorage.shared.accountInfo?.name?.firstLetter ?? "") + (SingletonStorage.shared.accountInfo?.surname?.firstLetter ?? "")
            newValue.setTitle(initials, for: .normal)
            newValue.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 18)
            newValue.tintColor = ColorConstants.topBarSettingsIconColor
            newValue.isUserInteractionEnabled = false
            
            newValue.backgroundColor = ColorConstants.Text.labelTitle
            newValue.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet private weak var changeAvatarButton: UIButton! {
        willSet {
            //TODO: - add tag for button when it'll be provided
            newValue.setTitle("Change", for: .normal)
            newValue.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 12)
            newValue.tintColor = ColorConstants.Text.labelTitle
        }
    }
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 5
        selectionStyle = .none
        setUserAvatar()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        leftConstraint.constant = 15
        rightConstraint.constant = 15
        layoutIfNeeded()
    }
    
    //MARK: - Private funcs
    
    private func setUserAvatar() {
        //TODO: - if user set avatar - show avatar and hide placeholder, else
        userAvatarImageView.isHidden = true
    }
    
    //MARK: - @IBActions
    
    @IBAction func changeAvatarButtonPressed(_ sender: Any) {
    }
}
