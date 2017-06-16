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
    @IBOutlet weak var infoImage: UIImageView!
    
    var sequreTexieldAndMessage: Bool = true {
        
        willSet (newValue) {
            var title = TextConstants.hidePassword
            if (newValue) {
                title = TextConstants.showPassword
            }
            textInput.isSecureTextEntry = newValue
            showBtn.setTitle(title, for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textInput.delegate = self
        titleLabel.textColor = ColorConstants.yellowColor
    }
    
    func setupInitialState(withLabelTitle title: String, placeHolderText placeholder: String) {
        titleLabel.text = title
        if textInput.attributedPlaceholder?.string != placeholder {
            textInput.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                                 attributes: [NSForegroundColorAttributeName: ColorConstants.yellowColor])
        }
    }
    
    @IBAction func showButtonPressed(_ sender: Any) {
        sequreTexieldAndMessage = !sequreTexieldAndMessage
    }
}

extension PasswordCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textInput.resignFirstResponder()
        return false
    }
}
