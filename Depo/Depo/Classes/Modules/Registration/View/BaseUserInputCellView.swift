//
//  BaseUserInputCellView.swift
//  Depo
//
//  Created by Aleksandr on 6/9/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class BaseUserInputCellView: UITableViewCell {
    
//    @IBOutlet weak var inputFieldLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textInputField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.textInputField.becomeFirstResponder()
        self.textInputField.delegate = self
    }
    
    
    func setupBaseCell(withTitle title: String, inputText text: String, cellType type: CellTypes) {
        self.titleLabel.text = title
        self.textInputField.text = text
    }
}

extension BaseUserInputCellView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textInputField.resignFirstResponder()
        return false
    }
}
