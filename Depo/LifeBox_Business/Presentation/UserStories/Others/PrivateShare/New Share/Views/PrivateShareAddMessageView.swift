//
//  PrivateShareAddMessageView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PrivateShareAddMessageView: UIView, NibInit {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.PrivateShare.add_message
            newValue.font = .GTAmericaStandardMediumFont(size: 14)
            newValue.textColor = ColorConstants.Text.labelTitle.color
        }
    }
    
    @IBOutlet private weak var textView: PlaceholderTextView! {
        willSet {
            newValue.placeholderColor = ColorConstants.Text.textFieldPlaceholder.color
            newValue.textColor = ColorConstants.Text.textFieldText.color
            newValue.font = .GTAmericaStandardRegularFont(size: 12)
            newValue.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 40)
            
            newValue.text = ""
            newValue.placeholder = TextConstants.PrivateShare.add_message_inside
            
            newValue.isScrollEnabled = false
            newValue.inputAccessoryView = toolbar
            
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = ColorConstants.separator.color.cgColor
            newValue.layer.cornerRadius = 5
            newValue.clipsToBounds = true
            
            newValue.delegate = self
        }
    }
    
    @IBOutlet private weak var counterLabel: UILabel! {
        willSet {
            newValue.text = "\(messageLengthLimit)"
            newValue.textColor = ColorConstants.Text.textFieldPlaceholder.color
            newValue.font = .GTAmericaStandardRegularFont(size: 12)
        }
    }
    
    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.isOpaque = true
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        
        toolbar.frame = CGRect(origin: .zero, size: CGSize(width: bounds.width, height: 50))
        toolbar.sizeToFit()
        
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                   target: nil,
                                   action: nil)
        
        let done = UIBarButtonItem(barButtonSystemItem: .done,
                                   target: self,
                                   action: #selector(hideKeyboard))
        done.tintColor = ColorConstants.Text.labelTitle.color
        
        toolbar.setItems([flex, done], animated: false)
        return toolbar
    }()
    
    private let messageLengthLimit = 500
    
    var message: String {
        textView.text
    }
    
    @objc private func hideKeyboard() {
        textView.resignFirstResponder()
    }
    
    private func updateCounter(count: Int) {
        guard messageLengthLimit >= count else {
            counterLabel.text = "0"
            assertionFailure()
            return
        }
        counterLabel.text = "\(messageLengthLimit - count)"
    }
}

extension PrivateShareAddMessageView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let stringRange = Range(range, in: textView.text) else {
            return false
        }
        
        let changedText = textView.text.replacingCharacters(in: stringRange, with: text)
        return changedText.count <= messageLengthLimit
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateCounter(count: textView.text.count)
    }
}
