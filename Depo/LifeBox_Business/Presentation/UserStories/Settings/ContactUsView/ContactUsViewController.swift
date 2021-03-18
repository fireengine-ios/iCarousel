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
    
    private lazy var textViewCounterLabel: UILabel = {
        let label = UILabel()
        label.text = "500"
        label.font = UIFont.GTAmericaStandardRegularFont(size: 12)
        label.textColor = ColorConstants.Text.textFieldPlaceholder
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - @IBOutlets
    
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var subjectContainerView: UIView!
    @IBOutlet weak private var subjectLabel: UILabel!
    @IBOutlet weak private var subjectButton: UIButton!
    @IBOutlet weak private var textView: UITextView!
    @IBOutlet weak private var sendButton: UIButton!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setSubjectButton()
        setTextField()
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
        subjectLabel.textColor = ColorConstants.Text.textFieldText
    }
    
    private func setTextField() {
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = ColorConstants.a2FABorder.cgColor
        
        textView.addSubview(textViewCounterLabel)
        textViewCounterLabel.rightAnchor.constraint(equalTo: textView.rightAnchor, constant: -10).activate()
        textViewCounterLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 5).activate()
    }
    
    private func setSendButton() {
        disableSendButton()
        
        sendButton.setTitleColor(UIColor.white, for: .normal)
        sendButton.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 14)
        
        sendButton.backgroundColor = ColorConstants.confirmationPopupButton
        sendButton.layer.cornerRadius = 5
    }
    
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
