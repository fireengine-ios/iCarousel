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
    private let subjects = [TextConstants.contactUsSubject1,
                            TextConstants.contactUsSubject2,
                            TextConstants.contactUsSubject3,
                            TextConstants.contactUsSubject4,
                            TextConstants.contactUsSubject5]
    
    private lazy var subjectView: TextFieldWithPickerView = {
        let view = TextFieldWithPickerView()
        view.responderOnNext = textView
        view.models = subjects
        view.textField.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - @IBOutlets
    
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var subjectContainerView: UIView!
    @IBOutlet weak private var textViewContainerView: UIView!
    @IBOutlet weak private var textView: UITextView!
    @IBOutlet weak private var textViewCounterLabel: UILabel!
    @IBOutlet weak private var sendButton: UIButton!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setTextView()
        setSendButton()
        setSubjectView()
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
        descriptionLabel.text = TextConstants.contactUsPageDescription
    }
    
    private func setBorder(for view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = ColorConstants.a2FABorder.cgColor
    }
    
    private func setSubjectView() {
        setBorder(for: subjectContainerView)
        
        subjectContainerView.addSubview(subjectView)
        subjectView.topAnchor.constraint(equalTo: subjectContainerView.topAnchor).activate()
        subjectView.bottomAnchor.constraint(equalTo: subjectContainerView.bottomAnchor).activate()
        subjectView.leftAnchor.constraint(equalTo: subjectContainerView.leftAnchor, constant: 20).activate()
        subjectView.rightAnchor.constraint(equalTo: subjectContainerView.rightAnchor, constant: -20).activate()
    }
    
    private func setTextView() {
        setBorder(for: textViewContainerView)
        
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

//MARK: - UITextFieldDelegate

extension ContactUsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let _ = textField.text {
            enableSendButton()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}
