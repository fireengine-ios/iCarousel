//
//  ContactInfoView.swift
//  Depo
//
//  Created by Andrei Novikau on 6/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ContactInfoView: UIView, NibInit {
    
    @IBOutlet private weak var categoryLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = ColorConstants.lightText
            newValue.font = .appFont(.medium, size: 14)
        }
    }
    
    @IBOutlet private weak var infoLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = ColorConstants.duplicatesGray
            newValue.font = .appFont(.medium, size: 20)
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    func configure(with category: ContactSectionCategory, value: String) {
        categoryLabel.text = category.title
        infoLabel.text = value
    }
}
