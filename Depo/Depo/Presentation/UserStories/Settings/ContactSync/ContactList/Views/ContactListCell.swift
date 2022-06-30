//
//  ContactListCell.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 5/29/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ContactListCell: UITableViewCell {
    
    @IBOutlet private weak var letterView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = newValue.bounds.height * 0.5
            newValue.backgroundColor = ColorConstants.photoCell
        }
    }
    
    @IBOutlet private weak var letterLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .appFont(.regular, size: 20.0)
            newValue.textColor = ColorConstants.duplicatesGray
        }
    }
    
    @IBOutlet private weak var nameLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .appFont(.medium, size: 16.0)
            newValue.textColor = .lrBrownishGrey
        }
    }
    
    @IBOutlet private weak var phoneLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .appFont(.regular, size: 12.0)
            newValue.textColor = ColorConstants.duplicatesGray
        }
    }
    
    func configure(with contact: RemoteContact) {
        nameLabel.text = contact.name
        phoneLabel.text = contact.phone
        letterLabel.text = contact.initials
    }
}
