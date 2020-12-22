//
//  ProtoInputTextCell.swift
//  Depo
//
//  Created by Aleksandr on 6/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol ProtoInputCellProtocol: class {
    
    func textFinishedEditing(withCell cell: ProtoInputTextCell)
    
    func textStartedEditing(withCell cell: ProtoInputTextCell)
}

class ProtoInputTextCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
    }
    
    var inputTextField: UITextField? {
        didSet {
            inputTextField?.delegate = self
        } 
    }
    
    var placeholderText: String?
    
    weak var textDelegate: ProtoInputCellProtocol?
    
    func startEditing() {
        inputTextField?.becomeFirstResponder()
    }
    
    func changeInfoButtonTo(hidden: Bool) {
        
    }
    
    func changeReturnKey(to key: UIReturnKeyType) {
        inputTextField?.returnKeyType = key
    }
}

extension ProtoInputTextCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textDelegate?.textFinishedEditing(withCell: self)
        self.inputTextField?.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.textDelegate?.textStartedEditing(withCell: self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
