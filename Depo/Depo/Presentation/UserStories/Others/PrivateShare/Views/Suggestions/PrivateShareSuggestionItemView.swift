//
//  PrivateShareSuggestionItemView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareSuggestionItemViewDelegate: class {
    func addItem(string: String)
}

final class PrivateShareSuggestionItemView: UIView, NibInit {

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .TurkcellSaturaFont(size: 18)
        }
    }
    
    @IBOutlet private weak var addButton: UIButton!
    
    @IBAction private func onAddTapped(_ sender: UIButton) {
        
    }
}
