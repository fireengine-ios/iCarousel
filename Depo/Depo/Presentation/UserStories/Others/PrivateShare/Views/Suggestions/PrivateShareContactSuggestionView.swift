//
//  PrivateShareContactSuggestionView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareContactSuggestionViewDelegate: class {
    func selectContact(string: String)
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
            newValue.font = .TurkcellSaturaMedFont(size: 16)
            newValue.textColor = .lrBrownishGrey
        }
    }
    
    @IBOutlet private weak var itemsStackView: UIStackView!
    
    private weak var delegate: PrivateShareContactSuggestionViewDelegate?
    
    private func setup(with contact: SuggestedContact) {
        nameLabel.text = contact.displayName
        nameView.isHidden = contact.displayName.isEmpty

        let items = contact.phones + contact.emails
        items.forEach { item in
            itemsStackView.addArrangedSubview(PrivateShareSuggestionItemView.with(text: item, delegate: self))
        }
    }
}

extension PrivateShareContactSuggestionView: PrivateShareSuggestionItemViewDelegate {
    func addItem(string: String) {
        delegate?.selectContact(string: string)
    }
}
