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
    
    private let selectedRadioButtonImage = UIImage(named: "selectedRectangle")
    private let deselectedRadioButtonImage = UIImage(named: "emtyRectangle")

    @IBOutlet private weak var receiveMethodLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.lightGray
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 15)
        }
    }
    
    @IBOutlet private weak var selectButton: UIButton! 
    
    private var cellIndexPathRow: Int?
    
    var delegate: TwoFactorAuthenticationCellDelegate?
    
    override func awakeFromNib() {
        
        selectButton.setImage(deselectedRadioButtonImage, for: .normal)
        selectButton.setImage(selectedRadioButtonImage, for: .selected)
    }
    
    func setupCell(typeDescription: String, userData: String) {
        let receiveMethod = String(format: "%@ %@", typeDescription, userData)
        let attributedString = NSMutableAttributedString(string: receiveMethod)

        if let range = receiveMethod.range(of: userData) {
            let nsRange = NSRange(location: range.lowerBound.encodedOffset,
                                  length: range.upperBound.encodedOffset - range.lowerBound.encodedOffset)
            
            attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: nsRange)
        }

        receiveMethodLabel.attributedText = attributedString
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
