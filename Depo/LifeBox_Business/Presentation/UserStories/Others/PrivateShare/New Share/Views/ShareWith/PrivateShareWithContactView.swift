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
    
    @available(iOS 14, *)
    func onUserRoleChanged(contact: PrivateShareContact)
}

final class PrivateShareWithContactView: UIView, NibInit {

    static func with(contact: PrivateShareContact, delegate: PrivateShareWithContactViewDelegate?) -> PrivateShareWithContactView {
        let view = PrivateShareWithContactView.initFromNib()
        view.setup(with: contact)
        view.delegate = delegate
        return view
    }

    @IBOutlet private weak var contactFiledsStack: UIStackView! {
        willSet {
            newValue.axis = .vertical
            newValue.alignment = .leading
            newValue.distribution = .fillProportionally
            newValue.spacing = 5
        }
    }
    
    @IBOutlet private weak var deleteButton: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            newValue.setImage(UIImage(named: "cancelButton"), for: .normal)
        }
    }
    
    @IBOutlet private weak var userRoleButton: UIButton! {
        willSet {
            newValue.setImage(UIImage(named: "arrowDown"), for: .normal)
            newValue.setTitleColor(ColorConstants.Text.labelTitle.color, for: .normal)
            newValue.titleLabel?.font = .GTAmericaStandardMediumFont(size: 14)
            newValue.tintColor = ColorConstants.Text.labelTitle.color
            newValue.forceImageToRightSide()
            newValue.imageEdgeInsets.left = -8
        }
    }
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.font = .GTAmericaStandardMediumFont(size: 12)
        label.textColor = ColorConstants.Text.labelTitle.color
        label.text = ""
        return label
    }()
    
    private lazy var groupNameLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.font = .GTAmericaStandardRegularFont(size: 14)
        label.textColor = ColorConstants.Text.labelTitle.color
        label.text = ""
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.font = .GTAmericaStandardRegularFont(size: 12)
        label.textColor = ColorConstants.Text.labelTitle.color
        label.text = ""
        return label
    }()
    
    private weak var delegate: PrivateShareWithContactViewDelegate?
    private var contact: PrivateShareContact?
    
    //MARK: - Public
    
    func setup(with contact: PrivateShareContact) {
        contactFiledsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        self.contact = contact
        
        switch contact.type {
            case .user, .knownName:
                if !contact.displayName.isEmpty {
                    nameLabel.text = contact.displayName
                    contactFiledsStack.addArrangedSubview(nameLabel)
                }
                
                if !contact.username.isEmpty {
                    if contact.username.contains("@") {
                        emailLabel.text = contact.username
                    } else {
                        let allowedCharacterSet = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "+()"))
                        emailLabel.text = contact.username.components(separatedBy: allowedCharacterSet.inverted).joined()
                    }
                    
                    contactFiledsStack.addArrangedSubview(emailLabel)
                }
                
            case .group:
                groupNameLabel.text = contact.displayName
                contactFiledsStack.addArrangedSubview(groupNameLabel)
        }
        
        userRoleButton.setTitle(contact.role.title, for: .normal)
        setupUserRoleMenu()
    }
    
    //MARK: - Private
    
    @IBAction private func onDeleteTapped(_ sender: UIButton) {
        if let contact = contact {
            delegate?.onDeleteTapped(contact: contact)
        }
        removeFromSuperview()
    }
    
    @objc private func onUserRoleTapped(_ sender: UIButton) {
        if let contact = contact {
            delegate?.onUserRoleTapped(contact: contact)
        }
    }
    
    private func setupUserRoleMenu() {
        if #available(iOS 14, *) {
            let completion: ValueHandler<PrivateShareUserRole> = { [weak self] updatedRole in
                if updatedRole != self?.contact?.role {
                    self?.contact?.role = updatedRole
                    self?.userRoleButton.setTitle(updatedRole.title, for: .normal)
                    self?.setupUserRoleMenu()
                    
                    if let updatedContact = self?.contact {
                        self?.delegate?.onUserRoleChanged(contact: updatedContact)
                    }
                }
            }
            
            let roles: [PrivateShareUserRole] = [.viewer, .editor]
            let menu = MenuItemsFabric.privateShareUserRoleMenu(roles: roles, currentRole: contact?.role ?? .viewer, completion: completion)
            userRoleButton.showsMenuAsPrimaryAction = true
            userRoleButton.menu = menu
            
        } else {
            userRoleButton.addTarget(self, action: #selector(onUserRoleTapped), for: .touchUpInside)
        }
    }
}
