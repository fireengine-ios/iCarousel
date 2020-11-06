//
//  PrivateShareContactSuggestionView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareContactSuggestionViewDelegate: class {
    
}

final class PrivateShareContactSuggestionView: UIView, NibInit {
    
    static func with(contact: SuggestedApiContact, delegate: PrivateShareContactSuggestionViewDelegate?) -> PrivateShareContactSuggestionView {
        let view = PrivateShareContactSuggestionView.initFromNib()
        view.delegate = delegate
        view.setup(with: contact)
        return view
    }
    
    @IBOutlet private weak var nameLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .TurkcellSaturaMedFont(size: 16)
            newValue.textColor = .lrBrownishGrey
        }
    }
    
    @IBOutlet private weak var itemsStackView: UIStackView!
    
    private weak var delegate: PrivateShareContactSuggestionViewDelegate?
    
    private func setup(with contact: SuggestedApiContact) {
        nameLabel.text = contact.name ?? ""
        
        if let phone = contact.username {
            itemsStackView.addArrangedSubview(PrivateShareSuggestionItemView.with(text: phone, delegate: self))
        }
        
        if let email = contact.email {
            itemsStackView.addArrangedSubview(PrivateShareSuggestionItemView.with(text: email, delegate: self))
        }
    }
}

extension PrivateShareContactSuggestionView: PrivateShareSuggestionItemViewDelegate {
    func addItem(string: String) {
        
    }
}
