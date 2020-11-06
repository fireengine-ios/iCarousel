//
//  PrivateShareSuggestionsView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareSuggestionsViewDelegate: class {
    
}

final class PrivateShareSuggestionsView: UIView, NibInit {
    
    static func with(contacts: [SuggestedContact], delegate: PrivateShareSuggestionsViewDelegate?) -> PrivateShareSuggestionsView {
        let view = PrivateShareSuggestionsView.initFromNib()
        view.delegate = delegate
        view.setup(with: contacts)
        return view
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            
        }
    }
    
    @IBOutlet private weak var suggestionsView: UIStackView!
    
    private weak var delegate: PrivateShareSuggestionsViewDelegate?
    
    
    private func setup(with contacts: [SuggestedContact]) {
        
    }
}
