//
//  PrivateShareContactSuggestionView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareContactSuggestionViewDelegate: class {
    func selectContact(info: ContactInfo)
}

final class PrivateShareContactSuggestionView: UIView, NibInit {
    
    static func with(contact: SuggestedContact, delegate: PrivateShareContactSuggestionViewDelegate?) -> PrivateShareContactSuggestionView {
        let view = PrivateShareContactSuggestionView.initFromNib()
        view.delegate = delegate
        view.setup(with: contact)
        return view
    }
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.font = .GTAmericaStandardMediumFont(size: 12)
        label.textColor = ColorConstants.Text.labelTitle
        label.text = ""
        return label
    }()
    
    private lazy var groupNameLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.font = .GTAmericaStandardRegularFont(size: 14)
        label.textColor = ColorConstants.Text.labelTitle
        label.text = ""
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.font = .GTAmericaStandardRegularFont(size: 12)
        label.textColor = ColorConstants.Text.labelTitle
        label.text = ""
        return label
    }()
    
    @IBOutlet private weak var contactFiledsStack: UIStackView! {
        willSet {
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fillEqually
        }
    }
    
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onSelect))
    
    private weak var delegate: PrivateShareContactSuggestionViewDelegate?
    
    private var contact: SuggestedContact?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setup(with contact: SuggestedContact) {
        self.contact = contact
        
        switch contact.type {
            case .user, .knownName:
                if !contact.displayName.isEmpty {
                    nameLabel.text = contact.displayName
                    contactFiledsStack.addArrangedSubview(nameLabel)
                }
                
                if let email = contact.emails.first, !email.isEmpty {
                    emailLabel.text = email
                    
                    contactFiledsStack.addArrangedSubview(emailLabel)
                }
                
            case .group:
                groupNameLabel.text = contact.displayName
                contactFiledsStack.addArrangedSubview(groupNameLabel)
        }
        
        layoutIfNeeded()
    }
    
    @objc private func onSelect() {
        guard let contact = contact else {
            return
        }
        
        let contactInfo = ContactInfo(name: contact.displayName, value: contact.emails.first ?? "", identifier: contact.identifier, userType: contact.type)
        
        delegate?.selectContact(info: contactInfo)
    }
}
