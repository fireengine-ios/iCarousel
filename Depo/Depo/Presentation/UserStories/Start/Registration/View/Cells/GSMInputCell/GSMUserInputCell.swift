//
//  GSMUserInputCell.swift
//  Depo
//
//  Created by Aleksandr on 6/12/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

enum GSMUserInputCellStyle {
    case registration
    case textEnter
}

protocol GSMCodeCellDelegate: class {
    func codeViewGotTapped()
    func phoneNumberChanged(toNumber number: String)
}

final class GSMUserInputCell: BaseUserInputCellView {

    @IBOutlet weak var gsmCountryCodeLabel: UILabel!
    @IBOutlet weak var gsmCodeContainerView: UIView!
    @IBOutlet var separators: [UIView]!
    weak var delegate: GSMCodeCellDelegate?
    
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
        toolBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 50)
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: TextConstants.nextTitle,
                                         target: self,
                                         selector: #selector(nextButtonPressed(sender:)))
        doneButton.tintColor = UIColor.lrTealish
        
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
    
    func setup(style: GSMUserInputCellStyle) {
        switch style {
        case .registration:
            titleLabel.font = .TurkcellSaturaBolFont(size: 16)
            gsmCountryCodeLabel.textColor = UIColor.white.lighter(by: 10)
            titleLabel.textColor = .white
            textInputField.textColor = .white
            separators.forEach { view in
                view.backgroundColor = .white
            }
            defaultTitleHightlightColor = .white
        case .textEnter:
            titleLabel.font = .TurkcellSaturaBolFont(size: 14)
            titleLabel.textColor = ColorConstants.textGrayColor
            gsmCountryCodeLabel.textColor = ColorConstants.textGrayColor            
            textInputField.textColor = ColorConstants.textGrayColor
            separators.forEach { view in
                view.backgroundColor = ColorConstants.textLightGrayColor
            }
            defaultTitleHightlightColor = ColorConstants.textLightGrayColor
        }
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
