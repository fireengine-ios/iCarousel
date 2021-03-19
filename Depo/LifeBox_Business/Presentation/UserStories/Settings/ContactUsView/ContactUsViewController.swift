//
//  ContactUsViewController.swift
//  Depo
//
//  Created by Vyacheslav Bakinskiy on 18.03.21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class ContactUsViewController: BaseViewController, NibInit {
    
    //MARK: - Private properties
    
    private let textViewPlaceholder = TextConstants.contactUsMessageBoxName
    private let maxCharactersCount = 500
    
    //MARK: - @IBOutlets
    
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var subjectContainerView: UIView!
    @IBOutlet weak private var subjectLabel: UILabel!
    @IBOutlet weak private var subjectButton: UIButton!
    @IBOutlet weak private var textViewContainerView: UIView!
    @IBOutlet weak private var textView: UITextView!
    @IBOutlet weak private var textViewCounterLabel: UILabel!
    @IBOutlet weak private var sendButton: UIButton!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setSubjectButton()
        setTextView()
        setSendButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TODO: uncomment after merge with bar branch
//        setNavigationBarStyle(.white)
        
//        if !Device.isIpad {
//            defaultNavBarStyle()
//        }
    }
    
    //MARK: - Setup
    
    private func setView() {
        setTitle(withString: TextConstants.contactUsPageTitle)
        //TODO: replace setTitle to it after merge with bar branch
//        setNavigationTitle(title: TextConstants.contactUsPageTitle, isLargeTitle: false)
        
        descriptionLabel.font = UIFont.GTAmericaStandardRegularFont(size: 14)
        descriptionLabel.textColor = ColorConstants.Text.textFieldText
    }
    
    private func setSubjectButton() {
        subjectContainerView.layer.cornerRadius = 5
        subjectContainerView.layer.borderWidth = 1
        subjectContainerView.layer.borderColor = ColorConstants.a2FABorder.cgColor
        
        subjectLabel.text = TextConstants.contactUsSubjectBoxName
        subjectLabel.font = UIFont.GTAmericaStandardRegularFont(size: 12)
        subjectLabel.textColor = ColorConstants.Text.textFieldPlaceholder
    }
    
    private func setTextView() {
        textViewContainerView.layer.cornerRadius = 5
        textViewContainerView.layer.borderWidth = 1
        textViewContainerView.layer.borderColor = ColorConstants.a2FABorder.cgColor
        
        textView.delegate = self
        
        textView.text = textViewPlaceholder
        textView.font = UIFont.GTAmericaStandardRegularFont(size: 12)
        textView.textColor = ColorConstants.Text.textFieldPlaceholder
        
        textViewCounterLabel.text = "\(maxCharactersCount)"
        textViewCounterLabel.font = UIFont.GTAmericaStandardRegularFont(size: 12)
        textViewCounterLabel.textColor = ColorConstants.Text.textFieldPlaceholder
    }
    
    private func setSendButton() {
        disableSendButton()
        
        sendButton.setTitleColor(UIColor.white, for: .normal)
        sendButton.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 14)
        
        sendButton.backgroundColor = ColorConstants.confirmationPopupButton
        sendButton.layer.cornerRadius = 5
    }
    
    //MARK: - Private funcs
    
    private func disableSendButton() {
        sendButton.isEnabled = false
        sendButton.alpha = 0.4
    }
    
    private func enableSendButton() {
        sendButton.isEnabled = true
        sendButton.alpha = 1
    }
    
    //MARK: - @IBActions
    
    @IBAction func subjectButonPressed(_ sender: Any) {
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
    }
}

//MARK: - UITextViewDelegate

extension ContactUsViewController: UITextViewDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textViewDidBeginEditing (_ textView: UITextView) {
        if textView.text == textViewPlaceholder {
            textView.text = ""
            textView.textColor = ColorConstants.Text.textFieldText
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textViewCounterLabel.text = "\(maxCharactersCount - textView.text.count)"
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textViewPlaceholder
            textView.textColor = ColorConstants.Text.textFieldPlaceholder
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count +  (text.count - range.length) <= maxCharactersCount
    }
}
