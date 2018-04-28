//
//  PasswordCell.swift
//  Depo
//
//  Created by Aleksandr on 6/14/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

final class PasswordCell: ProtoInputTextCell {
    
    enum PasswordCellType {
        case regular
        case reEnter
    }
    
    @IBOutlet private weak var infoImage: UIImageView!
    @IBOutlet private weak var infoButton: UIButton!
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = ColorConstants.whiteColor
        }
    }
    
    @IBOutlet private weak var showBtn: UIButton! {
        didSet {
            showBtn.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            showBtn.setTitle(TextConstants.showPassword, for: .normal)
        }
    }
    
    @IBOutlet weak var textInput: UITextField! {
        didSet {
            inputTextField = textInput
            textInput.delegate = self
            textInput.font = UIFont.TurkcellSaturaBolFont(size: 21)
        }
    }
    
    private var isSecureTextFieldAndMessage: Bool = true {
        willSet {
            let showBtnTitle = newValue ? TextConstants.showPassword : TextConstants.hidePassword
            showBtn.setTitle(showBtnTitle, for: .normal)
            
            /// https://stackoverflow.com/a/35295940/5893286
            textInput.isSecureTextEntry = newValue
            textInput.font = nil
            textInput.font = UIFont.TurkcellSaturaBolFont(size: 21)
        }
    }
    
    var type: PasswordCellType = .regular
    
    weak var infoButtonDelegate: InfoButtonCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
        
        textInput.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedStringKey.foregroundColor: ColorConstants.yellowColor])
    }
    
    override func changeInfoButtonTo(hidden: Bool) {
        infoImage.isHidden = hidden
        changeTitleHeighlight(heighlight: hidden)
    }
    
    @IBAction private func showButtonPressed(_ sender: Any) {
        isSecureTextFieldAndMessage = !isSecureTextFieldAndMessage
    }
    
    @IBAction private func InfoButtonAction(_ sender: Any) {
        //        infoButtonDelegate?.infoButtonGotPressed(with: self, andType: .passwordNotValid)
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        changeInfoButtonTo(hidden: true)
    }
}

