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
    
    @IBOutlet weak var bacgroungImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cantLoginButton: ButtonWithCorner!
    @IBOutlet weak var rememberLoginLabel: UILabel!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString(TextConstants.loginTitle, comment: "")
        
        self.tableView.delegate = self.dataSource
        self.tableView.dataSource = self.dataSource
        self.dataSource.setupTableView(tableView: self.tableView)
        
        self.configurateView()
        
        output.viewIsReady()
    }
    
    func configurateView(){
        self.tableView.backgroundColor = UIColor.clear
        
        self.loginButton.backgroundColor = ColorConstants.whiteColor
        self.loginButton.setTitle(NSLocalizedString("Login", comment: ""), for: UIControlState.normal)
        self.loginButton.setTitleColor(ColorConstants.blueColor, for: UIControlState.normal)
        self.loginButton.layer.cornerRadius = self.loginButton.frame.size.height * 0.5
        self.loginButton.titleLabel?.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 20)
        
        self.cantLoginButton.setTitleColor(ColorConstants.whiteColor, for: UIControlState.normal)
        self.cantLoginButton.setTitle(NSLocalizedString("I can't login", comment: ""), for: UIControlState.normal)
        self.cantLoginButton.titleLabel?.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 12)
        
        self.rememberLoginLabel.text = NSLocalizedString("Remember my credentials", comment: "")
        self.rememberLoginLabel.textColor = ColorConstants.whiteColor
        self.rememberLoginLabel.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 15)
    }
    
    // MARK: Buttons action
    
    @IBAction func onLoginButton(){
        
    }
    
    @IBAction func onCantLoginButton(){
        
    }
    
    @IBAction func onSaveMyLoginButton(){
        
    }

    // MARK: LoginViewInput
    func setupInitialState(array :[BaseCellModel]){
        self.dataSource.setupCellsWithModels(models: array)
    }
    
    func showCapcha(){
        
    }
    
}
