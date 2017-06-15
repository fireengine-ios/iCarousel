//
//  BaseUserInputCellView.swift
//  Depo
//
//  Created by Aleksandr on 6/9/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class BaseUserInputCellView: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textInputField: UITextField!
    @IBOutlet weak var InfoImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.textInputField.becomeFirstResponder()
        self.textInputField.delegate = self
        self.titleLabel.textColor = ColorConstants.yellowColor
    }
    
    func setupBaseCell(withTitle title: String, inputText text: String) {
        self.titleLabel.text = title
        if self.textInputField.attributedPlaceholder?.string != text {
            self.textInputField.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: ColorConstants.yellowColor])
        }
    }
}

extension BaseUserInputCellView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textInputField.resignFirstResponder()
        return false
    }
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        self.textInputField.becomeFirstResponder()
//        if self.textInputField.text?.characters.count == 1 {
//            self.InfoImage.isHidden = true
//        }
//    }
//    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard let text = self.textInputField.text else {
//            return false
//        }
////        let charactersCount =
//        if string.characters.count > 0, text.characters.count + 1 > 0 {
//            self.InfoImage.isHidden = true
//        } else if string.characters.count == 0, text.characters.count - 1 == 0 {
//            self.InfoImage.isHidden = false
//        }
//        return true
//    }
//    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if self.textInputField.text?.characters.count == 0 {
//            self.InfoImage.isHidden = false
//        }
//    }
}
