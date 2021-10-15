//
//  ContactDetailHeader.swift
//  Depo
//
//  Created by Andrei Novikau on 6/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ContactDetailHeader: UIView, NibInit {
    
    @IBOutlet private weak var lettersView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = newValue.bounds.width * 0.5
            newValue.backgroundColor = ColorConstants.photoCell
        }
    }
    
    @IBOutlet private weak var lettersLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = ColorConstants.duplicatesGray
            newValue.font = .TurkcellSaturaDemFont(size: 40)
            newValue.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var stackView: UIStackView! {
        willSet {
            newValue.spacing = 4
        }
    }
    
    @IBOutlet private weak var nameLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = .lrBrownishGrey
            newValue.font = .TurkcellSaturaDemFont(size: 24)
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var companyLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = ColorConstants.lightText
            newValue.font = .TurkcellSaturaFont(size: 16)
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = ColorConstants.toolbarTintColor
    }
    
    func configure(with contact: RemoteContact) {
        lettersLabel.text = contact.initials
        nameLabel.text = contact.name
        companyLabel.text = contact.company
    }
    
}
