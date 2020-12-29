//
//  CodeTextField.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/28/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CodeTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bottomBorder.frame.size.width = layer.frame.width
    }
    
    var inputTextLimit = NumericConstants.verificationCharacterLimit
    var underlineColor = UIColor.gray
    var underlineWidth: CGFloat = 1
    let fontKern = 20
    
    private lazy var bottomBorder = CALayer()
    
    private func setup() {
        delegate = self
        
        font = UIFont.TurkcellSaturaBolFont(size: 37)
        textColor = ColorConstants.darkText
        textAlignment = .center
        
        bottomBorder.frame = CGRect(x: 0, y: frame.height - underlineWidth, width: frame.width, height: underlineWidth)
        bottomBorder.backgroundColor = underlineColor.cgColor
        layer.addSublayer(bottomBorder)
    }
    
    private func isAvailableCharacters(in text: String) -> Bool {
        return text.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}

extension CodeTextField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard isAvailableCharacters(in: string),
            let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string),
            newString.count <= inputTextLimit
            else { return false }
        
        typingAttributes?[NSAttributedStringKey.kern.rawValue] = fontKern
        
        return true
    }
}
