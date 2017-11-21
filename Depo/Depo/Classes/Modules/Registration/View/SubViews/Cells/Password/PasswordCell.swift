//
//  PasswordCell.swift
//  Depo
//
//  Created by Aleksandr on 6/14/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class PasswordCell: ProtoInputTextCell {
    
    enum PasswordCellType {
        case regular
        case reEnter
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textInput: UITextField! {
        didSet {
            inputTextField = textInput
        }
    }
    @IBOutlet weak var showBtn: UIButton!
    @IBOutlet weak var infoImage: UIImageView!
    
    @IBOutlet weak var infoButton: UIButton!
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
    
    var type: PasswordCellType = .regular
    
    weak var infoButtonDelegate: InfoButtonCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textInput.delegate = self
//        textInput.font = UIFont.TurkcellSaturaBolFont(size: 21)
        titleLabel.textColor = ColorConstants.whiteColor
        backgroundColor = UIColor.clear
        changeInfoButtonTo(hidden: true)
    }
    
    func setupInitialState(withLabelTitle title: String, placeHolderText placeholder: String) {
        
        titleLabel.text = title
        placeholderText = placeholder
        changeTitleHeighlight(heighlight: true)
        
    }
    
    override func changeReturnKey(to key: UIReturnKeyType) {
        textInput.returnKeyType = key
    }
    
    func changeTitleHeighlight(heighlight: Bool) {
        var placeholder = ""
        if heighlight {
            textInput.font = UIFont.TurkcellSaturaBolFont(size: 21)
            titleLabel.textColor = ColorConstants.whiteColor
         
            
        } else {
            titleLabel.textColor = ColorConstants.yellowColor
            if let savedPlaceholder = placeholderText {
                if textInput.text?.count == 0 {
                    textInput.font = UIFont.TurkcellSaturaBolFont(size: 16)
                }
                placeholder = savedPlaceholder
            }
        }
        
        
        textInput.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                             attributes: [NSAttributedStringKey.foregroundColor: ColorConstants.yellowColor])
    }

    override func changeInfoButtonTo(hidden: Bool) {
//        infoButton.isEnabled = false//!hidden
//        infoButton.isHidden = hidden
        infoImage.isHidden = hidden
        changeTitleHeighlight(heighlight: hidden)
    }
    
    @IBAction func showButtonPressed(_ sender: Any) {
        sequreTexieldAndMessage = !sequreTexieldAndMessage
    }
    
    @IBAction func InfoButtonAction(_ sender: Any) {
//        infoButtonDelegate?.infoButtonGotPressed(with: self, andType: .passwordNotValid)
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        changeInfoButtonTo(hidden: true)
    }
}
