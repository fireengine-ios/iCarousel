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
        interactor.clearAllPreviouslyStoredInfo()
        
        let window = (UIApplication.shared.delegate as! AppDelegate).window!
        if PasscodeStorageDefaults().isEmpty || window.rootViewController?.presentedViewController is PasscodeEnterViewController {
            interactor.startLoginInBackroung()
            return
        }
        let vc = PasscodeEnterViewController.with(flow: .validate)
        
        vc.success = {
            window.rootViewController?.dismiss(animated: true, completion: nil)
            self.interactor.startLoginInBackroung()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            window.rootViewController?.present(vc, animated: true,completion: nil)
        }
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
