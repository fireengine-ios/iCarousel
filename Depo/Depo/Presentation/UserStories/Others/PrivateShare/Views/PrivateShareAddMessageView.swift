//
//  PrivateShareAddMessageView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PrivateShareAddMessageView: UIView, NibInit {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.privateShareStartPageAddMessageTitle
            newValue.font = .TurkcellSaturaBolFont(size: 16)
            newValue.textColor = ColorConstants.marineTwo
        }
    }
    
    @IBOutlet private weak var textView: PlaceholderTextView! {
        willSet {
            newValue.text = ""
            newValue.placeholder = TextConstants.privateShareStartPageMessagePlaceholder
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.contentInset = .zero
            newValue.isScrollEnabled = false
        }
    }
    
    var message: String {
        textView.text
    }
}
