//
//  ContactsBackupDetailsView.swift
//  Depo
//
//  Created by Maxim Soldatov on 6/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol ContactsBackupHistoryViewDelegate: class {
    func restoreBackupTapped()
    func deleteBackupTapped()
}

final class ContactsBackupHistoryView: UIView, NibInit {
    
    @IBOutlet weak var tableView: UITableView! {
        willSet {
            newValue.tableFooterView = UIView()
        }
    }
    
    @IBOutlet private weak var headerLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.contactBackupHistoryHeader
        }
    }
    
    @IBOutlet private weak var restoreBackupButton: RoundedButton! {
        willSet {
            newValue.backgroundColor = ColorConstants.marineTwo
            newValue.setTitle(TextConstants.contactBackupHistoryRestoreButton, for: .normal)
        }
    }
    
    @IBOutlet private weak var deleteBuckupButton: RoundedButton! {
        willSet {
            newValue.tintColor = ColorConstants.marineTwo
            newValue.layer.borderColor = ColorConstants.marineTwo.cgColor
            newValue.layer.borderWidth = 1.0
            newValue.setTitle(TextConstants.contactBackupHistoryDeleteButton, for: .normal)
        }
    }
    
    weak var delegate: ContactsBackupHistoryViewDelegate?
    
    @IBAction func restoreBackupTapped(_ sender: UIButton) {
        delegate?.restoreBackupTapped()
    }
    
    @IBAction func deleteBackupTapped(_ sender: UIButton) {
        delegate?.deleteBackupTapped()
    }
}
