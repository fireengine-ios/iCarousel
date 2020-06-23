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
    
    func setupCell(title: String, detail: String)
    func manageSelectionState(isCellSelected: Bool)
}

protocol ContactsBackupCellDelegate: class {
    func selectCellButtonTapped(for cell: UITableViewCell & ContactsBackupCellProtocol)
}

final class ContactsBackupCell: UITableViewCell, ContactsBackupCellProtocol {
    
    @IBOutlet private weak var selectButton: ExtendedTapAreaButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    
    weak var delegate: ContactsBackupCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func setupCell(title: String, detail: String) {
        titleLabel.text = title
        detailLabel.text = detail
    }
    
    func manageSelectionState(isCellSelected: Bool) {
        let image = isCellSelected ? UIImage(named: "selected_by_point") : UIImage(named: "notSelected")
        selectButton.setImage(image, for: .normal)
    }
    
    @IBAction private func selectButtonTapped(_ sender: UIButton) {
        delegate?.selectCellButtonTapped(for: self)
    }
}
