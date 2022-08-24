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
            newValue.text = TextConstants.privateShareStartPageAddMessageTitle
            newValue.font = UIFont.appFont(.medium, size: 14)
            newValue.textColor = AppColor.filesLabel.color
        }
    }
    
    @IBOutlet private weak var textView: PlaceholderTextView! {
        willSet {
            newValue.text = ""
            newValue.placeholder = TextConstants.privateShareStartPageMessagePlaceholder
            newValue.font = UIFont.appFont(.regular, size: 14)
            newValue.contentInset = .zero
            newValue.isScrollEnabled = false
            newValue.inputAccessoryView = toolbar
            newValue.delegate = self
        }
    }
    
    @IBOutlet private weak var counterLabel: UILabel! {
        willSet {
            newValue.text = "0/\(messageLengthLimit)"
            newValue.textColor = AppColor.filesLabel.color
            newValue.font = .TurkcellSaturaDemFont(size: 16)
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
        done.tintColor = UIColor.lrTealish
        
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
        counterLabel.text = "\(count)/\(messageLengthLimit)"
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
