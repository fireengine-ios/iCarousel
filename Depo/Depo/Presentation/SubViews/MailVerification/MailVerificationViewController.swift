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

class MailVerificationViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var refuseButton: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var alertLikeView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var actionDelegate: MailVerificationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        UIBlurEffect()
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
        titleLabel.textColor = UIColor.lrTealish
        titleLabel.text = TextConstants.registrationCellPlaceholderEmail
        
        sendButton.setTitle(TextConstants.registrationNextButtonText, for: .normal)
        sendButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 32)
        sendButton.setTitleColor(UIColor.lrTealish, for: .normal)

        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc func handleTap() {
        inputTextField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        animateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputTextField.becomeFirstResponder()
    }
    
    private func animateView() {
//        if isShown {
//            return
//        }
//        isShown = true
        alertLikeView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.contentView.transform = .identity
        }
    }
    
    @IBAction func sendAction(_ sender: Any) {
        verifyMail()
    }
    @IBAction func refuseAction(_ sender: Any) {
        closeAnimation()
    }
    
    private func closeAnimation(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
            self.contentView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }) { _ in
            self.dismiss(animated: false, completion: completion)
        }
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
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
}
