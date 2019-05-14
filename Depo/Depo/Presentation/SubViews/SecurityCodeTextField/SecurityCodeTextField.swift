//
//  SecurityCodeTextField.swift
//  Depo
//
//  Created by 12345 on 5/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SecurityCodeTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
                
        setupDesign()
    }
    
    // MARK: Utility methods
    private func setupDesign() {
        keyboardType = .phonePad
        tintColor = .clear
        font = UIFont.TurkcellSaturaBolFont(size: 36)
        textColor = .black
        textAlignment = .center
        
        addBottomBorder()
    }
    
    private func addBottomBorder() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 6.0,
                                  y: frame.height - 3.0,
                                  width: 18.0,
                                  height: 3.0)
        bottomLine.backgroundColor = ColorConstants.coolGrey.cgColor
        bottomLine.cornerRadius = 2
        layer.addSublayer(bottomLine)
    }

}
