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
                            TextConstants.contactUsSubject5,
                            TextConstants.contactUsSubject6,
                            TextConstants.contactUsSubject7,
                            TextConstants.contactUsSubject8]
    
    private lazy var subjectView: TextFieldWithPickerView = {
        let view = TextFieldWithPickerView()
        view.responderOnNext = textView
        view.models = subjects
        view.textField.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - @IBOutlets
    
    @IBOutlet weak private var descriptionLabel: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 14)
            newValue.textColor = ColorConstants.Text.textFieldText.color
            newValue.text = TextConstants.contactUsPageDescription
        }
    }
    
    @IBOutlet weak private var subjectContainerView: UIView! {
        willSet {
            setBorder(for: newValue)
        }
    }
    
    @IBOutlet weak private var textViewContainerView: UIView! {
        willSet {
            setBorder(for: newValue)
        }
    }
    
    @IBOutlet weak private var textView: UITextView! {
        willSet {
            newValue.delegate = self
            newValue.text = textViewPlaceholder
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 12)
            newValue.textColor = ColorConstants.Text.textFieldPlaceholder.color
        }
    }
    
    @IBOutlet weak private var textViewCounterLabel: UILabel! {
        willSet {
            newValue.text = "\(maxCharactersCount)"
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 12)
            newValue.textColor = ColorConstants.Text.textFieldPlaceholder.color
        }
    }
    
    @IBOutlet weak private var sendButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.contactUsSendButton, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 14)
            newValue.backgroundColor = ColorConstants.confirmationPopupButton.color
            newValue.layer.cornerRadius = 5
            newValue.isEnabled = false
            newValue.alpha = 0.4
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeLargeTitle(prefersLargeTitles: false, barStyle: .white)
        setView()
        addSubjectView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle(title: TextConstants.contactUsPageTitle, style: .white)
        setNavigationBarStyle(.white)
        
        if !Device.isIpad {
            setNavigationBarStyle(.byDefault)
        }
    }
    
    //MARK: - Setup
    
    private func setView() {
        view.backgroundColor = ColorConstants.tableBackground.color
    }
    
    private func setBorder(for view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = ColorConstants.a2FABorder.color.cgColor
    }
    
    private func addSubjectView() {
        subjectContainerView.addSubview(subjectView)
        subjectView.topAnchor.constraint(equalTo: subjectContainerView.topAnchor).activate()
        subjectView.bottomAnchor.constraint(equalTo: subjectContainerView.bottomAnchor).activate()
        subjectView.leftAnchor.constraint(equalTo: subjectContainerView.leftAnchor, constant: 20).activate()
        subjectView.rightAnchor.constraint(equalTo: subjectContainerView.rightAnchor, constant: -20).activate()
    }
    
    //MARK: - Private funcs
    
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
                    (response.storageInBytes?.convertBytesToFormattedString ?? ""),
                    response.usageInBytes.convertBytesToFormattedString)
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
        
        getUserInfo { userEmail, unlimitedStorage, storageQuota, storageUsage in
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
                       storageQuota,
                       storageUsage,
                       subject)
            
            let emailSubject = userEmail + " - " + TextConstants.NotLocalized.appNameMailSubject + subject
            
            Mail.shared().sendEmail(emailBody: emailBody,
                                    subject: emailSubject,
                                    emails: [TextConstants.NotLocalized.contactUsEmail],
                                    presentCompletion: nil, success: {
                                        self.navigationController?.popViewController(animated: true)
                                    }, fail: { error in
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
            textView.textColor = ColorConstants.Text.textFieldText.color
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textViewCounterLabel.text = "\(maxCharactersCount - textView.text.count)"
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textViewPlaceholder
            textView.textColor = ColorConstants.Text.textFieldPlaceholder.color
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
