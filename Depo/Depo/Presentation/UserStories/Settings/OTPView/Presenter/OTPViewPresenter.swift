//
//  OTPViewOTPViewPresenter.swift
//  Depo
//
//  Created by Oleg on 12/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class OTPViewPresenter: PhoneVereficationPresenter {
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    
    override func verificationSucces() {
        completeAsyncOperationEnableScreen()
        view.getNavigationController()?.popViewController(animated: true)
    }
}
