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
    
    static func with(contact: SuggestedContact, delegate: PrivateShareContactSuggestionViewDelegate?) -> PrivateShareContactSuggestionView {
        let view = PrivateShareContactSuggestionView.initFromNib()
        view.delegate = delegate
        view.setup(with: contact)
        return view
    }
    
    @IBOutlet private weak var nameLabel: UILabel!
    
    @IBOutlet private weak var itemsStackView: UIStackView!
    
    private weak var delegate: PrivateShareContactSuggestionViewDelegate?
    
    private func setup(with contact: SuggestedContact) {
        
    }
}
