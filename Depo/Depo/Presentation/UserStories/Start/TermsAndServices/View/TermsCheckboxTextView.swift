//
//  TermsCheckboxTextView.swift
//  Depo
//
//  Created by Aleksandr on 7/16/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class TermsCheckboxTextView: UIView {
    
    @IBOutlet private weak var checkbox: UIButton!
    
    @IBOutlet private weak var textView: UITextView! {
        willSet {
            textView.linkTextAttributes = [
                NSAttributedStringKey.foregroundColor.rawValue: UIColor.lrTealishTwo,
                NSAttributedStringKey.underlineColor.rawValue: UIColor.lrTealishTwo,
                NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue
            ]
        }
    }

    override func awakeFromNib() {
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.text = ""
        
    }
    
    func setup(text: String, delegate: UITextViewDelegate) {
        textView.delegate = delegate
        textView.text = text
        
    }
  
    
}
