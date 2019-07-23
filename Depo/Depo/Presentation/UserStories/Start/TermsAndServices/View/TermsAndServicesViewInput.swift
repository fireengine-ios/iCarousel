//
//  TermsAndServicesTermsAndServicesViewInput.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol TermsAndServicesViewInput: class, Waiting {

    func setupInitialState()
    
    func showLoadedTermsAndUses(eula: String)
    
    func failLoadTermsAndUses(errorString: String)
    
    func noConfirmAgreements(errorString: String)
    
    func hideBackButton()
    
    func popNavigationVC()
    
    func showEtk()
    
    func showGlobalPermissions()
}
