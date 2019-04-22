//
//  EmailEnterController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

/// doc https://wiki.life.com.by/display/LTFizy/Empty+e-mail+iOS
final class EmailEnterController: ViewController, NibInit, ErrorPresenter {
    
    @IBOutlet private var customizator: EmailEnterCustomizator!
    @IBOutlet private weak var emailTextField: UnderlineTextField!
    
    private lazy var attemptsCounter = SavingAttemptsCounterByUnigueUserID.emptyEmailCounter
    
    private lazy var authService = AuthenticationService()
    var approveCancelHandler: VoidHandler?
    
    @IBAction private func actionApproveButton(_ sender: UIButton) {
        verifyMail()
    }
    
    @objc private func actionCloseButton(_ sender: UIBarButtonItem) {
        let isUpped = attemptsCounter.up(limitHandler: { [weak self] in
            self?.view.endEditing(true)
            self?.dismiss(animated: true) { 
                AppConfigurator.logout()
            }
        })
        
        if isUpped {
            closeAnimated()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.becomeFirstResponder()
        title = TextConstants.emptyEmailTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.exitWhite,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(actionCloseButton))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
    }
    
    private func closeAnimated() {
        view.endEditing(true)
        dismiss(animated: true) {
            self.approveCancelHandler?()
        }
    }
    
    private func verifyMail() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showErrorAlert(message: TextConstants.registrationCellPlaceholderEmail)
            return
        }
        
        guard Validator.isValid(email: email) else {
            showErrorAlert(message: TextConstants.notCorrectEmail)
            return
        }
        
        showSpinner()
        
        /// to test popup sucess close without email update
        /// also comment "authService.updateEmail..."
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
//            self?.hideSpiner()
//            self?.showEmailConfirmation(for: email)
//        }
        
        authService.updateEmail(emailUpdateParameters: EmailUpdate(mail: email),
            sucess: { [weak self] response in
                DispatchQueue.main.async {
                    self?.hideSpinner()
                    self?.showEmailConfirmation(for: email)
                }
            }, fail: { [weak self] error in
                DispatchQueue.main.async {
                    self?.showErrorAlert(message: error.description)
                    self?.hideSpinner()
                }
        })
    }
    
    private func showEmailConfirmation(for email: String) {
        let message = String(format: TextConstants.registrationEmailPopupMessage, email)
        
        let controller = PopUpController.with(
            title: TextConstants.registrationEmailPopupTitle,
            message: message,
            image: .error,
            buttonTitle: TextConstants.ok,
            action: { [weak self] vc in
                vc.close { [weak self] in
                    self?.closeAnimated()
                }
        })
        present(controller, animated: true, completion: nil)
    }
}
