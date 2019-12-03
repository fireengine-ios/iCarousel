//
//  ProfileDetailController.swift
//  Depo
//
//  Created by Bondar Yaroslav on 11/28/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class ProfileDetailController: ViewController, KeyboardHandler {
    
    @IBOutlet private weak var scrollView: UIScrollView! {
        willSet {
            newValue.delaysContentTouches = false
        }
    }
    
    @IBOutlet private weak var stackView: UIStackView! {
        willSet {
            newValue.spacing = 24
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fill
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            
            let fullnameStackView = UIStackView(arrangedSubviews: [nameView, surnameView])
            fullnameStackView.spacing = 20
            fullnameStackView.axis = .horizontal
            fullnameStackView.alignment = .fill
            fullnameStackView.distribution = .fillEqually
            fullnameStackView.backgroundColor = .white
            fullnameStackView.isOpaque = true
            
            newValue.addArrangedSubview(fullnameStackView)
            newValue.addArrangedSubview(emailView)
            newValue.addArrangedSubview(phoneView)
            newValue.addArrangedSubview(birthdayDetailView)
            newValue.addArrangedSubview(addressView)
            newValue.addArrangedSubview(changePasswordButton)
            newValue.addArrangedSubview(changeSecurityQuestionButton)
        }
    }
    
    let nameView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = TextConstants.userProfileName
        newValue.subtitleLabel.text = TextConstants.pleaseEnterYourName
        newValue.textField.quickDismissPlaceholder = TextConstants.enterYourName
        newValue.textField.autocorrectionType = .no
        return newValue
    }()
    
    let surnameView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = TextConstants.userProfileSurname
        newValue.subtitleLabel.text = TextConstants.pleaseEnterYourSurname
        newValue.textField.quickDismissPlaceholder = TextConstants.enterYourSurname
        newValue.textField.autocorrectionType = .no
        return newValue
    }()
    
    let emailView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = TextConstants.userProfileEmailSubTitle
        /// not set bcz of showEmptyCredentialsPopup
        //newValue.subtitleLabel.text
        newValue.textField.quickDismissPlaceholder = TextConstants.enterYourEmailAddress
        newValue.textField.keyboardType = .emailAddress
        newValue.textField.autocorrectionType = .no
        newValue.textField.autocapitalizationType = .none
        return newValue
    }()
    
    let phoneView = ProfilePhoneEnterView()
    
    private let birthdayDetailView: ProfileBirthdayFieldView = {
        let newValue = ProfileBirthdayFieldView()
        newValue.title = TextConstants.userProfileBirthday
        return newValue
    }()
    
    let addressView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = "Address"
        newValue.subtitleLabel.text = "This information will be used for campaigns"
        newValue.textField.quickDismissPlaceholder = "Please enter your address information"
        newValue.textField.autocorrectionType = .no
        return newValue
    }()
    
    let changePasswordButton: UIButton = {
        let newValue = UIButton(type: .custom)
        let attributedString = NSAttributedString(string: TextConstants.userProfileChangePassword,
                                                  attributes: [
                                                    .font: UIFont.TurkcellSaturaDemFont(size: 18),
                                                    .foregroundColor: UIColor.lrTealish,
                                                    .underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
        newValue.setAttributedTitle(attributedString, for: .normal)
        newValue.addTarget(self, action: #selector(onChangePassword), for: .touchUpInside)
        newValue.contentHorizontalAlignment = .left
        return newValue
    }()
    
    let changeSecurityQuestionButton: UIButton = {
        let newValue = UIButton(type: .custom)
        let attributedString = NSAttributedString(string: TextConstants.userProfileSecretQuestion,
                                                  attributes: [
                                                    .font: UIFont.TurkcellSaturaDemFont(size: 18),
                                                    .foregroundColor: UIColor.lrTealish,
                                                    .underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
        newValue.setAttributedTitle(attributedString, for: .normal)
        newValue.addTarget(self, action: #selector(onChangeSecurityQuestion), for: .touchUpInside)
        newValue.contentHorizontalAlignment = .left
        return newValue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTapGestureToHideKeyboard()
    }
    
    @objc private func onChangePassword() {
        let router = RouterVC()
        let controller = ChangePasswordController.initFromNib()
        router.pushViewController(viewController: controller)
    }
    
    @objc private func onChangeSecurityQuestion() {
        let router = RouterVC()
        let controller = SetSecurityQuestionViewController.initFromNib()
        
        // TODO: ???
        controller.configureWith(selectedQuestion: nil, delegate: nil)
        
        router.pushViewController(viewController: controller)
    }
    
}
