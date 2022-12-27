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
            newValue.backgroundColor = AppColor.grayMain.color
        }
    }
    
    @IBOutlet private weak var letterLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .appFont(.medium, size: 14.4)
            newValue.textColor = AppColor.darkBlue.color
        }
    }
    
    @IBOutlet private weak var nameLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .appFont(.medium, size: 14.0)
            newValue.textColor = AppColor.label.color
        }
    }
    
    @IBOutlet private weak var phoneLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .appFont(.light, size: 14.0)
            newValue.textColor = AppColor.label.color
        }
    }
    
    func configure(with contact: RemoteContact) {
        nameLabel.text = contact.name
        phoneLabel.text = contact.phone
        letterLabel.text = contact.initials
    }
}
