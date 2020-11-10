//
//  PrivateShareLocalContactCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 09.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit


protocol PrivateShareLocalContactCellDelegate: class {
    func didSelect(contactInfo: ContactInfo)
}


final class PrivateShareLocalContactCell: UITableViewCell {
    
    weak var delegate: PrivateShareLocalContactCellDelegate?
    
    private var contactInfoView: PrivateShareContactSuggestionView?
    private var currentContact: SuggestedContact?

    
    //MARK - Public
    
    func update(with contact: SuggestedContact) {
        guard contact != currentContact else {
            return
        }
        
        currentContact = contact
        setupInfoView()
    }
    
    //MARK - Private
    
    private func setupInfoView() {
        
        contactInfoView?.removeFromSuperview()
        
        guard let contact = currentContact else {
            return
        }
        
        contactInfoView = PrivateShareContactSuggestionView.with(contact: contact, delegate: self)
        
        if let contactInfoView = contactInfoView {
            contentView.addSubview(contactInfoView)
            contactInfoView.translatesAutoresizingMaskIntoConstraints = false
            
            contactInfoView.topAnchor.constraint(equalTo: contentView.topAnchor).activate()
            contactInfoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).activate()
            contactInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).activate()
            contactInfoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).activate()
        }
        layoutIfNeeded()
    }
}


extension PrivateShareLocalContactCell: PrivateShareContactSuggestionViewDelegate {
    func selectContact(string: String) {
        delegate?.didSelect(contactInfo: ContactInfo(name: currentContact?.displayName ?? "", value: string))
    }
}
