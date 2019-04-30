//
//  SyncContactsSyncContactsPresenter.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Contacts

typealias ContactsPermissionCallback = (_ success: Bool) -> Void

class SyncContactsPresenter: BasePresenter, SyncContactsModuleInput, SyncContactsViewOutput, SyncContactsInteractorOutput {
    
    weak var view: SyncContactsViewInput!
    var interactor: SyncContactsInteractorInput!
    var router: SyncContactsRouterInput!

    var contactSyncResponse: ContactSync.SyncResponse?
    var isBackUpAvailable: Bool { return contactSyncResponse != nil }
    let reachability = ReachabilityService.shared
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    
    // MARK: view out
    func viewIsReady() {
        interactor.trackScreen()
    }
    
    func viewWillAppear() {
        if ContactSyncSDK.isRunning() {
            if AnalyzeStatus.shared().analyzeStep == AnalyzeStep.ANALYZE_STEP_INITAL {
                interactor.performOperation(forType: SyncSettings.shared().mode)
            } else if AnalyzeStatus.shared().analyzeStep != AnalyzeStep.ANALYZE_STEP_PROCESS_DUPLICATES {
                view.setInitialState()
                startOperation(operationType: .getBackUpStatus)
            }
        } else {
            view.setInitialState()
            startOperation(operationType: .getBackUpStatus)
        }
    }
    
    func startOperation(operationType: SyncOperationType) {
        if operationType != .analyze {
            if operationType != .getBackUpStatus {
                requesetAccess { success in
                    if success {
                        self.proccessOperation(operationType)
                    }
                }
            } else {
                proccessOperation(operationType)
            }
        } else {
            interactor.getUserStatus()
        }
        
    }
    
    // MARK: Interactor Output
    
    func showError(errorType: SyncOperationErrors) {
        switch errorType {
        case .networkError:
            view.showErrorAlert(message: TextConstants.errorConnectedToNetwork)
        case .remoteServerError:
            view.showErrorAlert(message: TextConstants.errorManyContactsToBackUp)
        case .failed:
            view.showErrorAlert(message: TextConstants.serverErrorMessage)
        default:
            // TODO: Error handling
            break
        }
        view.setStateWithBackUp()
        contactSyncResponse = nil
        asyncOperationFinished()
    }
    
    func showProggress(progress: Int, count: Int, forOperation operation: SyncOperationType) {
        view.showProggress(progress: progress, count: count, forOperation: operation)
    }
    
    func success(response: ContactSync.SyncResponse, forOperation operation: SyncOperationType) {
        contactSyncResponse = response
        view.success(response: response, forOperation: operation)
    }
    
    func analyzeSuccess(response: [ContactSync.AnalyzedContact]) {
        if !response.isEmpty {
            router.goToDuplicatedContacts(with: response, moduleOutput: self)
        } else {
            let controller = PopUpController.with(title: nil,
                                                  message: TextConstants.errorAlertTextNoDuplicatedContacts,
                                                  image: .none, buttonTitle: TextConstants.ok)
            UIApplication.topController()?.present(controller, animated: false, completion: nil)
            interactor.startOperation(operationType: .cancel)
        }
    }
    
    func cancelSuccess() {
        guard let _ = view else { return }
        startOperation(operationType: .getBackUpStatus)
//        updateContactsStatus()
    }
    
    func onManageContacts() {
        requesetAccess { success in
            if success {
                self.router.goToManageContacts(moduleOutput: self)
            }
        }
    }
    
    func onDeinit() {
        interactor.startOperation(operationType: .cancel)
    }
    
    func showNoBackUp() {
        view.setStateWithoutBackUp()
    }
    
    func asyncOperationStarted() {
        outputView()?.showSpinner()
    }
    
    func asyncOperationFinished() {
        outputView()?.hideSpinner()
    }
    
    func didObtainUserStatus(isPremiumUser: Bool) {
        if isPremiumUser {
            requesetAccess { success in
                if success {
                    self.proccessOperation(.analyze)
                }
            }
        } else {
            router.goToPremium()
        }
    }
    
    func didObtainFailUserStatus(errorMessage: String) {
        router.showError(errorMessage: errorMessage)
    }
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
    fileprivate func updateContactsStatus() {
        if let contactSyncResponse = contactSyncResponse {
            view.success(response: contactSyncResponse, forOperation: .getBackUpStatus)
        } else {
            view.setStateWithoutBackUp()
        }
        view.resetProgress()
    }
    
    private func sendOperationToOutputs(_ operationType: SyncOperationType) {
        view.setOperationState(operationType: operationType)
        interactor.startOperation(operationType: operationType)
    }
    
    private func proccessOperation(_ operationType: SyncOperationType) {
        if !reachability.isReachable && operationType.isContained(in: [.backup, .restore, .analyze]) {
            router.goToConnectedToNetworkFailed()
            return
        }
        
        if isBackUpAvailable, operationType == .backup {
            sendOperationToOutputs(operationType)
            ///LR-5831 request to remove this pop-up. // Just in case we will save it(for now)
//            let controller = PopUpController.with(title: TextConstants.errorAlerTitleBackupAlreadyExist,
//                                                  message: TextConstants.errorAlertTextBackupAlreadyExist,
//                                                  image: .error,
//                                                  firstButtonTitle: TextConstants.errorAlertNopeBtnBackupAlreadyExist,
//                                                  secondButtonTitle: TextConstants.errorAlertYesBtnBackupAlreadyExist,
//                                                  secondAction: { [weak self] vc in
//                                                    vc.close { [weak self] in
//                                                        self?.sendOperationToOutputs(operationType)
//                                                    }
//            })
//            UIApplication.topController()?.present(controller, animated: false, completion: nil)
            
        } else {
            sendOperationToOutputs(operationType)
        }
    }
    
    private func requesetAccess(completionHandler: @escaping ContactsPermissionCallback) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completionHandler(true)
        case .denied:
            showSettingsAlert(completionHandler: completionHandler)
        case .restricted, .notDetermined:
            passcodeStorage.systemCallOnScreen = true
            
            CNContactStore().requestAccess(for: .contacts) { [weak self] granted, error in
                guard let `self` = self else { return }
                self.passcodeStorage.systemCallOnScreen = false
                DispatchQueue.main.async {
                    if granted {
                        completionHandler(true)
                    } else {
                        self.showSettingsAlert(completionHandler: completionHandler)
                    }
                }
            }
        }
    }
    
    private func showSettingsAlert(completionHandler: @escaping ContactsPermissionCallback) {
        let controller = PopUpController.with(title: TextConstants.errorAlert,
                                              message: TextConstants.settingsContactsPermissionDeniedMessage,
                                              image: .error,
                                              firstButtonTitle: TextConstants.cancel,
                                              secondButtonTitle: TextConstants.ok,
                                              firstAction: { vc in
                                                vc.close { completionHandler(false) }
                                              },
                                              secondAction: { vc in
                                                vc.close { completionHandler(false) }
                                                UIApplication.shared.openSettings()
                                              })
        UIApplication.topController()?.present(controller, animated: false, completion: nil)
    }
}

extension SyncContactsPresenter: DuplicatedContactsModuleOutput {
    func backFromDuplicatedContacts() {
        updateContactsStatus()
    }
    
    func cancelDeletingDuplicatedContacts() {
        //interactor.startOperation(operationType: .cancel)
    }
    
    func deleteDuplicatedContacts() {
        interactor.startOperation(operationType: .deleteDuplicated)
    }
}

extension SyncContactsPresenter: ManageContactsModuleOutput {
    func didDeleteContact() {
        contactSyncResponse?.totalNumberOfContacts -= 1
        updateContactsStatus()
    }
}
