//
//  PasswordCell.swift
//  Depo
//
//  Created by Aleksandr on 6/14/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class PasswordCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var showBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.textInput.delegate = self
    }
    @IBAction func showButtonPressed(_ sender: Any) {
    }
}

//extension PasswordCell: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.textInput.resignFirstResponder()
//        return false
//    }
//    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        self.textInput.becomeFirstResponder()
//        if self.textInput.text?.characters.count == 1 {
//            self.InfoImage.isHidden = true
//        }
//    }
//    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard let text = self.textInput.text else {
//            return false
//        }
//        //        let charactersCount =
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
//}
