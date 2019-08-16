//
//  OTPViewOTPViewPresenter.swift
//  Depo
//
//  Created by Oleg on 12/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class OTPViewPresenter: PhoneVerificationPresenter {
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    
    override func verificationSucces() {
        tokenStorage.isClearTokens = true
        successedVerification()
    }
    
    override func verificationSilentSuccess() {
        successedVerification()
    }
    
    private func successedVerification() {
        completeAsyncOperationEnableScreen()
        view.getNavigationController()?.popViewController(animated: true)
    }
}
