//
//  SnackbarView.swift
//  Depo
//
//  Created by Andrei Novikau on 4/22/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class SnackbarView: UIView, NibInit {
    
    @IBOutlet weak var contentView: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.tint.color
            newValue.clipsToBounds = true
            newValue.layer.cornerRadius = 16
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .appFont(.regular, size: 14)
            newValue.textColor = .white
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var actionButton: UIButton! {
        willSet {
            newValue.setBackgroundColor(.white, for: .normal)
            newValue.setTitleColor(AppColor.button.color, for: .normal)
            newValue.titleLabel?.font = UIFont.appFont(.medium, size: 16)
            newValue.isOpaque = true
            newValue.clipsToBounds = true
            newValue.layer.cornerRadius = 16
            newValue.isHidden = true
        }
    }
    @IBOutlet weak var actionButtonWidth: NSLayoutConstraint!
    
    static let shared = SnackbarView()
    
    private var action: VoidHandler?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func with(type: SnackbarType, message: String, actionTitle: String?, axis: NSLayoutConstraint.Axis, action: VoidHandler?) -> SnackbarView {
        let view = SnackbarView.initFromNib()
        
        view.titleLabel.text = message
        view.actionButtonWidth.constant = 0
        
        if let actionTitle = actionTitle {
            view.actionButton.setTitle(actionTitle, for: .normal)
            view.action = action
            view.actionButton.isHidden = false
            view.actionButtonWidth.constant = 140
        }

        return view
    }

    @IBAction func onActionButtonTap(_ sender: Any) {
        action?()
    }
}
