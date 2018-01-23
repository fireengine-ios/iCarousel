//
//  ManageContactTableViewCell.swift
//  Depo_LifeTech
//
//  Created by Raman on 1/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol ManageContactTableViewCellDelegate: class {
    func cell(_ cell: ManageContactTableViewCell, deleteContact: RemoteContact)
}

class ManageContactTableViewCell: UITableViewCell {

    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var nameLabel: UILabel!
    
    weak var delegate: ManageContactTableViewCellDelegate?
    var contact: RemoteContact?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        deleteButton.setTitle(TextConstants.settingsBackUpDeleteContactButton, for: .normal)
    }
    
    func configure(with contact: RemoteContact, delegate: ManageContactTableViewCellDelegate?) {
        self.delegate = delegate
        self.contact = contact
        
        nameLabel.text = contact.name
    }
    
    @IBAction private func onDeleteTapped(_ sender: Any) {
        if let contact = contact {
            delegate?.cell(self, deleteContact: contact)
        }
    }
}
