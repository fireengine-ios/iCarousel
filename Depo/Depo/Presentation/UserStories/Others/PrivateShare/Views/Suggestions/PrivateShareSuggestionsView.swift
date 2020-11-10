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
    
    private func setup(with contacts: [SuggestedContact]) {
        guard !contacts.isEmpty else {
            return
        }
  
        contacts.enumerated().forEach { index, contact in
            let view = PrivateShareContactSuggestionView.with(contact: contact, delegate: self)
            suggestionsView.addArrangedSubview(view)
            
            if index != contacts.count - 1 {
                let separator = makeSeparator()
                suggestionsView.addArrangedSubview(separator)
                separator.heightAnchor.constraint(equalToConstant: 1).activate()
            }
        }
    }
    
    private func makeSeparator() -> UIView {
        var frame = CGRect(origin: .zero, size: CGSize(width: suggestionsView.frame.width, height: 1))
        let view = UIView(frame: frame)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let offset: CGFloat = 16
        frame.origin.x = offset
        frame.size.width -= offset * 2
        let separator = UIView(frame: frame)
        separator.backgroundColor = ColorConstants.darkBorder.withAlphaComponent(0.3)
        view.addSubview(separator)
        separator.autoresizingMask = [.flexibleWidth]
        return view
    }
}

extension PrivateShareSuggestionsView: PrivateShareContactSuggestionViewDelegate {
    func selectContact(info: ContactInfo) {
        delegate?.didSelect(contactInfo: info)
    }
}
