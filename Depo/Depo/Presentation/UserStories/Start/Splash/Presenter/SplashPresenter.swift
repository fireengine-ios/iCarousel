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
        CoreDataStack.default.appendLocalMediaItems(completion: nil)
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
        
        let navVC = NavigationController(rootViewController: vc)
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
        
        if turkcellLogin {
            if storageVars.autoSyncSet {
                router.navigateToApplication()
            } else {
                router.goToSyncSettingsView()
            }
        } else {
            router.navigateToApplication()
        }
        interactor.updateUserLanguage()
    }
    
    private func openApp() {
        storageVars.emptyEmailUp = false

        if turkcellLogin {
            if storageVars.autoSyncSet {
                router.navigateToApplication()
            } else {
                router.goToSyncSettingsView()
            }
        } else {
            router.navigateToApplication()
        }
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
        let navVC = NavigationController(rootViewController: vc)
        UIApplication.topController()?.present(navVC, animated: true, completion: nil)
    }
    
    func onFailEULA() {
        router.navigateToTermsAndService()
    }
}
