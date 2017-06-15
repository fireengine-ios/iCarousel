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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textInput.delegate = self
        self.titleLabel.textColor = ColorConstants.yellowColor
    }
    
    func setupInitialState(withLabelTitle title: String, placeHolderText placeholder: String) {
        titleLabel.text = title
        if self.textInput.attributedPlaceholder?.string != placeholder {
            self.textInput.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: ColorConstants.yellowColor])
        }
    }
    
    @IBAction func showButtonPressed(_ sender: Any) {
        self.changeBtnText()
    }
    private func changeBtnText() {
        if self.showBtn.currentTitle == "Show" {
            self.changeSecureStatus(toSecure: false)
            self.showBtn.setTitle("Hide", for: UIControlState.normal)
        } else {
            self.changeSecureStatus(toSecure: true)
            self.showBtn.setTitle("Show", for: UIControlState.normal)
        }
    }
    private func changeSecureStatus(toSecure isSecure: Bool) {
        self.textInput.isSecureTextEntry = isSecure
    }
}

extension PasswordCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textInput.resignFirstResponder()
        return false
    }
}
