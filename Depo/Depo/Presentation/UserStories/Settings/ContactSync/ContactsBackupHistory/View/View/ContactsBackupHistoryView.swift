//
//  ContactsBackupDetailsView.swift
//  Depo
//
//  Created by Maxim Soldatov on 6/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol ContactsBackupHistoryViewDelegate: AnyObject {
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
            newValue.font = .appFont(.regular, size: 16)
            newValue.textColor = AppColor.label.color
        }
    }
    
    @IBOutlet private weak var restoreBackupButton: RoundedButton! {
        willSet {
            newValue.setTitle(TextConstants.contactBackupHistoryRestoreButton, for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = AppColor.darkBlueColor.color
            newValue.titleLabel?.font = .appFont(.medium, size: 16.0)
        }
    }
    
    @IBOutlet private weak var deleteBuckupButton: RoundedButton! {
        willSet {
            newValue.layer.borderColor = ColorConstants.navy.cgColor
            newValue.layer.borderWidth = 1.0
            newValue.setTitle(TextConstants.contactBackupHistoryDeleteButton, for: .normal)
            newValue.setTitleColor(ColorConstants.navy, for: .normal)
            newValue.backgroundColor = .white
            newValue.titleLabel?.font = .appFont(.medium, size: 16.0)
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
