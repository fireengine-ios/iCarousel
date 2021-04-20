//
//  PrivateShareSuggestionItemView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

enum SuggestionItemType {
    case phone
    case email
}

final class PrivateShareSuggestionItemView: UIView, NibInit {
    
    static func with(contact: SuggestedContact, text: String, type: SuggestionItemType) -> PrivateShareSuggestionItemView {
        let view = PrivateShareSuggestionItemView.initFromNib()
        view.type = type
        view.contact = contact
        view.backgroundColor = .clear
        
        if type == .phone {
            let allowedCharacterSet = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "+()"))
            view.titleLabel.text = text.components(separatedBy: allowedCharacterSet.inverted).joined()
        } else {
            view.titleLabel.text = text
        }
        
        return view
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .GTAmericaStandardRegularFont(size: 12)
            newValue.textColor = ColorConstants.Text.labelTitle
        }
    }
    
    private var type: SuggestionItemType = .phone
    private var contact: SuggestedContact?
}
