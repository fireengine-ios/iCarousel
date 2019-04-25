//
//  TermsAndServicesTermsAndServicesConfigurator.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class TermsAndServicesModuleConfigurator {

    weak var delegate: RegistrationViewDelegate?
    
    init(delegate: RegistrationViewDelegate?) {
        self.delegate = delegate
    }
    
    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, fromLogin: Bool, phoneNumber: String?, signUpSuccessResponse: SignUpSuccessResponse?, userInfo: RegistrationUserInfoModel?) {

        if let viewController = viewInput as? TermsAndServicesViewController {
            configure(viewController: viewController,
                      fromLogin: fromLogin,
                      phoneNumber: phoneNumber,
                      signUpSuccessResponse: signUpSuccessResponse,
                      userInfo: userInfo)
        }
    }

    private func configure(viewController: TermsAndServicesViewController, fromLogin: Bool, phoneNumber: String?,
                           signUpSuccessResponse: SignUpSuccessResponse?, userInfo: RegistrationUserInfoModel?) {

        let router = TermsAndServicesRouter()

        let presenter = TermsAndServicesPresenter()
        presenter.view = viewController
        presenter.router = router
        presenter.delegate = delegate

        let interactor = TermsAndServicesInteractor()
        interactor.phoneNumber = phoneNumber
        interactor.isFromLogin = fromLogin
        
//        if !fromLogin {
//            interactor.saveSignUpResponse(withResponse: withSignUpSuccessResponse!, andUserInfo: userInfo!)//unwrap
//        }

        if let signUpSuccessResponse = signUpSuccessResponse, let userInfo = userInfo {
            interactor.saveSignUpResponse(withResponse: signUpSuccessResponse, andUserInfo: userInfo)
        }

        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
