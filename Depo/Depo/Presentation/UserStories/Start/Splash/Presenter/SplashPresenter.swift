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
    
    private lazy var customProgressHUD = CustomProgressHUD()
    private var turkcellLogin = false
    
    func viewIsReady() {
        interactor.clearAllPreviouslyStoredInfo()
        showPasscodeIfNeed()
    }
    
    private func showPasscodeIfNeed() {
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window,
            let rootVC = window.rootViewController,
            !interactor.isPasscodeEmpty
        else {
            interactor.startLoginInBackroung()
            return
        }
        
        let vc = PasscodeEnterViewController.with(flow: .validate, navigationTitle: TextConstants.passcodeLifebox)
        
        vc.success = {
            rootVC.dismiss(animated: true, completion: nil)
            self.interactor.startLoginInBackroung()
        }
        
        let navVC = UINavigationController(rootViewController: vc)
        vc.navigationBarWithGradientStyleWithoutInsets()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            rootVC.present(navVC, animated: true,completion: nil)
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
    
    func onSuccessLoginTurkcell(){
        turkcellLogin = true
        interactor.checkEULA()
    }
    
    func onFailLogin(){
        router.navigateToOnboarding()
    }
    
    func onNetworkFail() {
        router.showNetworkError()
    }
    
    func onSuccessEULA() {
        
        CoreDataStack.default.appendLocalMediaItems(progress: { [weak self] progressPercentage in
            DispatchQueue.main.async {
                self?.customProgressHUD.showProgressSpinner(progress: progressPercentage)
            }
        
        }){ [weak self] in
            DispatchQueue.main.async {
                self?.customProgressHUD.hideProgressSpinner()
                
                if (self?.turkcellLogin)! {
                    let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
                    if launchedBefore  {
                        self?.router.navigateToApplication()
                    } else {
                        self?.router.goToSyncSettingsView()
                        UserDefaults.standard.set(true, forKey: "launchedBefore")
                    }
                } else {
                    self?.router.navigateToApplication()
                }
            }
        }
    }
    
    func onFailEULA() {
        router.navigateToTermsAndService()
    }
}
