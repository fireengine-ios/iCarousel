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
        changeLargeTitle(prefersLargeTitles: false)
        setView()
        setTextView()
        setSendButton()
        setSubjectView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle(title: TextConstants.contactUsPageTitle)
        setNavigationBarStyle(.white)
        
        if !Device.isIpad {
            setNavigationBarStyle(.byDefault)
        }
    }
    
    //MARK: - Setup
    
    private func setView() {
        view.backgroundColor = ColorConstants.tableBackground
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
    
    private func getUserInfo(_ handler: @escaping ( _ userEmail: String, _ unlimitedStorage: Bool, _ storageInBytes: String, _ usageInBytes: String) -> Void) {
        let organizationUUID = SingletonStorage.shared.accountInfo?.parentAccountInfo.uuid ?? ""
        let userAccountUuid = SingletonStorage.shared.accountInfo?.uuid ?? ""
        
        SingletonStorage.shared.getStorageUsageInfo(projectId: organizationUUID, userAccountId: userAccountUuid) { response in
            handler(response.email ?? "No user email",
                    response.unlimitedStorage ?? false,
                    (response.storageInBytes?.convertBytesToGb ?? ""),
                    response.usageInBytes.convertBytesToGb)
        } fail: { error in
            assertionFailure(error.localizedDescription)
        }
    }
    
    private func openEmail() {
        guard Mail.canSendEmail() else {
            UIApplication.showErrorAlert(message: TextConstants.feedbackEmailError)
            return
        }
        
        let subject = subjectView.textField.text ?? ""
        let usersDescription = textView.text ?? ""
        
        getUserInfo { userEmail, unlimitedStorage, storageUsage, storageQuota in
            let versionString = SettingsBundleHelper.appVersion()
            let storageQuota = unlimitedStorage ? TextConstants.contactUsMailBodyUnlimitedStorage : storageQuota
            
            let emailBody = usersDescription + "\n" +
                String(format: TextConstants.contactUsMailTextFormat,
                       userEmail,
                       versionString,
                       UIDevice.current.modelName,
                       UIDevice.current.systemVersion,
                       Device.locale,
                       ReachabilityService.shared.isReachableViaWiFi ? "WIFI" : "WWAN",
                       storageUsage,
                       storageQuota,
                       subject)
            
            let emailSubject = userEmail + " - " + TextConstants.NotLocalized.appNameMailSubject + subject
            
            print(emailSubject)
            print("")
            print(emailBody)
            
            Mail.shared().sendEmail(emailBody: emailBody,
                                    subject: emailSubject,
                                    emails: ["lifeboxipadpro@gmail.com"],
                                    presentCompletion: {
                                        RouterVC().popViewController()
                                    }, success: nil, fail: { error in
                                        UIApplication.showErrorAlert(message: error?.description ?? TextConstants.feedbackEmailError)
                                    })
        }
    }
    
    //MARK: - @IBActions
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        openEmail()
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
        return textView.text.count + (text.count - range.length) <= maxCharactersCount
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
