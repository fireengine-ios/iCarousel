//
//  TermsCheckboxTextView.swift
//  Depo
//
//  Created by Aleksandr on 7/16/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol TermsCheckboxTextViewDelegate: class {
    func checkBoxPressed(isSelected: Bool, sender: TermsCheckboxTextView)
    func tappedOnURL(url: URL) -> Bool
}

final class TermsCheckboxTextView: UIView, NibInit {
    
    weak var delegate: TermsCheckboxTextViewDelegate?
    
    @IBOutlet private weak var checkbox: UIButton!
    
    @IBOutlet private weak var titleView: UITextView! {
        willSet {
            newValue.linkTextAttributes = [
                NSAttributedStringKey.foregroundColor.rawValue: UIColor.lrTealishTwo,
                NSAttributedStringKey.underlineColor.rawValue: UIColor.lrTealishTwo,
                NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue
            ]
            
            newValue.isEditable = false
            
            /// to remove insets
            /// https://stackoverflow.com/a/42333832/5893286
            newValue.textContainer.lineFragmentPadding = 0
            newValue.textContainerInset = .zero
        }
    }
    
    @IBOutlet private weak var descriptionView: UITextView! {
        willSet {
            newValue.linkTextAttributes = [
                NSAttributedStringKey.foregroundColor.rawValue: UIColor.lrTealishTwo,
                NSAttributedStringKey.underlineColor.rawValue: UIColor.lrTealishTwo,
                NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue
            ]
            newValue.isEditable = false
            
            /// to remove insets
            /// https://stackoverflow.com/a/42333832/5893286
            newValue.textContainer.lineFragmentPadding = 0
            newValue.textContainerInset = .zero
        }
    }
    
    override func awakeFromNib() {
        setupDefaultTitleView()
        setupDefaultTextView()
    }
    
    private func setupDefaultTitleView() {
        setupDefaultTextViewState(textView: titleView)
    }
    
    private func setupDefaultTextView() {
        setupDefaultTextViewState(textView: descriptionView)
    }
    
    private func setupDefaultTextViewState(textView: UITextView) {
        textView.text = ""
        textView.delegate = self
    }
    
    func setup(title: String?, text: String?, delegate: TermsCheckboxTextViewDelegate) {
        self.delegate = delegate
        if let title = title {
            titleView.text = title
        }
        if let text = text {
            descriptionView.text = text
        }
    }
  
    func setup(atributedTitleText: NSMutableAttributedString?, atributedText: NSMutableAttributedString?, delegate: TermsCheckboxTextViewDelegate) {
        self.delegate = delegate
        if let atributedTitleText = atributedTitleText {
            titleView.attributedText = atributedTitleText
        }
        if let atributedText = atributedText {
            descriptionView.attributedText = atributedText
        }
    }
    
    @IBAction private func checkBoxAction(_ button: UIButton) {
        button.isSelected = !button.isSelected
        delegate?.checkBoxPressed(isSelected: button.isSelected, sender: self)
    }
    
}

extension TermsCheckboxTextView: UITextViewDelegate {
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return delegate?.tappedOnURL(url: URL) ?? true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return delegate?.tappedOnURL(url: URL) ?? true//UIApplication.shared.openURL(URL)
    }
    
}
