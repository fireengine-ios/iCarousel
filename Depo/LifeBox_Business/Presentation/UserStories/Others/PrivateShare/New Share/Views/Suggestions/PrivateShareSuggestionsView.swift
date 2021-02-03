//
//  PrivateShareSuggestionsView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PrivateShareSuggestionsView: UIView, NibInit {
    
    static func with(contacts: [SuggestedContact], delegate: PrivateShareSelectSuggestionsDelegate?) -> PrivateShareSuggestionsView {
        let view = PrivateShareSuggestionsView.initFromNib()
        view.delegate = delegate
        view.setup(with: contacts)
        return view
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.privateShareStartPageSuggestionsTitle
            newValue.font = .TurkcellSaturaBolFont(size: 14)
            newValue.textColor = ColorConstants.marineTwo
        }
    }
    
    @IBOutlet private weak var suggestionsView: UIStackView!
    
    private weak var delegate: PrivateShareSelectSuggestionsDelegate?
    private lazy var analytics = PrivateShareAnalytics()
    
    private func setup(with contacts: [SuggestedContact]) {
        guard !contacts.isEmpty else {
            return
        }
  
        contacts.enumerated().forEach { index, contact in
            let view = PrivateShareContactSuggestionView.with(contact: contact, delegate: self)
            suggestionsView.addArrangedSubview(view)
            
            let separator = UIView.makeSeparator(width: suggestionsView.frame.width, offset: 16)
            suggestionsView.addArrangedSubview(separator)
            separator.heightAnchor.constraint(equalToConstant: 1).activate()
        }
    }
}

extension PrivateShareSuggestionsView: PrivateShareContactSuggestionViewDelegate {
    func selectContact(info: ContactInfo) {
        analytics.addApiSuggestion()
        delegate?.didSelect(contactInfo: info)
    }
}
