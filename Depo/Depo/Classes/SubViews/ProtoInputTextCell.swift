//
//  ProtoInputTextCell.swift
//  Depo
//
//  Created by Aleksandr on 6/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol ProtoInputCellProtocol: class  {
    func textFinishedEditing(withCell cell: ProtoInputTextCell)
//    func
}

class ProtoInputTextCell: UITableViewCell {
    
    var inputTextField: UITextField? {
        didSet {
            inputTextField?.delegate = self
        } 
    }
    weak var textDelegate: ProtoInputCellProtocol?
    
    func startEditing() {
        self.inputTextField?.becomeFirstResponder()
    }
    
    
    
}

extension ProtoInputTextCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.inputTextField?.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.textDelegate?.textFinishedEditing(withCell: self)
    }
}
