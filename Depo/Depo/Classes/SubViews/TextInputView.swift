//
//  TextInputView.swift
//  Depo
//
//  Created by Oleg on 09.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class TextInputView: UIView, UITextFieldDelegate {
    
    enum TextInputViewType: Int {
        case Text = 0
        case Password = 1
    }
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var textField:UITextField!
    
    
    class func viewFromNib () -> TextInputView {
        let nibName = String(describing: self)
        let nibs = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        guard let view = nibs?[0] else {
            return TextInputView()
        }
        let textInputView = view as! TextInputView
        return textInputView
    }
    
    
// MARK: Configuratin
    
    func configurateViewWithType(viewType:TextInputViewType){ 
        self.titleLabel.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 10)
        self.textField.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 14)
        
        switch viewType {
        case TextInputViewType.Text:
            
            break
        case TextInputViewType.Password:
            
            break
        }
    }
    
    func updateTitleText(titleText:String){
        self.titleLabel.text = titleText
    }
    
    
// MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
}
