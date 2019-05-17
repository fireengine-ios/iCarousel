//
//  SecurityCodeTextField.swift
//  Depo
//
//  Created by 12345 on 5/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SecurityCodeTextField: UITextField {
    
    private enum Constants {
        static let heightBottomLine: CGFloat = 3
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupDesign()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
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
                                  y: frame.height - Constants.heightBottomLine,
                                  width: 18.0,
                                  height: Constants.heightBottomLine)
        bottomLine.backgroundColor = ColorConstants.coolGrey.cgColor
        bottomLine.cornerRadius = 2
        layer.addSublayer(bottomLine)
    }

}
