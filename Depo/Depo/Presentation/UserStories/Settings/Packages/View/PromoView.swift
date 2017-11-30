//
//  PromoView.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/30/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class InsetsTextField: UITextField {
    @IBInspectable var insetX: CGFloat = 5 {
        didSet { layoutIfNeeded() }
    }
    @IBInspectable var insetY: CGFloat = 5 {
        didSet { layoutIfNeeded() }
    }
    
    /// placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    /// text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
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
            
            let attributes = [NSAttributedStringKey.foregroundColor: ColorConstants.grayTabBarButtonsColor,
                              NSAttributedStringKey.font: UIFont.TurkcellSaturaRegFont(size: 14)]
            codeTextField.attributedPlaceholder = NSAttributedString(string: TextConstants.promocodePlaceholder, attributes: attributes)
        }
    }
    
    @IBOutlet weak var applyButton: UIButton! {
        didSet {
            applyButton.setTitle(TextConstants.apply, for: .normal)
            applyButton.setTitleColor(UIColor.white, for: .normal)
            applyButton.backgroundColor = ColorConstants.darcBlueColor
            applyButton.layer.cornerRadius = 15
        }
    }
    
    let offersService: OffersService = OffersServiceIml()
    
    @IBAction func actionApplyButton(_ sender: UIButton) {
        
        offersService.submit(promocode: codeTextField.text!,
            success: { [weak self] response in
                guard let response = response as? SubmitPromocodeResponse else { return }
                DispatchQueue.main.async {
                    CustomPopUp.sharedInstance.showCustomInfoAlert(withTitle: TextConstants.errorAlert, withText: TextConstants.promocodeSuccess, okButtonText: TextConstants.ok)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.errorLabel.text = TextConstants.promocodeError
                }
        })
    }
}
