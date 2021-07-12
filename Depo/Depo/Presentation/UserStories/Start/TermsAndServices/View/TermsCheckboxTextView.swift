//
//  TermsCheckboxTextView.swift
//  Depo
//
//  Created by Aleksandr on 7/16/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol TermsCheckboxTextViewDelegate: AnyObject {
    func checkBoxPressed(isSelected: Bool, sender: TermsCheckboxTextView)
}

final class TermsCheckboxTextView: UIView, NibInit {
    
    weak var delegate: TermsCheckboxTextViewDelegate?

    var isChecked: Bool {
        get { checkbox.isSelected }
        set {
            checkbox.isSelected = newValue
            updateAccessibilityInfo()
        }
    }
    
    @IBOutlet private weak var checkbox: UIButton!
    
    @IBOutlet weak var titleView: UITextView! {
        willSet {
            newValue.linkTextAttributes = [
                .foregroundColor: UIColor.lrTealishTwo,
                .underlineColor: UIColor.lrTealishTwo,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            
            newValue.isEditable = false
            
            /// to remove insets
            /// https://stackoverflow.com/a/42333832/5893286
            newValue.textContainer.lineFragmentPadding = 0
            newValue.textContainerInset = .zero
            
            setupDefaultTextViewState(textView: newValue)
        }
    }
    
    @IBOutlet private weak var descriptionView: UITextView! {
        willSet {
            newValue.linkTextAttributes = [
                .foregroundColor: UIColor.lrTealishTwo,
                .underlineColor: UIColor.lrTealishTwo,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            newValue.isEditable = false
            
            /// to remove insets
            /// https://stackoverflow.com/a/42333832/5893286
            newValue.textContainer.lineFragmentPadding = 0
            newValue.textContainerInset = .zero
            
            setupDefaultTextViewState(textView: newValue)
        }
    }

    private func setupDefaultTextViewState(textView: UITextView) {
        textView.text = ""
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isAccessibilityElement = true
    }
    
    func setup(title: String?, text: String?, delegate: TermsCheckboxTextViewDelegate) {
        self.delegate = delegate
        if let title = title {
            titleView.text = title
        }
        if let text = text {
            descriptionView.text = text
        }
        updateAccessibilityInfo()
    }
  
    func setup(atributedTitleText: NSMutableAttributedString?, atributedText: NSMutableAttributedString?, delegate: TermsCheckboxTextViewDelegate, textViewDelegate: UITextViewDelegate) {
        self.delegate = delegate
        descriptionView.delegate = textViewDelegate
        if let atributedTitleText = atributedTitleText {
            titleView.attributedText = atributedTitleText
        }
        if let atributedText = atributedText {
            descriptionView.attributedText = atributedText
        }
        updateAccessibilityInfo()
    }
    
    @IBAction private func checkBoxAction(_ button: UIButton) {
        button.isSelected = !button.isSelected
        updateAccessibilityInfo()
        delegate?.checkBoxPressed(isSelected: button.isSelected, sender: self)
    }

    override func accessibilityActivate() -> Bool {
        checkBoxAction(checkbox)
        return true
    }

    private func updateAccessibilityInfo() {
        let title = titleView.text ?? titleView.attributedText?.string ?? ""
        accessibilityLabel = title
        accessibilityTraits = isChecked ? [.selected, .button] : .button
    }
}

