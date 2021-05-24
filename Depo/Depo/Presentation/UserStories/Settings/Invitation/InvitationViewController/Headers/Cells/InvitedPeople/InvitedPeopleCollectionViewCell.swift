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

        if let name = invitationRegisteredAccount.name, name.length > 0 {
            profileShortCutLabel.text = self.dotTextBy(name: name)
            profileNameLabel.text = name
        } else {
            profileShortCutLabel.text = self.dotTextBy(email: invitationRegisteredAccount.email)
            profileNameLabel.text = invitationRegisteredAccount.email
        }
    }

    // Using Name
    private func dotTextBy(name: String) -> String {
        let fullNameArray = name.components(separatedBy: " ")
        let firstName = fullNameArray.first
        let lastName = fullNameArray.last
        var firstLetterOfName = ""
        var firstLetterOfLastname = ""

        if let firstName = firstName {
            firstLetterOfName = firstName[0]
        }

        if let lastName = lastName {
            firstLetterOfLastname = lastName[0]
        }

        return firstLetterOfName + firstLetterOfLastname
    }

    // Using Email
    private func dotTextBy(email: String) -> String {
        return email[1]
    }

}
