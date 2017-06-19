//
//  LoginLoginViewOutput.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol LoginViewOutput {

    /**
        @author Oleg
        Notify presenter that view is ready
    */

    func viewIsReady()
    func sendLoginAndPassword(login: String, password: String)

    func onCantLoginButton()
    
}
