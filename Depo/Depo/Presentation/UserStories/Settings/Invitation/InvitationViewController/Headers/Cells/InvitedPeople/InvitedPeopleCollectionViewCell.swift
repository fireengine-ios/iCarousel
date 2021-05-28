//
//  InvitedPeopleCollectionViewCell.swift
//  Depo
//
//  Created by Alper Kırdök on 7.05.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

class InvitedPeopleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileShortCutLabel: UILabel!
    @IBOutlet weak var profileNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(invitationRegisteredAccount: InvitationRegisteredAccount, bgColor: UIColor) {
        profileImageView.backgroundColor = bgColor

        if let name = invitationRegisteredAccount.name, name.count > 0 {
            profileShortCutLabel.text = AccountConstants.shared.dotTextBy(name: name)
            profileNameLabel.text = name
        } else {
            profileShortCutLabel.text = AccountConstants.shared.dotTextBy(email: invitationRegisteredAccount.email)
            profileNameLabel.text = invitationRegisteredAccount.email
        }
    }
}
