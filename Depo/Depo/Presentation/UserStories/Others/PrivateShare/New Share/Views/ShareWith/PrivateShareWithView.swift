//
//  PrivateShareWithView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareWithViewDelegate: AnyObject {
    func shareListDidEmpty()
    func onUserRoleTapped(contact: PrivateShareContact, sender: Any)
}

final class PrivateShareWithView: UIView, NibInit {
    
    static func with(contacts: [PrivateShareContact], delegate: PrivateShareWithViewDelegate?) -> PrivateShareWithView {
        let view = PrivateShareWithView.initFromNib()
        view.setup(with: contacts)
        view.delegate = delegate
        return view
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.privateShareStartPageSharedWithTitle
            newValue.font = UIFont.appFont(.medium, size: 14)
            newValue.textColor = AppColor.filesLabel.color
        }
    }
    
    @IBOutlet private weak var stackView: UIStackView!
    
    private(set) var contacts = [PrivateShareContact]()
    private weak var delegate: PrivateShareWithViewDelegate?
    
    //MARK: - Public
    
    func add(contact: PrivateShareContact) {
        guard !contacts.contains(contact) else {
            return
        }
        contacts.append(contact)
        addContactView(with: contact)
    }
    
    func update(contact: PrivateShareContact) {
        if let index = contacts.firstIndex(where: { $0 == contact }),
           let view = stackView.arrangedSubviews[safe: index] as? PrivateShareWithContactView {
            contacts[index] = contact
            view.setup(with: contact)
        }
    }
    
    //MARK: - Private
    
    private func setup(with contacts: [PrivateShareContact]) {
        self.contacts = contacts
        contacts.forEach { addContactView(with: $0) }
    }
    
    private func addContactView(with contact: PrivateShareContact) {
        let view = PrivateShareWithContactView.with(contact: contact, delegate: self)
        stackView.addArrangedSubview(view)
        layoutIfNeeded()
    }
}

//MARK: - PrivateShareWithContactViewDelegate

extension PrivateShareWithView: PrivateShareWithContactViewDelegate {
    
    func onDeleteTapped(contact: PrivateShareContact) {
        contacts.remove(contact)
        
        if contacts.isEmpty {
            delegate?.shareListDidEmpty()
        }
    }
    
    func onUserRoleTapped(contact: PrivateShareContact) {
        delegate?.onUserRoleTapped(contact: contact, sender: self)
    }
}

//MARK: - PrivateShareUserRoleViewControllerDelegate

extension PrivateShareWithView: PrivateShareUserRoleViewControllerDelegate {
    
    func contactRoleDidChange(_ contact: PrivateShareContact) {
        update(contact: contact)
    }
}
