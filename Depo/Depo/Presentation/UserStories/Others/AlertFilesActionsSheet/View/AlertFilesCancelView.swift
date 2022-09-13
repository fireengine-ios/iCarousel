//
//  AlertFilesCancelView.swift
//  Depo
//
//  Created by Burak Donat on 19.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol AlertFilesCancelViewDelegate: AnyObject {
    func onCancelButton()
}

class AlertFilesCancelView: UIView, NibInit {
    
    weak var delegate: AlertFilesCancelViewDelegate?
    
    @IBOutlet private weak var cancelButton: RoundedButton! {
        willSet {
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = AppColor.drawerButtonBorder.cgColor
            newValue.setTitle(TextConstants.cancel, for: .normal)
            newValue.accessibilityLabel = TextConstants.cancel
            newValue.setTitleColor(AppColor.darkLabel.color, for: .normal)
            newValue.setTitleColor(AppColor.darkLabel.color, for: .highlighted)
            newValue.backgroundColor = .white
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
        }
    }
    
    @IBAction func onCancelButton(_ sender: RoundedButton) {
        delegate?.onCancelButton()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        cancelButton.layer.borderColor = AppColor.drawerButtonBorder.cgColor
    }
}

