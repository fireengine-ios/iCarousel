//
//  SplashSplashInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 10/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SplashInteractorOutput: class, BaseAsyncOperationInteractorOutput {
    
    func onSuccessEULA()
    func onFailEULA(isFirstLogin: Bool)
    
    func onSuccessLogin()
    func onSuccessLoginTurkcell()
    func onFailLogin()
    func onNetworkFail()
    
    func showEmptyEmail(show: Bool)
    
    func updateUserLanguageSuccess()
    func updateUserLanguageFailed(error: Error)
    
    func onFailGetAccountInfo(error: Error)

}
