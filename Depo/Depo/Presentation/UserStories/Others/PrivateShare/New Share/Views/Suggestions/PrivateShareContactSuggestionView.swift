//
//  PrivateShareContactSuggestionView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareContactSuggestionViewDelegate: AnyObject {
    func selectContact(info: ContactInfo)
}

final class PrivateShareContactSuggestionView: UIView, NibInit {
    
    static func with(contact: SuggestedContact, delegate: PrivateShareContactSuggestionViewDelegate?) -> PrivateShareContactSuggestionView {
        let view = PrivateShareContactSuggestionView.initFromNib()
        view.delegate = delegate
        view.setup(with: contact)
        return view
    }
    
    @IBOutlet private weak var nameView: UIView!
    
    @IBOutlet private weak var nameLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = UIFont.appFont(.medium, size: 14)
            newValue.textColor = AppColor.filesLabel.color
        }
    }
    
    @IBOutlet private weak var itemsStackView: UIStackView!
    
    private weak var delegate: PrivateShareContactSuggestionViewDelegate?
    
    private func setup(with contact: SuggestedContact) {
        nameLabel.text = contact.displayName
        nameView.isHidden = contact.displayName.isEmpty

        contact.phones.forEach { item in
            let item = PrivateShareSuggestionItemView.with(text: item, type: .phone, delegate: self)
            itemsStackView.addArrangedSubview(item)
        }
        
        if contact.isLocal || contact.phones.isEmpty {
            contact.emails.forEach { item in
                let item = PrivateShareSuggestionItemView.with(text: item, type: .email, delegate: self)
                itemsStackView.addArrangedSubview(item)
            }
        }
        
        layoutIfNeeded()
    }
}

extension PrivateShareContactSuggestionView: PrivateShareSuggestionItemViewDelegate {
    func addItem(string: String) {
        let contact = ContactInfo(name: nameLabel.text ?? "", value: string)
        delegate?.selectContact(info: contact)
    }
}
