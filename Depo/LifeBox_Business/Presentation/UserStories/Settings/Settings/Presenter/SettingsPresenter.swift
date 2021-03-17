//
//  SettingsSettingsPresenter.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//
import WidgetKit

final class SettingsPresenter: BasePresenter {
    
    weak var view: SettingsViewInput!
    var interactor: SettingsInteractorInput!
    var router: SettingsRouterInput!
    
    private let cameraService = CameraService()
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}

// MARK: - SettingsViewOutput
extension SettingsPresenter: SettingsViewOutput {
    
    func viewIsReady() {
        startAsyncOperation()
        interactor.getUserInfo()
    }
    
    func onLogout() {
        let controller = PopUpController.with(title: TextConstants.settingsViewLogoutCheckMessage,
                                              message: nil,
                                              image: .none,
                                              firstButtonTitle: TextConstants.cancel,
                                              secondButtonTitle: TextConstants.ok,
                                              secondAction: { [weak self] vc in
                                                vc.close { [weak self] in
                                                    self?.startAsyncOperation()
                                                    self?.interactor.checkConnectedToNetwork()
                                                }
        })
        
        UIApplication.topController()?.present(controller, animated: false, completion: nil)
    }

    func navigateToProfile() {
        router.navigateToProfile()
    }

    func navigateToAgreements() {
        router.navigateToAgreements()
    }

    func navigateToFAQ() {
        router.navigateToFAQ()
    }

    func navigateToContactUs() {
        router.navigateToContactUs()
    }

    func navigateToTrashBin() {
        router.navigateToTrashBin()
    }
    
    func presentErrorMessage(errorMessage: String) {
        router.showError(errorMessage: errorMessage)
    }
}

// MARK: - SettingsInteractorOutput
extension SettingsPresenter: SettingsInteractorOutput {
    func didFailToRetrieveUsageData(error: ErrorResponse) {
        asyncOperationSuccess()
        router.showError(errorMessage: error.errorDescription ?? TextConstants.errorServer)
    }

    func updateStorageUsageDataInfo() {
        view.updateUserDataUsageSection(usageData: interactor.userStorageInfo)
    }
    
    func goToLoginScreen() {
        router.goToLoginScreen()
    }
    
    func connectToNetworkFailed() {
        asyncOperationSuccess()
        router.goToConnectedToNetworkFailed()
    }
    
    func asyncOperationStarted() {
        startAsyncOperation()
    }
    
    func asyncOperationStoped() {
        asyncOperationSuccess()
    }
}

// MARK: - SettingsModuleInput
extension SettingsPresenter: SettingsModuleInput { }
