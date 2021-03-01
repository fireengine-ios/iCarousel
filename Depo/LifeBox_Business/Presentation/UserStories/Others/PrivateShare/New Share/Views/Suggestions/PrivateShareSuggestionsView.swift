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
    
    @IBOutlet weak var scrollableContent: UIScrollView! {
        willSet {
            newValue.translatesAutoresizingMaskIntoConstraints = false
            newValue.isScrollEnabled = true
            newValue.showsVerticalScrollIndicator = true
            newValue.showsHorizontalScrollIndicator = false
            newValue.alwaysBounceHorizontal = false
            newValue.alwaysBounceVertical = true
        }
    }

    @IBOutlet private weak var suggestionsView: UIStackView! {
        willSet {
            newValue.translatesAutoresizingMaskIntoConstraints = false
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fill
            newValue.spacing = 0
        }
    }
    
    private lazy var heightConstraint = heightAnchor.constraint(equalToConstant: 0)
    private weak var delegate: PrivateShareSelectSuggestionsDelegate?
    private lazy var analytics = PrivateShareAnalytics()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        heightConstraint.activate()
    }
   
    func setup(with contacts: [SuggestedContact]) {
        defer {
            setNeedsLayout()
        }
        
        suggestionsView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard !contacts.isEmpty else {
            heightConstraint.constant = 0
            return
        }
  
        var contentHeight: CGFloat = 0
        
        contacts.enumerated().forEach { index, contact in
            let view = PrivateShareContactSuggestionView.with(contact: contact, delegate: self)
            suggestionsView.addArrangedSubview(view)
            
            contentHeight += view.bounds.size.height
        }
        
        updateHeightConstraint(contentHeight: contentHeight)
    }
    
    private func updateHeightConstraint(contentHeight: CGFloat) {
        let screenMaxHeight = UIScreen.main.bounds.height / 3
        let height = min(contentHeight, screenMaxHeight)
        heightConstraint.constant = height
    }
}

extension PrivateShareSuggestionsView: PrivateShareContactSuggestionViewDelegate {
    func selectContact(info: ContactInfo) {
        analytics.addApiSuggestion()
        delegate?.didSelect(contactInfo: info)
    }
}
