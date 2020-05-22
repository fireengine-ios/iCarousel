//
//  ContactSyncMainView.swift
//  Depo
//
//  Created by Konstantin Studilin on 21.05.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ContactSyncMainView: UIView, NibInit {

    @IBOutlet weak var cardsStack: UIStackView! {
        willSet {
            newValue.alignment = .fill
            newValue.distribution = .equalSpacing
            newValue.spacing = 24.0
        }
    }
    
    
    func update() {
        DispatchQueue.main.async {
            for _ in 0..<6 {
                let card = ContactSyncSmallCardView.initFromNib()
                self.cardsStack.addArrangedSubview(card)
            }
        }
    }
    
}
