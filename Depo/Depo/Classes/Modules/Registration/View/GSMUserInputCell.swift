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

class GSMUserInputCell: UITableViewCell {//BaseUserInputCellView {

    @IBOutlet weak var gsmCountryCodeLabel: UILabel!
    @IBOutlet weak var gsmCodeContainerView: UIView!
    @IBOutlet weak var textInputField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    var delegate: GSMCodeCellDelegate?
    var notAvailableChracterSet: CharacterSet = CharacterSet(charactersIn: "1234567890")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gsmCodeContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GSMUserInputCell.codeViewTouched)))
        self.textInputField.delegate = self
    }
    
    func setupCell(withTitle title: String, inputText text: String, cellType type: CellTypes) {
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

extension GSMUserInputCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textInputField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.phoneNumberChanged(toNumber: self.textInputField.text!)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return (string.rangeOfCharacter(from: notAvailableChracterSet) != nil)
    }
}
