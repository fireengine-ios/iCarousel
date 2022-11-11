//
//  AcceptedPeopleCollectionViewCell.swift
//  Depo
//
//  Created by Alper Kırdök on 26.05.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

class AcceptedPeopleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var shortNameBGView: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.campaignBackground.color
        }
    }
    
    @IBOutlet weak var shortNameLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.medium, size: 14)
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 12)
        }
    }

    func configureCell(invitationRegisteredAccount: InvitationRegisteredAccount) {
        if let name = invitationRegisteredAccount.name, name.count > 0 {
            shortNameLabel.text = AccountConstants.shared.dotTextBy(name: name)
            nameLabel.text = name
        } else {
            shortNameLabel.text = AccountConstants.shared.dotTextBy(email: invitationRegisteredAccount.email)
            nameLabel.text = invitationRegisteredAccount.email
        }
    }

}
