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
    
    private func showLoginScreen() {
        router.navigateToLoginScreen()
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
    }
    
    func onSuccessLoginTurkcell() {
        turkcellLogin = true
        interactor.checkEULA()
    }
    
    func onFailLogin() {
        showLoginScreen()
    }
    
    func onNetworkFail() {
        router.showNetworkError()
    }
    
    func updateUserLanguageSuccess() {
        openApp() 
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
        router.navigateToApplication()
        openLink()
    }
    
    func onFailEULA(isFirstLogin: Bool) {
        router.navigateToTermsAndService(isFirstLogin: isFirstLogin)
    }
    
    func onFailGetAccountInfo(error: Error) {
        router.showError(error)
    }

}
