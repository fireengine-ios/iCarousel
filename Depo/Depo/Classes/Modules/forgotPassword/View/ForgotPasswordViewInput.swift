//
//  ForgotPasswordForgotPasswordViewInput.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol ForgotPasswordViewInput: class {

    /**
        @author Oleg
        Setup initial state of the view
    */

    func setupInitialState()
    func showCapcha()
}
