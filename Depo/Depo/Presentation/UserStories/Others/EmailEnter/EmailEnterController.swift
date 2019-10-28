import UIKit

final class EmailEnterController: ViewController, NibInit, ErrorPresenter {
    
    var successHandler: VoidHandler?
    var isNeedToDismissController = true
    
    @IBOutlet private var designer: EmailEnterDesigner!
    
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var continueButton: RoundedInsetsButton!
    
    @IBOutlet private weak var emailView: ProfileTextEnterView! {
        willSet {
            newValue.textField.delegate = self
            
            newValue.textField.autocorrectionType = .no
            newValue.textField.autocapitalizationType = .none
            
            newValue.textField.addTarget(self, action: #selector(emailDidChange), for: .editingChanged)
        }
    }
    
    private lazy var authService = AuthenticationService()
    
    private var email: String {
        return emailView.textField.text ?? ""
    }
    
    private var isEmailValid: Bool {
        return !email.isEmpty && Validator.isValid(email: email)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = TextConstants.missingInformation
        
        emailView.becomeFirstResponder()
        
        updateButtonState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
    }
    
    @IBAction func onContinueButton(_ sender: UIButton) {
        updateEmail()
    }
    
    @objc private func emailDidChange() {
        updateButtonState()
    }
    
    private func updateButtonState() {
        continueButton.isEnabled = isEmailValid
    }
    
    private func updateEmail() {
        assert(isEmailValid)
        showSpinner()
        
        authService.updateEmail(emailUpdateParameters: EmailUpdate(mail: email),
                                sucess: { [weak self] response in
                                    
                                    /// email updating without "SingletonStorage.shared.getAccountInfoForUser(forceReload: true"
                                    SingletonStorage.shared.accountInfo?.email = self?.email
                                    
                                    DispatchQueue.main.async {
                                        self?.hideSpinner()
                                        self?.showEmailConfirmation()
                                    }
            }, fail: { [weak self] error in
                DispatchQueue.main.async {
                    self?.showErrorAlert(message: error.description)
                    self?.hideSpinner()
                }
        })
    }
    
    private func showEmailConfirmation() {
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
    
    private func closeAnimated() {
        view.endEditing(true)
        
        if isNeedToDismissController {
            dismiss(animated: true, completion: self.successHandler)
        } else {
            self.successHandler?()
        }
        
    }
}

extension EmailEnterController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isEmailValid {
            updateEmail()
        }
        return false
    }
}
