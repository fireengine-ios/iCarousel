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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.count == 0, string == "+" {
            loginCellActionDelegate?.firstCharacterIsPlus(fromCell: self, string: string)
            return false
        } else if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil, textField.text?.count == 0 {
            loginCellActionDelegate?.firstCharacterIsNum(fromCell: self, string: string)
            if string == "0", CoreTelephonyService().isTurkcellOperator() { return false }
        }

        return true
    }
    
    func enterPhoneCode(code: String) {
        textInputField.text = textInputField.text! + code
    }
    
    func incertPhoneCode(code: String) {
        textInputField?.text = code + (textInputField?.text ?? "")
    }
    
}
