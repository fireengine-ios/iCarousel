//
//  BaseUserInputCellView.swift
//  Depo
//
//  Created by Aleksandr on 6/9/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class BaseUserInputCellView: ProtoInputTextCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textInputField: UITextField! {
        didSet {
            inputTextField = textInputField
        }
    }
    @IBOutlet weak var infoImage: UIImageView!
    @IBOutlet weak var infoButton: UIButton!
    
    weak var infoButtonDelegate: InfoButtonCellProtocol?
    
    var defaultTitleHightlightColor = ColorConstants.whiteColor.color {
        didSet {
            changeTitleHeighlight(heighlight: isTitleTitleHightlight)
        }
    }
    var isTitleTitleHightlight = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textInputField.delegate = self
        titleLabel.textColor = ColorConstants.whiteColor.color
        changeInfoButtonTo(hidden: true)
    }
    
    func setupBaseCell(withTitle title: String, inputText text: String) {
        titleLabel.text = title
        placeholderText = text
//        if textInputField.attributedPlaceholder?.string != text {
//            textInputField.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: ColorConstants.yellowColor.color])
//        }
    }
    
    func changeTitleHeighlight(heighlight: Bool) {
        isTitleTitleHightlight = heighlight
        var placeholder = ""
        if heighlight {
            textInputField.font = UIFont.GTAmericaStandardBoldFont(size: 21)
            titleLabel.textColor = defaultTitleHightlightColor
        } else {
            titleLabel.textColor = ColorConstants.yellowColor.color
            if let savedPlaceholder = placeholderText {
                if textInputField.text?.count == 0 {
                    textInputField.font = UIFont.GTAmericaStandardBoldFont(size: 16)
                }
                
                placeholder = savedPlaceholder
            }
        }
        
        
        textInputField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                                  attributes: [NSAttributedStringKey.foregroundColor: ColorConstants.yellowColor.color])
    }
    
    override func changeInfoButtonTo(hidden: Bool) {
//        infoButton.isEnabled = false//!hidden
//        infoButton.isHidden = hidden
        infoImage.isHidden = hidden
        changeTitleHeighlight(heighlight: hidden)
    }
    
    @IBAction func infoButtonAction(_ sender: Any) {
//        infoButtonDelegate?.infoButtonGotPressed(with: self, andType: .mailNotValid)
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        
        changeInfoButtonTo(hidden: true)
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        super.textFieldDidEndEditing(textField)

        guard var text = textInputField.text else {
            return
        }
        
        text = text.removingWhiteSpaces()
        textInputField.text = text
    }

    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        
        return true
    }
}
