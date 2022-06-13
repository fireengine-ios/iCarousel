//
//  PrivateShareSuggestionItemView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareSuggestionItemViewDelegate: AnyObject {
    func addItem(string: String)
}

enum SuggestionItemType {
    case phone
    case email
}

final class PrivateShareSuggestionItemView: UIView, NibInit {

    static func with(text: String, type: SuggestionItemType, delegate: PrivateShareSuggestionItemViewDelegate?) -> PrivateShareSuggestionItemView {
        let view = PrivateShareSuggestionItemView.initFromNib()
        view.delegate = delegate
        view.type = type
        
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
            newValue.font = UIFont.appFont(.light, size: 14)
        }
    }
    
    @IBOutlet private weak var addButton: UIButton!
    
    private weak var delegate: PrivateShareSuggestionItemViewDelegate?
    private var type: SuggestionItemType = .phone
    
    @IBAction private func onAddTapped(_ sender: UIButton) {
        delegate?.addItem(string: titleLabel.text ?? "")
    }
    
}
