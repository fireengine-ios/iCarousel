//
//  SplashSplashPresenter.swift
//  Depo
//
//  Created by Oleg on 10/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class SplashPresenter: BasePresenter, SplashModuleInput, SplashViewOutput, SplashInteractorOutput {

    weak var view: SplashViewInput!
    var interactor: SplashInteractorInput!
    var router: SplashRouterInput!

    func viewIsReady() {
        interactor.clearAllPreviouslyStoredInfo()
        showPasscodeIfNeed()
    }
    
    private func showPasscodeIfNeed() {
        guard
            let window = (UIApplication.shared.delegate as? AppDelegate)?.window,
            let rootVC = window.rootViewController,
            interactor.isPasscodeEmpty || rootVC.presentedViewController is PasscodeEnterViewController
        else {
            return interactor.startLoginInBackroung()
        }
        
        let vc = PasscodeEnterViewController.with(flow: .validate)
        
        vc.success = {
            rootVC.dismiss(animated: true, completion: nil)
            self.interactor.startLoginInBackroung()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            rootVC.present(vc, animated: true,completion: nil)
        }
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view
    }
    
    // MARK: Interactor out
    
    func onSuccessLogin(){
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
