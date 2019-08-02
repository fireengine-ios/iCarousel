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
        static let widthBottomLine: CGFloat = 18
    }
    
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
        updateLineFrame()
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
        bottomLine.backgroundColor = ColorConstants.coolGrey.cgColor
        bottomLine.cornerRadius = 2
        
        layer.addSublayer(bottomLine)
    }
    
    private func updateLineFrame() {
        let x = bounds.midX - Constants.widthBottomLine / 2
        
        bottomLine.frame = CGRect(x: x,
                                  y: frame.height - Constants.heightBottomLine,
                                  width: Constants.widthBottomLine,
                                  height: Constants.heightBottomLine)
    }

}
