//
//  GSMUserInputCell.swift
//  Depo
//
//  Created by Aleksandr on 6/12/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol GSMCodeCellDelegate {
    func codeViewGotTapped()
    func phoneNumberChanged(toNumber number: String)
}

class GSMUserInputCell: BaseUserInputCellView {

    @IBOutlet weak var gsmCountryCodeLabel: UILabel!
    @IBOutlet weak var gsmCodeContainerView: UIView!
    var delegate: GSMCodeCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gsmCodeContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GSMUserInputCell.codeViewTouched)))
    }
    
    override func setupBaseCell(withTitle title: String, inputText text: String) {
        super.setupBaseCell(withTitle: title, inputText: text)
        addBarToKeyboard()
    }
    
    func addBarToKeyboard() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 50)
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: TextConstants.nextTitle, style: .plain, target: self, action: #selector(nextButtonPressed(sender:)))
        
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        
        toolBar.setItems([flex, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textInputField.inputAccessoryView = toolBar
    }
    
    @objc func nextButtonPressed(sender: Any?) {
        textDelegate?.textFinishedEditing(withCell: self)
        inputTextField?.resignFirstResponder()
    }
    
    func setupGSMCode(code: String) {
        gsmCountryCodeLabel.text = code
    }
    
    @objc func codeViewTouched() {
        changeInfoButtonTo(hidden: true)
        delegate?.phoneNumberChanged(toNumber: textInputField.text!)
        delegate?.codeViewGotTapped()
    }
}

extension GSMUserInputCell {
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        var number = textField.text!
        let isTurkeyNumber = gsmCountryCodeLabel.text == "+90"
        if isTurkeyNumber, number.first == "0" {
            let sliceRange = number.index(after: number.startIndex)...
            number = String(number[sliceRange])
        }
        textField.text = number
        delegate?.phoneNumberChanged(toNumber: number)
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        changeInfoButtonTo(hidden: true)
    }
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let notAvailableCharacterSet = CharacterSet.decimalDigits.inverted
        let result = string.rangeOfCharacter(from: notAvailableCharacterSet)
        return result == nil
    }
    
}
