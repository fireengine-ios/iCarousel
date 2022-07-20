//
//  PrivateShareWithContactView.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 11/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareWithContactViewDelegate: AnyObject {
    func onDeleteTapped(contact: PrivateShareContact)
    func onUserRoleTapped(contact: PrivateShareContact)
}

final class PrivateShareWithContactView: UIView, NibInit {

    static func with(contact: PrivateShareContact, delegate: PrivateShareWithContactViewDelegate?) -> PrivateShareWithContactView {
        let view = PrivateShareWithContactView.initFromNib()
        view.setup(with: contact)
        view.delegate = delegate
        return view
    }
    
    @IBOutlet private weak var borderView: UIView! {
        willSet {
            newValue.clipsToBounds = true
            newValue.layer.cornerRadius = newValue.frame.height * 0.5
            newValue.backgroundColor = AppColor.filesSharedInfoBackground.color
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .appFont(.light, size: 14)
            newValue.lineBreakMode = .byTruncatingMiddle
            newValue.textColor = AppColor.filesLabel.color
        }
    }
    
    @IBOutlet private weak var deleteButton: UIButton!
    
    @IBOutlet private weak var userRoleButton: UIButton! {
        willSet {
            newValue.setTitleColor(AppColor.filesLabel.color, for: .normal)
            newValue.titleLabel?.font = UIFont.appFont(.medium, size: 14)
            newValue.forceImageToRightSide()
            newValue.imageEdgeInsets.left = -10
        }
    }
    
    private weak var delegate: PrivateShareWithContactViewDelegate?
    private var contact: PrivateShareContact?
    
    //MARK: - Public
    
    func setup(with contact: PrivateShareContact) {
        self.contact = contact
        if contact.displayName.isEmpty {
            if contact.username.contains("@") {
                titleLabel.text = contact.username
            } else {
                let allowedCharacterSet = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "+()"))
                titleLabel.text = contact.username.components(separatedBy: allowedCharacterSet.inverted).joined()
            }
        } else {
            titleLabel.text = contact.displayName
        }
        
        userRoleButton.setTitle(contact.role.title, for: .normal)
    }
    
    //MARK: - Private
    
    @IBAction private func onDeleteTapped(_ sender: UIButton) {
        if let contact = contact {
            delegate?.onDeleteTapped(contact: contact)
        }
        removeFromSuperview()
    }
    
    @IBAction private func onUserRoleTapped(_ sender: UIButton) {
        if let contact = contact {
            delegate?.onUserRoleTapped(contact: contact)
        }
    }
}
