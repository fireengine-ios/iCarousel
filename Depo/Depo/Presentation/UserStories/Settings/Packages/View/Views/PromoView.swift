//
//  PromoView.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/30/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol PromoViewDelegate: class {
    func promoView(_ promoView: PromoView, didPressApplyWithPromocode promocode: String)
}

final class PromoView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = TextConstants.promocodeTitle
            titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 14)
            titleLabel.textColor = ColorConstants.textGrayColor
        }
    }
    
    @IBOutlet weak var errorLabel: UILabel! {
        didSet {
            errorLabel.text = ""
            errorLabel.font = UIFont.TurkcellSaturaRegFont(size: 15)
            errorLabel.textColor = ColorConstants.textOrange
        }
    }
    
    @IBOutlet weak var codeTextField: InsetsTextField! {
        didSet {
            codeTextField.layer.cornerRadius = 5
            codeTextField.layer.borderColor = ColorConstants.darkBorder.cgColor
            codeTextField.layer.borderWidth = 1
            
            codeTextField.font = UIFont.TurkcellSaturaRegFont(size: 14)
            
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: ColorConstants.grayTabBarButtonsColor,
                .font: UIFont.TurkcellSaturaRegFont(size: 14)
            ]
            codeTextField.attributedPlaceholder = NSAttributedString(string: TextConstants.promocodePlaceholder, attributes: attributes)
        }
    }
    
    @IBOutlet weak var applyButton: UIButton! {
        didSet {
            applyButton.setTitle(TextConstants.apply, for: .normal)
            applyButton.setTitleColor(UIColor.white, for: .normal)
            applyButton.backgroundColor = ColorConstants.darkBlueColor
            applyButton.layer.cornerRadius = 15
            applyButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        }
    }
    
    weak var deleagte: PromoViewDelegate?
    
    @IBAction func actionApplyButton(_ sender: UIButton) {
        deleagte?.promoView(self, didPressApplyWithPromocode: codeTextField.text!)
    }
}
