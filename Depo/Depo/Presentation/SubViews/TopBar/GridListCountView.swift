//
//  GridListCountView.swift
//  Depo
//
//  Created by Burak Donat on 19.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

protocol GridListCountViewDelegate: AnyObject {
    func cancelSelection()
}

class GridListCountView: UIView, NibInit {
    
    weak var delegate: GridListCountViewDelegate?
    
    @IBOutlet private weak var countLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.medium, size: 14)
        }
    }
    
    @IBOutlet private weak var cancelButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.cancel, for: .normal)
            newValue.accessibilityLabel = TextConstants.cancel
            newValue.setTitleColor(AppColor.label.color, for: .normal)
            newValue.setTitleColor(AppColor.label.color, for: .highlighted)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
        }
    }
    
    @IBAction func onCancelButton(_ sender: UIButton) {
        delegate?.cancelSelection()
    }
    
    func setCountLabel(with numberOfSelectedItems: Int) {
        let title = String(numberOfSelectedItems) + " " + TextConstants.accessibilitySelected
        countLabel.text = title
    }
    
}
