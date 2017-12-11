//
//  LoginPhoneMailCell.swift
//  Depo
//
//  Created by Aleksandr on 7/10/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

//
protocol LoginPhoneMailCellActionProtocol: class {
    func firstCharacterIsPlus(fromCell cell: LoginPhoneMailCell, string: String)
    func firstCharacterIsNum(fromCell cell: LoginPhoneMailCell, string: String)
}
class LoginPhoneMailCell: BaseUserInputCellView {
    
    weak var loginCellActionDelegate: LoginPhoneMailCellActionProtocol?
    private var code: String = ""
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.count == 0, string == "+" {
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
        
        if code == "+90" && text[3] == "0" {
            text.remove(at: text[3])
            textInputField.text = text
        }
        
    }
    
    func enterPhoneCode(code: String) {
        textInputField.text = textInputField.text! + code
    }
    
    func incertPhoneCode(code: String) {
        self.code = code
        textInputField?.text = code + (textInputField?.text ?? "")
    }
    
}
