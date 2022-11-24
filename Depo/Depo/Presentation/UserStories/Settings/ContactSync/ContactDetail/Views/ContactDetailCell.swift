//
//  ContactDetailCell.swift
//  Depo
//
//  Created by Andrei Novikau on 6/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

typealias ContactDetailInfo = (category: ContactSectionCategory, values: [String])

enum ContactSectionCategory {
    case phone
    case email
    case address
    case birthday
    case notes
    
    var title: String {
        switch self {
        case .phone:
            return TextConstants.contactDetailSectionPhone
        case .email:
            return TextConstants.contactDetailSectionEmail
        case .address:
            return TextConstants.contactDetailSectionAddress
        case .birthday:
            return TextConstants.contactDetailSectionBirthday
        case .notes:
            return TextConstants.contactDetailSectionNotes
        }
    }
    
    var image: UIImage? {
        switch self {
        case .phone:
            return UIImage(named: "contact_phone")
        case .email:
            return Image.contact_email.image
        case .address:
            return Image.contact_address.image
        case .birthday:
            return UIImage(named: "contact_birthday")
        case .notes:
            return UIImage(named: "contact_notes")
        }
    }
}

final class ContactDetailCell: UITableViewCell {

    @IBOutlet private weak var stackView: UIStackView! {
        willSet {
            newValue.spacing = 8
        }
    }
    
    @IBOutlet private weak var categoryImageView: UIImageView!
    
    func configure(with info: ContactDetailInfo) {
        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0) }

        categoryImageView.image = info.category.image
        
        info.values.forEach { value in
            let view = ContactInfoView.initFromNib()
            view.configure(with: info.category, value: value)
            stackView.addArrangedSubview(view)
        }
    }
    
}
