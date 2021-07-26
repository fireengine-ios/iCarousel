//
//  SplashSplashViewInput.swift
//  Depo
//
//  Created by Oleg on 10/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol SplashViewInput: AnyObject, Waiting, ErrorPresenter {

    func setupInitialState()
}
