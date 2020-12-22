//
//  ContactsBackupCell.swift
//  Depo
//
//  Created by Maxim Soldatov on 6/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol ContactsBackupCellProtocol {
    var delegate: ContactsBackupCellDelegate? { get set }
    var isCellSelected: Bool { get set }
    
    func setupCell(title: String, detail: String, isSelected: Bool)
}

protocol ContactsBackupCellDelegate: class {
    func selectCellButtonTapped(for cell: UITableViewCell & ContactsBackupCellProtocol)
}

final class ContactsBackupCell: UITableViewCell, ContactsBackupCellProtocol {
    
    @IBOutlet private weak var selectButton: ExtendedTapAreaButton! {
        willSet {
            newValue.setImage(UIImage(named: "notSelected"), for: .normal)
            newValue.setImage(UIImage(named: "selected_by_point"), for: .highlighted)
            newValue.setImage(UIImage(named: "selected_by_point"), for: .selected)
        }
    }
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    
    weak var delegate: ContactsBackupCellDelegate?
    
    var isCellSelected: Bool = false {
        didSet {
            selectButton.isSelected = isCellSelected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = .disclosureIndicator
    }
    
    func setupCell(title: String, detail: String, isSelected: Bool) {
        titleLabel.text = title
        detailLabel.text = detail
        isCellSelected = isSelected
    }
    
    @IBAction private func selectButtonTapped(_ sender: UIButton) {
        delegate?.selectCellButtonTapped(for: self)
        isCellSelected = true
    }
}
