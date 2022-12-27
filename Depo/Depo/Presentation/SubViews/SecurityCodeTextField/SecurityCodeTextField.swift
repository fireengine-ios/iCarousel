//
//  SecurityCodeTextField.swift
//  Depo
//
//  Created by 12345 on 5/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SecurityCodeTextField: UITextField {
    
    private let bottomLine = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupDesign()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupDesign()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: Utility methods
    private func setupDesign() {
        keyboardType = .phonePad
        tintColor = .clear
        font = .appFont(.medium, size: 24)
        textAlignment = .center
        layer.borderWidth = 2
        layer.cornerRadius = 6
        layer.borderColor = AppColor.forgetPassCodeClose.cgColor
        layer.masksToBounds = true
        backgroundColor = .clear
        textColor = AppColor.forgetPassText.color
    }
}
