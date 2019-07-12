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
    
    @IBOutlet private weak var separatorView: UIView! {
        willSet {
            newValue.isHidden = true
        }
    }
    
    @IBOutlet private weak var typeAuthorizationLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.lightGray
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 15)
        }
    }
    
    @IBOutlet private weak var userDataLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 15)
        }
    }
    
    @IBOutlet private weak var selectButton: UIButton! 
    
    private var cellIndexPathRow: Int?
    
    var delegate: TwoFactorAuthenticationCellDelegate?
    
    func setupCell(typeDescription: String, userData: String, isNeedToShowSeparator: Bool) {
        typeAuthorizationLabel.text = typeDescription
        userDataLabel.text = userData
        separatorView.isHidden = !isNeedToShowSeparator
    }
    
    func setCellIndexPath(index: Int) {
        self.cellIndexPathRow = index
    }
    
    func setSelected(selected: Bool) {
        
        UIView.transition(with: selectButton, duration: 1.25, options: .transitionCrossDissolve, animations: {
            if selected {
                self.selectButton.setImage(UIImage(named: "selectedRectangle"), for: .normal)
            } else {
                self.selectButton.setImage(UIImage(named: "emtyRectangle"), for: .normal)
            }
        }, completion: nil)
        
//        if selected {
//            selectButton.setImage(UIImage(named: "selectedRectangle"), for: .normal)
//        } else {
//            selectButton.setImage(UIImage(named: "emtyRectangle"), for: .normal)
//        }
    }
    
    @IBAction private func selectedButtonTapped(_ sender: Any) {
        guard let index = cellIndexPathRow else {
            assertionFailure()
            return
        }
        delegate?.selectButtonPressed(cell: index)
    }
    
}
