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
    private lazy var autoSyncRoutingService = AutoSyncRoutingService()
    
    func viewIsReady() {
        interactor.trackScreen()
        TurkcellUpdaterService().startUpdater(controller: self.view as? UIViewController) { [weak self] shouldProceed in
            guard shouldProceed else {
                self?.showUpdateIsRequiredPopup()
                return
            }
            self?.showPasscodeIfNeed()
        }
    }
    
    private func showUpdateIsRequiredPopup() {
        let popup = PopUpController.with(title: TextConstants.turkcellUpdateRequiredTitle, message: TextConstants.turkcellUpdateRequiredMessage, image: .error, buttonTitle: TextConstants.ok) { popup in
            debugLog("required app killing")
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                exit(EXIT_SUCCESS)
            })
        }
        UIApplication.topController()?.present(popup, animated: false, completion: nil)
        return
    }
    
    private func showLandingPagesIfNeeded() {
        if storageVars.isNewAppVersionFirstLaunchTurkcellLanding {
            router.navigateToLandingPages(isTurkCell: false)
        } else {
            router.navigateToOnboarding()
        }
    }
    
    private func showPasscodeIfNeed() {
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window,
            let rootVC = window.rootViewController,
            !interactor.isPasscodeEmpty
        else {
            interactor.startLoginInBackground()
            return
        }
        
        let vc = PasscodeEnterViewController.with(flow: .validate, navigationTitle: TextConstants.passcodeLifebox)
        
        vc.success = {
            rootVC.dismiss(animated: true, completion: {
                self.interactor.startLoginInBackground()
            })
        }
        
        let navVC = NavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .overFullScreen
        
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
        MenloworksAppEvents.onStartWithLogin(true)
    }
    
    func onFailLogin() {
        showLandingPagesIfNeeded()
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
    
    func openLink() {
        debugLog("Open Link on Splash Presenter")
        if let deepLink = storageVars.deepLink {
            if PushNotificationService.shared.assignDeepLink(innerLink: deepLink, options: storageVars.deepLinkParameters) {
                debugLog("Open Link after Router navigates to home")
                PushNotificationService.shared.openActionScreen()
            }
        }
    }
    
    private func openApp() {
        AuthoritySingleton.shared.checkNewVersionApp()
        
        if turkcellLogin {
            if storageVars.autoSyncSet {
                if !Device.isIpad, storageVars.isNewAppVersionFirstLaunchTurkcellLanding {
                    storageVars.isNewAppVersionFirstLaunchTurkcellLanding = false
                    router.navigateToLandingPages(isTurkCell: turkcellLogin)
                } else {
                    router.navigateToApplication()
                    openLink()
                }
            } else {
                if !Device.isIpad, storageVars.isNewAppVersionFirstLaunchTurkcellLanding {
                    storageVars.isNewAppVersionFirstLaunchTurkcellLanding = false
                    router.navigateToLandingPages(isTurkCell: turkcellLogin)
                } else {
                    openAutoSyncIfNeeded()
                }
            }
        } else {
            if storageVars.autoSyncSet {
                router.navigateToApplication()
                openLink()
            } else {
                openAutoSyncIfNeeded()
            }
        }
    }
    
    func showEmptyEmail(show: Bool) {
        show ? openEmptyEmail() : openApp()  
    }
    
    private func openEmptyEmail() {
        /// guard for two controller due to interactor.startLoginInBackground()
        if UIApplication.topController() is EmailEnterController {
            return
        }
        
        let vc = EmailEnterController.initFromNib()
        vc.successHandler = { [weak self] in
            self?.openApp()
        }
        let navVC = NavigationController(rootViewController: vc)
        UIApplication.topController()?.present(navVC, animated: true, completion: nil)
    }
    
    private func openAutoSyncIfNeeded() {
        view.showSpinner()
        autoSyncRoutingService.checkNeededOpenAutoSync(success: { [weak self] needToOpenAutoSync in
            self?.view.hideSpinner()
            
            if needToOpenAutoSync {
                self?.router.goToSyncSettingsView(fromSplash: true)
            }
        }) { [weak self] error in
            self?.view.hideSpinner()
        }
    }
    
    func onFailEULA(isFirstLogin: Bool) {
        router.navigateToTermsAndService(isFirstLogin: isFirstLogin)
    }
    
    func onFailGetAccountInfo(error: Error) {
        router.showError(error)
    }

}
