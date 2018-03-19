//
//  EmailEnterController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class EmailEnterController: UIViewController, NibInit {
    
    deinit {
        print("- deint EmailEnterController")
    }
    
    @IBOutlet private var customizator: EmailEnterCustomizator!
    @IBOutlet private weak var emailTextField: UnderlineTextField!
    
    private lazy var attemptsCounter = SavingAttemptsCounter(limit: NumericConstants.emptyEmailUserCloseLimit, userDefaultsKey: "EmailSavingAttemptsCounter", limitHandler: {
        self.attemptsCounter.reset()
        AppConfigurator.logout()
    })
    
    private lazy var authService = AuthenticationService()
    var approveCancelHandler: VoidHandler?
    
    @IBAction private func actionApproveButton(_ sender: UIButton) {
        verifyMail()
    }
    
    @IBAction private func actionCloseButton(_ sender: UIButton) {
        attemptsCounter.up()
        closeAnimated()
    }
    
    private func closeAnimated() {
        dismiss(animated: true) {
            self.approveCancelHandler?()
        }
    }
    
    private func verifyMail() {
        guard let email = emailTextField.text, email.isEmpty else {
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
    
    func showErrorAlert(message: String) {
        let vc = PopUpController.with(errorMessage: message)
        present(vc, animated: false, completion: nil)
    }
}
