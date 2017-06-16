//
//  LoginLoginViewController.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
class LoginViewController: UIViewController, LoginViewInput {

    var output: LoginViewOutput!
    var dataSource: LoginDataSource = LoginDataSource()
    
    var tableDataMArray:Array<UITableViewCell> = Array()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cantLoginButton: ButtonWithCorner!
    @IBOutlet weak var rememberLoginLabel: UILabel!
    @IBOutlet weak var viewForCaptcha: UIView!
    @IBOutlet weak var captchaViewH: NSLayoutConstraint!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = TextConstants.loginTitle
        
        tableView.delegate = dataSource
        tableView.dataSource = dataSource
        dataSource.setupTableView(tableView: tableView)
        
        configurateView()
        output.viewIsReady()
    }
    
    func configurateView(){
        tableView.backgroundColor = UIColor.clear
        
        loginButton.backgroundColor = ColorConstants.whiteColor
        loginButton.setTitle(TextConstants.loginTitle, for: UIControlState.normal)
        loginButton.setTitleColor(ColorConstants.blueColor, for: UIControlState.normal)
        loginButton.layer.cornerRadius = loginButton.frame.size.height * 0.5
        loginButton.titleLabel?.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 20)
        
        cantLoginButton.setTitleColor(ColorConstants.whiteColor, for: UIControlState.normal)
        cantLoginButton.setTitle(TextConstants.loginCantLoginButtonTitle, for: UIControlState.normal)
        cantLoginButton.titleLabel?.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 12)
        
        rememberLoginLabel.text = TextConstants.loginRememberMyCredential
        rememberLoginLabel.textColor = ColorConstants.whiteColor
        rememberLoginLabel.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 15)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideKeyboard()
    }
    
    private func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: Buttons action
    
    @IBAction func onLoginButton(){
        
    }
    
    @IBAction func onCantLoginButton(){
        self.output.onCantLoginButton()
    }
    
    @IBAction func onSaveMyLoginButton(){
        
    }
    
    @IBAction func rememberMe(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        button.isSelected = !button.isSelected;
    }

    // MARK: LoginViewInput
    func setupInitialState(array :[BaseCellModel]){
        dataSource.setupCellsWithModels(models: array)
    }
    
    func showCapcha(){
        
    }
    
}
