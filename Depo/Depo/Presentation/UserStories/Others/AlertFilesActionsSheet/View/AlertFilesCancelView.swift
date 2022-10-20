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
    
    @IBOutlet private weak var cancelButton: WhiteButton! {
        willSet {
            newValue.setTitle(TextConstants.cancel, for: .normal)
            newValue.accessibilityLabel = TextConstants.cancel
        }
    }
    
    @IBOutlet private weak var seperatorView: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.separator.color
        }
    }
    
    @IBAction func onCancelButton(_ sender: RoundedButton) {
        delegate?.onCancelButton()
    }
}

