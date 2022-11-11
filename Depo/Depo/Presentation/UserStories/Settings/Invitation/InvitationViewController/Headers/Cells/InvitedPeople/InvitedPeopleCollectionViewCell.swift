//
//  InvitedPeopleCollectionViewCell.swift
//  Depo
//
//  Created by Alper Kırdök on 7.05.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

class InvitedPeopleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var profileImageView: UIImageView! {
        willSet {
            newValue.backgroundColor = AppColor.campaignBackground.color
        }
    }
    @IBOutlet weak var profileShortCutLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.medium, size: 14)
        }
    }
    
    @IBOutlet weak var profileNameLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 12)
        }
    }
    
    func configureCell(invitationRegisteredAccount: InvitationRegisteredAccount) {
        if let name = invitationRegisteredAccount.name, name.count > 0 {
            profileShortCutLabel.text = AccountConstants.shared.dotTextBy(name: name)
            profileNameLabel.text = name
        } else {
            profileShortCutLabel.text = AccountConstants.shared.dotTextBy(email: invitationRegisteredAccount.email)
            profileNameLabel.text = invitationRegisteredAccount.email
        }
    }
}
