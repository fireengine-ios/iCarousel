//
//  SplashSplashRouterInput.swift
//  Depo
//
//  Created by Oleg on 10/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SplashRouterInput {
    
    func navigateToApplication()
   
    func navigateToLoginScreen()
    
    func navigateToTermsAndService(isFirstLogin: Bool)
    
    func showNetworkError()
    
    func showError(_ error: Error)
    
}
