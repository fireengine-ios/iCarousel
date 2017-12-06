//
//  MailVereficationViewController.swift
//  Depo_LifeTech
//
//  Created by Aleksandr on 11/30/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol MailVerificationViewControllerDelegate: class {
    func mailVerified()
    func mailVerificationFailed()
}

class MailVerificationViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var refuseButton: UIButton!
    
    weak var actionDelegate: MailVerificationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
        titleLabel.textColor = UIColor.lrTealish
        titleLabel.text = TextConstants.registrationCellPlaceholderEmail
        
        sendButton.setTitle(TextConstants.registrationNextButtonText, for: .normal)
        sendButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 32)
        sendButton.setTitleColor(UIColor.lrTealish, for: .normal)

        
        refuseButton.setTitle(TextConstants.updaitMailMaybeLater, for: .normal)
        refuseButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
        refuseButton.setTitleColor(UIColor.darkGray, for: .normal)
    }
    
    
    @IBAction func sendAction(_ sender: Any) {
        verifyMail()
    }
    @IBAction func refuseAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func verifyMail() {
        guard let email = inputTextField.text, email.count > 0 else {
            CustomPopUp.sharedInstance.showCustomInfoAlert(withTitle: TextConstants.errorAlert, withText: TextConstants.registrationCellPlaceholderEmail, okButtonText: TextConstants.ok)
            return
        }
        showSpiner()

        let authService = AuthenticationService()
        authService.updateEmail(emailUpdateParameters: EmailUpdate(mail: email),
                                sucess: { [weak self] response in
                                    DispatchQueue.main.async {
                                        self?.actionDelegate?.mailVerified()
                                    }
                                    self?.hideSpiner()
                                    self?.dismiss(animated: true, completion: nil)
            },
                                fail: { [weak self] error in
                                    DispatchQueue.main.async {
                                        self?.actionDelegate?.mailVerificationFailed()
                                        self?.hideSpiner()
                                        CustomPopUp.sharedInstance.showCustomInfoAlert(withTitle: TextConstants.errorAlert, withText: TextConstants.notCorrectEmail, okButtonText: TextConstants.ok)
                                    }
        })
    }
    
}
