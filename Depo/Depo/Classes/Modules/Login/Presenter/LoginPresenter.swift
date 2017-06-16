//
//  LoginLoginPresenter.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LoginPresenter: LoginModuleInput, LoginViewOutput, LoginInteractorOutput {

    weak var view: LoginViewInput!
    var interactor: LoginInteractorInput!
    var router: LoginRouterInput!

    func viewIsReady() {
        interactor.prepareModels()
    }
    
    func models(models: [BaseCellModel]) {
        view.setupInitialState(array: models)
    }
    
    func sendLoginAndPassword(login: String, password: String) {
        
    }
    
    func onCantLoginButton(){
        self.router.goToForgotPassword()
    }
}
