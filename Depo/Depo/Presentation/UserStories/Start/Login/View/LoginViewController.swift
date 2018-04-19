//
//  LoginLoginViewController.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
class LoginViewController: ViewController, LoginViewInput, LoginDataSourceActionsDelegate {
    
    var captchaViewController: CaptchaViewController!
    
    var output: LoginViewOutput!
    var dataSource: LoginDataSource = LoginDataSource()
    
    var tableDataMArray: Array<UITableViewCell> = Array()
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var loginButton: WhiteButtonWithRoundedCorner!
    @IBOutlet weak var cantLoginButton: ButtonWithCorner!
    @IBOutlet weak var rememberLoginLabel: UILabel!
    @IBOutlet weak var viewForCaptcha: UIView!
    @IBOutlet weak var captchaViewH: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var iPadLogoImage: UIImageView!
    
    private let capthcaVC = CaptchaViewController.initFromXib()    
    
    // MARK: Life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hidenNavigationBarStyle()
        
        backButtonForNavigationItem(title: TextConstants.backTitle)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showKeyBoard),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideKeyboard),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurateView()
        
        tableView.delegate = dataSource
        tableView.dataSource = dataSource
        dataSource.actionsDelegate = self
        dataSource.setupTableView(tableView: tableView)
        
        captchaViewH.constant = 0
        viewForCaptcha.addSubview(capthcaVC.view)
        capthcaVC.view.frame = viewForCaptcha.bounds
        viewForCaptcha.isHidden = true
        
        output.viewIsReady()
                
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        output.viewAppeared()
    }
    
    func configurateView() {
        tableView.backgroundColor = UIColor.clear
        
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 22)
        titleLabel.textColor = ColorConstants.whiteColor
        errorLabel.font = UIFont.TurkcellSaturaItaFont(size: 18)
//        errorLabel.minimumScaleFactor = 0.5
        errorLabel.textColor = ColorConstants.yellowColor
        errorLabel.text = TextConstants.loginScreenCredentialsError
        errorLabel.isHidden = true
        if (Device.isIpad) {
            titleLabel.text = TextConstants.loginTableTitle
        } else {
            setNavigationTitle(title: TextConstants.loginTitle)
            iPadLogoImage.isHidden = true
            titleLabel.text = ""
        }
        
        loginButton.setTitle(TextConstants.loginTitle, for: UIControlState.normal)
        cantLoginButton.setTitle(TextConstants.loginCantLoginButtonTitle, for: UIControlState.normal)
        
        rememberLoginLabel.text = TextConstants.loginRememberMyCredential
        rememberLoginLabel.textColor = ColorConstants.whiteColor
        rememberLoginLabel.font = UIFont.TurkcellSaturaBolFont(size: 15)
    }
    
    @objc func showKeyBoard(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        let yNextButton = getMainYForView(view: cantLoginButton) + cantLoginButton.frame.size.height
        if (view.frame.size.height - yNextButton < keyboardHeight) {
            
            scrollView.contentInset.bottom = keyboardHeight + 40
            
            let textField = searchActiveTextField(view: self.view)
            if (textField != nil) {
                var yOfTextField: CGFloat = 0
                if (textField?.tag == 33) {
                    yOfTextField = getMainYForView(view: loginButton) + loginButton.frame.size.height + 20
                } else {
                    yOfTextField = getMainYForView(view: textField!) + textField!.frame.size.height + 20
                }
                if (yOfTextField > view.frame.size.height - keyboardHeight) {
                    let dy = yOfTextField - (view.frame.size.height - keyboardHeight)
                    
                    let point = CGPoint(x: 0, y: dy + 10)
                    scrollView.setContentOffset(point, animated: true)
                }
            }
        }
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
        scrollView.contentInset = .zero
    }
    
    private func searchActiveTextField(view: UIView) -> UITextField? {
        
        if let textField = view as? UITextField {
            if textField.isFirstResponder {
                return textField
            }
        }
        for subView in view.subviews {
            let textField = searchActiveTextField(view: subView)
            if (textField != nil) {
                return textField
            }
        }
        return nil
    }
    
    private func getMainYForView(view: UIView) -> CGFloat {
        if (view.superview == self.view) {
            return view.frame.origin.y
        } else {
            if (view.superview != nil) {
                return view.frame.origin.y + getMainYForView(view: view.superview!)
            } else {
                return 0
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideKeyboard()
    }
    
    func showErrorMessage(with text: String) {
        errorLabel.text = text
        errorLabel.isHidden = false
    }
    
    func showInfoButton(in field: LoginViewInputField) {
        switch field {
        case .login:
            guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? BaseUserInputCellView else {
                return
            }
            cell.changeInfoButtonTo(hidden: false)
        case .password:
            guard let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? PasswordCell else {
                return
            }
            cell.changeInfoButtonTo(hidden: false)
        }
        
    }
    
    func showNeedSignUp(message: String) {
        let vc = PopUpController.with(title: TextConstants.errorAlert, message: message, image: .error, buttonTitle: TextConstants.ok) { [weak self] controller in
            controller.close { [weak self] in
                self?.output.onOpenSignUp()
            }
        }
        present(vc, animated: true, completion: nil)
    }
    
    func hideErrorMessage() {
        errorLabel.text = ""
        errorLabel.isHidden = true
    }
    
    func highlightLoginTitle() {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? BaseUserInputCellView else {
            return
        }
        cell.changeTitleHeighlight(heighlight: true)
    }
    
    func highlightPasswordTitle() {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? PasswordCell else {
            return
        }
        cell.changeTitleHeighlight(heighlight: true)
    }
    
    func dehighlightTitles() {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? BaseUserInputCellView else {
            return
        }
        cell.changeTitleHeighlight(heighlight: true)
        
        guard let cellPassword = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? PasswordCell else {
            return
        }
        cellPassword.changeTitleHeighlight(heighlight: true)
    }

    
    // MARK: - DATA SOURCE DELEGATES
    
    func textStrtedEditing() {
        self.hideErrorMessage()
    }

    func loginCellFistEnteringPhone() {
        output.startedEnteringPhoneNumber()
    }
    
    func loginCellFistEnteringPhonePlus() {
        output.startedEnteringPhoneNumberPlus()
    }
    
    func enterPhoneCountryCode(countryCode: String) {
        guard let loginCell = tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? LoginPhoneMailCell else {
            return
        }
        loginCell.enterPhoneCode(code: countryCode)
    }
    
    func incertPhoneCountryCode(countryCode: String) {
        guard let loginCell = tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? LoginPhoneMailCell else {
            return
        }
        loginCell.incertPhoneCode(code: countryCode)
    }
    
    
    // MARK: Buttons action
    
    @IBAction func onLoginButton() {        
        let password = dataSource.getPassword()
        let login = dataSource.getLogin()
        hideKeyboard()
        if !viewForCaptcha.isHidden {
            output.sendLoginAndPasswordWithCaptcha(login: login, password: password, captchaID: capthcaVC.currentCaptchaID, captchaAnswer: capthcaVC.inputTextField.text ?? "")
        } else {
            output.sendLoginAndPassword(login: login, password: password)
        }
        
    }
    
    @IBAction func onCantLoginButton() {
        output.onCantLoginButton()
    }
    
    @IBAction func rememberMe(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        button.isSelected = !button.isSelected

        output.rememberMe(remember: button.isSelected)
    }

    
    // MARK: LoginViewInput
    
    func setupInitialState(array: [BaseCellModel]) {
        dataSource.setupCellsWithModels(models: array)
    }
    
    func showCapcha() {
        captchaViewH.constant = 150
        viewForCaptcha.isHidden = false
    }
    
    func refreshCaptcha() {
        capthcaVC.refreshCapthcha()
        capthcaVC.inputTextField.text = ""
    }
    
    func blockUI() {
        loginButton.isEnabled = false
        cantLoginButton.isEnabled = false
    }
    
    func unblockUI() {
        loginButton.isEnabled = true
        cantLoginButton.isEnabled = true
    }
    
    func failedBlockError() {
        showErrorMessage(with: TextConstants.hourBlockLoginError)
    }
}
