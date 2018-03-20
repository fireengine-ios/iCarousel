//
//  EmailEnterController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class EmailEnterController: UIViewController, NibInit, ErrorPresenter {
    
    @IBOutlet private var customizator: EmailEnterCustomizator!
    @IBOutlet private weak var emailTextField: UnderlineTextField!
    
    private lazy var attemptsCounter = SavingAttemptsCounterByUnigueUserID(
        limit: NumericConstants.emptyEmailUserCloseLimit,
        userDefaultsKey: "EmailSavingAttemptsCounter")
    
    private lazy var authService = AuthenticationService()
    var approveCancelHandler: VoidHandler?
    
    @IBAction private func actionApproveButton(_ sender: UIButton) {
        verifyMail()
    }
    
    @objc private func actionCloseButton(_ sender: UIBarButtonItem) {
        let isUpped = attemptsCounter.up(limitHandler: { [weak self] in
            self?.attemptsCounter.reset()
            self?.view.endEditing(true)
            AppConfigurator.logout()
        })
        
        if isUpped {
            closeAnimated()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.becomeFirstResponder()
        title = TextConstants.emptyEmailTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.exitWhite, style: .plain, target: self, action: #selector(actionCloseButton))
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
        
        showSpiner()
        authService.updateEmail(emailUpdateParameters: EmailUpdate(mail: email),
            sucess: { [weak self] response in
                DispatchQueue.main.async {
                    self?.hideSpiner()
                    self?.closeAnimated()
                }
            }, fail: { [weak self] error in
                DispatchQueue.main.async {
                    self?.showErrorAlert(message: TextConstants.notCorrectEmail)
                    self?.hideSpiner()
                }
        })
    }
}
