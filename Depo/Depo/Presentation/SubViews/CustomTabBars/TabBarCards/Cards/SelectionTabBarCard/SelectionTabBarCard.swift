//
//  SelectionTabBarCard.swift
//  Depo
//
//  Created by Burak Donat on 14.09.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

final class SelectionTabBarCard: BaseTabBarCard {
    @IBOutlet private weak var countLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 12)
            newValue.textColor = .white
            newValue.textAlignment = .left
        }
    }
    
    @IBOutlet weak var cancelButton: RoundedButton! {
        willSet {
            newValue.backgroundColor = .clear
            newValue.setTitle(TextConstants.cancel, for: .normal)
            newValue.titleLabel?.font = .appFont(.regular, size: 12)
            newValue.setTitleColor(.white, for: .normal)
            newValue.setTitleColor(.white.darker(by: 30), for: .highlighted)
        }
    }
    
    @IBAction func onCancelButton(_ sender: RoundedButton) {
        CardsManager.default.stopOperationWith(type: .itemSelection)
        ItemOperationManager.default.stopItemSelection()
    }
    
    func setCountLabel(count: Int) {
        countLabel.text = "\(count) \(TextConstants.accessibilitySelected)"
    }
}
