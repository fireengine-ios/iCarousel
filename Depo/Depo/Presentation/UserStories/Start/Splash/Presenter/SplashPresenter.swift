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
    private lazy var storageVars: StorageVars = factory.resolve()
    
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
            rootVC.present(navVC, animated: true, completion: nil)
        }
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view
    }
    
    // MARK: Interactor out
    
    func onSuccessLogin() {
        interactor.checkEULA()
        MenloworksAppEvents.onStartWithLogin(true)
    }
    
    func onSuccessLoginTurkcell() {
        turkcellLogin = true
        interactor.checkEULA()
    }
    
    func onFailLogin() {
        router.navigateToOnboarding()
        MenloworksAppEvents.onStartWithLogin(false)
    }
    
    func onNetworkFail() {
        router.showNetworkError()
    }
    
    func updateUserLanguageSuccess() {
        interactor.checkEmptyEmail()
    }
    
    func updateUserLanguageFailed(error: Error) {
        view.showErrorAlert(message: error.description)
    }
    
    func onSuccessEULA() {
        interactor.updateUserLanguage()
    }
    
    private func openApp() {
        storageVars.emptyEmailUp = false
        CoreDataStack.default.appendLocalMediaItems(progress: { [weak self] progressPercentage in
            DispatchQueue.main.async {
                self?.customProgressHUD.showProgressSpinner(progress: progressPercentage)
            }
            
        }, end: { [weak self] in
            DispatchQueue.main.async {
                self?.customProgressHUD.hideProgressSpinner()
                
                if (self?.turkcellLogin)! {
                    let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
                    if launchedBefore {
                        self?.router.navigateToApplication()
                    } else {
                        self?.router.goToSyncSettingsView()
                        UserDefaults.standard.set(true, forKey: "launchedBefore")
                    }
                } else {
                    self?.router.navigateToApplication()
                }
            }
        })
    }
    
    func showEmptyEmail(show: Bool) {
        show ? openEmptyEmail() : openApp()  
    }
    
    private func openEmptyEmail() {
        storageVars.emptyEmailUp = true
        let vc = EmailEnterController.initFromNib()
        vc.approveCancelHandler = { [weak self] in
            self?.openApp()
        }
        let navVC = UINavigationController(rootViewController: vc)
        UIApplication.topController()?.present(navVC, animated: true, completion: nil)
    }
    
    func onFailEULA() {
        router.navigateToTermsAndService()
    }
}
