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
    
    func configureModuleForViewInput<UIViewController>(viewInput: UIViewController, fromLogin: Bool) {

        if let viewController = viewInput as? TermsAndServicesViewController {
            configure(viewController: viewController, fromLogin: fromLogin)
        }
    }

    private func configure(viewController: TermsAndServicesViewController, fromLogin: Bool) {

        let router = TermsAndServicesRouter()

        let presenter = TermsAndServicesPresenter()
        presenter.view = viewController
        presenter.router = router
        presenter.delegate = delegate

        let interactor = TermsAndServicesInteractor()
        interactor.isFromLogin = fromLogin
//        if !fromLogin {
//            interactor.saveSignUpResponse(withResponse: withSignUpSuccessResponse!, andUserInfo: userInfo!)//unwrap
//        }
        interactor.output = presenter

        presenter.interactor = interactor
        viewController.output = presenter
    }

}
