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

protocol ContactsBackupCellDelegate: AnyObject {
    func selectCellButtonTapped(for cell: UITableViewCell & ContactsBackupCellProtocol)
}

final class ContactsBackupCell: UITableViewCell, ContactsBackupCellProtocol {
    
    @IBOutlet private weak var selectButton: ExtendedTapAreaButton! {
        willSet {
            newValue.setImage(Image.iconRadioButtonUnselect.image, for: .normal)
            newValue.setImage(Image.iconRadioButtonSelectBlue.image, for: .highlighted)
            newValue.setImage(Image.iconRadioButtonSelectBlue.image, for: .selected)
            newValue.tintColor = AppColor.darkBlueAndTealish.color
        }
    }
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.medium, size: 14)
        }
    }
    
    @IBOutlet private weak var detailLabel: UILabel!{
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.light, size: 14)
        }
    }
    
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
