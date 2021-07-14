//
//  LoginPhoneMailCell.swift
//  Depo
//
//  Created by Aleksandr on 7/10/17.
//  Copyright © 2017 com.igones. All rights reserved.
//


protocol LoginPhoneMailCellActionProtocol: AnyObject {
    func firstCharacterIsPlus(fromCell cell: LoginPhoneMailCell, string: String)
    func firstCharacterIsNum(fromCell cell: LoginPhoneMailCell, string: String)
}
class LoginPhoneMailCell: BaseUserInputCellView {
    
    weak var loginCellActionDelegate: LoginPhoneMailCellActionProtocol?

    override var textInputField: UITextField! {
        didSet {
            textInputField.keyboardType = .default
        }
    }

    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        } else if textField.text?.count == 0, string == "+" {
            loginCellActionDelegate?.firstCharacterIsPlus(fromCell: self, string: string)
            return false
        } else if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil, textField.text?.count == 0 {
            loginCellActionDelegate?.firstCharacterIsNum(fromCell: self, string: string)
        }
        return true
    }

    override func textFieldDidEndEditing(_ textField: UITextField) {
        guard var text = textInputField.text else {
            return
        }
        
        text = text.removingWhiteSpaces()
        textInputField.text = text
        
        guard let range = text.range(of: "+(90)0") else {
            return
        }
        
        if text.startIndex == range.lowerBound {
            text.remove(at: text[5])
            textInputField.text = text
        }
    }
    
    func enterPhoneCode(code: String) {
        textInputField.text = textInputField.text! + code
    }
    
    func incertPhoneCode(code: String) {
        textInputField?.text = code + (textInputField?.text ?? "")
    }
}
