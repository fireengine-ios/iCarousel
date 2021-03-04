//
//  TwoFactorAuthenticationCell.swift
//  Depo
//
//  Created by Maxim Soldatov on 7/11/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol TwoFactorAuthenticationCellDelegate {
    func selectButtonPressed(cell index: Int)
}

final class TwoFactorAuthenticationCell: UITableViewCell {
    
    private let selectedRadioButtonImage = UIImage(named: "selected_method")
    private let deselectedRadioButtonImage = UIImage(named: "not_selected_method")

    @IBOutlet private weak var innerContentView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = ColorConstants.a2FABorderColor.cgColor
            newValue.backgroundColor = ColorConstants.tableBackground
        }
    }

    @IBOutlet private weak var methodLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.a2FAMethodLabel
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 12)
        }
    }

    @IBOutlet private weak var valueLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.infoPageValueText
            newValue.font = UIFont.GTAmericaStandardMediumFont(size: 12)
        }
    }
    
    @IBOutlet private weak var selectButton: UIButton! 
    
    private var cellIndexPathRow: Int?
    
    var delegate: TwoFactorAuthenticationCellDelegate?
    
    override func awakeFromNib() {
        contentView.backgroundColor = ColorConstants.tableBackground
        selectButton.setImage(deselectedRadioButtonImage, for: .normal)
        selectButton.setImage(selectedRadioButtonImage, for: .selected)
    }
    
    func setupCell(typeDescription: String, userData: String) {
        methodLabel.text = typeDescription
        valueLabel.text = userData
    }
    
    func setCellIndexPath(index: Int) {
        self.cellIndexPathRow = index
    }
    
    func setSelected(selected: Bool) {
        selectButton.isSelected = selected
    }
    
    @IBAction private func selectedButtonTapped(_ sender: Any) {
        guard let index = cellIndexPathRow else {
            assertionFailure()
            return
        }
        delegate?.selectButtonPressed(cell: index)
    }
}
