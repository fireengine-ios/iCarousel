//
//  PrivateShareWithContactView.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 11/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareWithContactViewDelegate: class {
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
            newValue.backgroundColor = ColorConstants.marineTwo
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .TurkcellSaturaDemFont(size: 16)
            newValue.lineBreakMode = .byTruncatingMiddle
            newValue.textColor = .white
        }
    }
    
    @IBOutlet private weak var deleteButton: UIButton! {
        willSet {
            newValue.imageEdgeInsets = UIEdgeInsets(topBottom: 8, rightLeft: 8)
        }
    }
    
    @IBOutlet private weak var userRoleButton: UIButton! {
        willSet {
            newValue.setTitleColor(.lrTealishFour, for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 18)
            newValue.tintColor = .lrTealishFour
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
