//
//  ContactListSectionHeader.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 5/29/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ContactListSectionHeader: UIView {
    
    private var label: UILabel = {
        let label = UILabel()
        label.textColor = AppColor.contactHeader.color
        label.font = .appFont(.medium, size: 16.0)
        return label
    }()
    
    func setup(with text: String) {
        backgroundColor = AppColor.secondaryBackground.color
        
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        topAnchor.constraint(equalTo: label.topAnchor).activate()
        bottomAnchor.constraint(equalTo: label.bottomAnchor).activate()
        leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: -16).activate()
        trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 16).activate()
    }
}
