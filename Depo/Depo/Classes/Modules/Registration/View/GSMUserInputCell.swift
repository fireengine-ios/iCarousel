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
            self.inputTextField = textInputField
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    
    var delegate: GSMCodeCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gsmCodeContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GSMUserInputCell.codeViewTouched)))
        self.textInputField.delegate = self
    }
    
    func setupCell(withTitle title: String, inputText text: String) {
        self.textInputField.text = text
        self.titleLabel.text = title
    }
    
    func setupGSMCode(code: String) {
        self.gsmCountryCodeLabel.text = code
        
    }
    
    func codeViewTouched() {
        self.delegate?.phoneNumberChanged(toNumber: self.textInputField.text!)
        self.delegate?.codeViewGotTapped()
    }
}

extension GSMUserInputCell {
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.phoneNumberChanged(toNumber: self.textInputField.text!)
        self.textDelegate?.textFinishedEditing(withCell: self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let notAvailableCharacterSet = CharacterSet(charactersIn: "1234567890")//TODO: MAKE a Numeric text field class
        
//        let oldString: NSString? = textField.text as NSString?
//        let newString = oldString?.replacingCharacters(in: range, with: string)//replacingCharacters(in: <#T##Range<String.Index>#>, with: string)//(in: range, with: string)
        guard string.rangeOfCharacter(from: notAvailableCharacterSet) != nil || string == ""  else {
            return false
        }
        return true//(string.rangeOfCharacter(from: notAvailableCharacterSet) != nil)
    }
}
