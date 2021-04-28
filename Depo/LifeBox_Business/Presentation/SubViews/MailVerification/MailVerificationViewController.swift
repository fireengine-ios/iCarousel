//
//  MailVerificationViewController.swift
//  Depo_LifeTech
//
//  Created by Aleksandr on 11/30/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol MailVerificationViewControllerDelegate: class {
    func mailVerified(mail: String)
    func mailVerificationFailed()
}

class MailVerificationViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var refuseButton: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var alertLikeView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var actionDelegate: MailVerificationViewControllerDelegate?
    
    let authService = AuthenticationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        UIBlurEffect()
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 20)
        titleLabel.textColor = ColorConstants.darkBlueColor
        titleLabel.text = TextConstants.registrationCellPlaceholderEmail
        
        inputTextField.font = UIFont.TurkcellSaturaRegFont(size: 20)
        
        sendButton.setTitle(TextConstants.save, for: .normal)
        sendButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
        sendButton.setTitleColor(ColorConstants.blueColor, for: .normal)

        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        alertLikeView.layer.cornerRadius = 5
        alertLikeView.layer.masksToBounds = true
    }
    
    @objc func handleTap() {
        inputTextField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputTextField.becomeFirstResponder()
    }
    
    @IBAction func sendAction(_ sender: Any) {
        verifyMail()
    }
    @IBAction func refuseAction(_ sender: Any) {
        closeAnimation()
    }
    
    private func closeAnimation(completion: VoidHandler? = nil) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
            self.contentView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }) { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    private func verifyMail() {
        guard let email = inputTextField.text, email.count > 0 else {
            UIApplication.showErrorAlert(message: TextConstants.registrationCellPlaceholderEmail)
            return
        }
       
        guard Validator.isValid(email: email) else {
            UIApplication.showErrorAlert(message: TextConstants.notCorrectEmail)
            return
        }
        
        showSpinner()
        authService.updateEmail(emailUpdateParameters: EmailUpdate(mail: email),
            sucess: { [weak self] response in
                DispatchQueue.main.async {
                    self?.actionDelegate?.mailVerified(mail: email)
                    self?.hideSpinner()
                    self?.dismiss(animated: true, completion: nil)
                }
            }, fail: { [weak self] error in
                DispatchQueue.main.async {
                    self?.actionDelegate?.mailVerificationFailed()
                    self?.hideSpinner()
                    UIApplication.showErrorAlert(message: error.description)
                }
        })
    }
    
    override func showKeyBoard(notification: NSNotification) {
        super.showKeyBoard(notification: notification)
        let y = alertLikeView.frame.size.height + getMainYForView(view: alertLikeView)
        if (view.frame.size.height - y) < keyboardHeight {
            let dy = keyboardHeight - (view.frame.size.height - y)
            scrollView.contentInset = UIEdgeInsetsMake(0, 0, dy + 10, 0)

            //let yText = storyNameTextField.frame.size.height + getMainYForView(view: storyNameTextField)
            let dyText = keyboardHeight - (view.frame.size.height - y) + 10
            if (dyText > 0) {
                let point = CGPoint(x: 0, y: dyText)
                scrollView.setContentOffset(point, animated: true)
            }
        }
    }
    
    override func hideKeyboard() {
        super.hideKeyboard()
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}
