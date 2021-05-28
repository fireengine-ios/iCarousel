//
//  AcceptedPeopleCollectionViewCell.swift
//  Depo
//
//  Created by Alper Kırdök on 26.05.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

class AcceptedPeopleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var shortNameBGView: UIView!
    @IBOutlet weak var shortNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(invitationRegisteredAccount: InvitationRegisteredAccount, bgColor: UIColor) {
        shortNameBGView.backgroundColor = bgColor

        if let name = invitationRegisteredAccount.name, name.count > 0 {
            shortNameLabel.text = AccountConstants.shared.dotTextBy(name: name)
            nameLabel.text = name
        } else {
            shortNameLabel.text = AccountConstants.shared.dotTextBy(email: invitationRegisteredAccount.email)
            nameLabel.text = invitationRegisteredAccount.email
        }
    }

}
