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

class GSMUserInputCell: ProtoInputTextCell {//BaseUserInputCellView {

    @IBOutlet weak var gsmCountryCodeLabel: UILabel!
    @IBOutlet weak var gsmCodeContainerView: UIView!
    @IBOutlet weak var textInputField: UITextField!{
        didSet {
            inputTextField = textInputField
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var infoIcon: UIImageView!
    
    var delegate: GSMCodeCellDelegate?
    weak var infoButtonDelegate: InfoButtonCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gsmCodeContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GSMUserInputCell.codeViewTouched)))
        textInputField.delegate = self
        changeInfoButtonTo(hidden: true)
    }
    
    func setupCell(withTitle title: String, inputText text: String) {
        addBarToKeyboard()
        textInputField.text = text
        titleLabel.text = title
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
    
    func changeTitleHeighlight(heighlight: Bool) {
        if heighlight {
            titleLabel.textColor = ColorConstants.whiteColor
        } else {
            titleLabel.textColor = ColorConstants.yellowColor
        }
    }
    
    override func changeInfoButtonTo(hidden: Bool) {
//        infoButton.isEnabled = false//!hidden
//        infoButton.isHidden = hidden
        infoIcon.isHidden = hidden
        changeTitleHeighlight(heighlight: hidden)
    }
    
    @IBAction func infoButtonAction(_ sender: Any) {
//        infoButtonDelegate?.infoButtonGotPressed(with: self, andType: .phoneNotValid)
    }
}

extension GSMUserInputCell {
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        var number = textField.text!
        if gsmCountryCodeLabel.text == "+90", number.first == "0", let index = number.index(of: "0") {
            number = String(number[number.index(after: index)...])
        }
        textField.text = number
        delegate?.phoneNumberChanged(toNumber: number)
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        changeInfoButtonTo(hidden: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let notAvailableCharacterSet = CharacterSet.decimalDigits.inverted
        let result = string.rangeOfCharacter(from: notAvailableCharacterSet)
        return result == nil
    }
    
}
