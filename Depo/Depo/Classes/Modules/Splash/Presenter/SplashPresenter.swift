//
//  SplashSplashPresenter.swift
//  Depo
//
//  Created by Oleg on 10/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SplashPresenter:BasePresenter, SplashModuleInput, SplashViewOutput, SplashInteractorOutput {

    weak var view: SplashViewInput!
    
    var interactor: SplashInteractorInput!
    
    var router: SplashRouterInput!

    func viewIsReady() {
        interactor.startLoginInBackroung()
    }
    
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view
    }
    
    
    // MARK: Interactor out
    
    func onSuccessLogin(){
        //check EULA
//        router.navigateToApplication()// temporary
        interactor.checkEULA()
    }
    
    func onFailLogin(){
        router.navigateToOnboarding()
    }
    
    func onSuccessEULA() {
        router.navigateToApplication()
    }
    
    func onFailEULA() {
        router.navigateToTermsAndService()
    }
}
