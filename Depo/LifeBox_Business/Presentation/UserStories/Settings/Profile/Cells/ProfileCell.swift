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
            let initials: String
            
            if let firstLetter = SingletonStorage.shared.accountInfo?.name?.firstLetter,
               let secondLetter = SingletonStorage.shared.accountInfo?.surname?.firstLetter {
                initials = firstLetter + secondLetter
            } else {
                initials = String((SingletonStorage.shared.accountInfo?.email ?? "").prefix(2)).uppercased()
            }
            
            newValue.setTitle(initials, for: .normal)
            newValue.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 18)
            newValue.tintColor = ColorConstants.topBarSettingsIconColor
            newValue.isUserInteractionEnabled = false
            
            newValue.backgroundColor = ColorConstants.Text.labelTitle
            newValue.layer.cornerRadius = 5
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
        containerView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).activate()
        containerView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).activate()
        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowLayer()
    }

    //MARK: - Private funcs
    
    private func setUserAvatar() {
        //TODO: - if user set avatar - show avatar and hide placeholder, else
        userAvatarImageView.isHidden = true
    }

    private func updateShadowLayer() {
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowOpacity = 0.3
    }
}
