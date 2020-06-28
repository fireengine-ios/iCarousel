//
//  ContactSyncHelper.swift
//  Depo
//
//  Created by Andrei Novikau on 6/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol ContactSyncHelperDelegate: class {
    func didUpdateBackupStatus()
    func didAnalyze(contacts: [ContactSync.AnalyzedContact])
    func didBackup(result: ContactSync.SyncResponse)
    func didRestore()
    func didDeleteDuplicates()
    func didCancelAnalyze()
    func didFailed(operationType: SyncOperationType, error: ContactSyncHelperError)
    func progress(progress: Int, for operationType: SyncOperationType)
}

extension ContactSyncHelperDelegate {
    func didUpdateBackupStatus() {}
    func didAnalyze(contacts: [ContactSync.AnalyzedContact]) {}
    func didBackup(result: ContactSync.SyncResponse) {}
    func didRestore() {}
    func didDeleteDuplicates() {}
    func didCancelAnalyze() {}
//    func didFailed(operationType: SyncOperationType, error: ContactSyncHelperError) {}
    func progress(progress: Int, for operationType: SyncOperationType) {}
}

enum ContactSyncHelperError {
    case notPremiumUser
    case accessDenied
    case emptyStoredContacts
    case emptyLifeboxContacts
    case noBackUp
    case syncError(Error)
}

final class ContactSyncHelper {
    
    static let shared = ContactSyncHelper()
    
    weak var delegate: ContactSyncHelperDelegate? {
        didSet {
            if let operation = currentOperation, let progressPercentage = currentOperationProgress {
                delegate?.progress(progress: progressPercentage, for: operation)
            }
        }
    }
    
    private let localContactsService = ContactService()
    private let contactSyncService = ContactsSyncService()
    private let analyticsHelper = Analytics()
    private let accountService = AccountService()
    private let reachability = ReachabilityService.shared
    private let auth: AuthorizationRepository = factory.resolve()
    let tokenStorage: TokenStorage = factory.resolve()
    
    private (set) var syncResponse: ContactSync.SyncResponse?
    
    private(set) var currentOperation: SyncOperationType?
    var currentOperationProgress: Int? {
        return SyncStatus.shared().progress?.intValue
    }
    
    //MARK: - Public
    
    var isRunning: Bool {
        return ContactSyncSDK.isRunning()
    }
    
    func prepare() -> Bool {
        //TODO: check logic, maybe just cancel and call .getBackUpStatus
        guard !ContactSyncSDK.isRunning() else {
            if AnalyzeStatus.shared().analyzeStep == AnalyzeStep.ANALYZE_STEP_INITAL {
                performOperation(forType: SyncSettings.shared().mode)
            } else if AnalyzeStatus.shared().analyzeStep != AnalyzeStep.ANALYZE_STEP_PROCESS_DUPLICATES {
                proccessOperation(.getBackUpStatus)
            }
            return false
        }
        
        proccessOperation(.getBackUpStatus)
        return true
    }
    
    func backup(onStart: @escaping VoidHandler) {
        startOperation(operationType: .backup, onStart: onStart)
    }
    
    func analyze(onStart: @escaping VoidHandler) {
        userHasPermissionFor(type: .deleteDublicate) { [weak self] hasPermission in
            guard hasPermission else {
                self?.failed(operationType: .analyze, error: .notPremiumUser)
                return
            }
            self?.startOperation(operationType: .analyze, onStart: onStart)
        }
    }
    
    func deleteDuplicates(onStart: @escaping VoidHandler) {
        userHasPermissionFor(type: .deleteDublicate) { [weak self] hasPermission in
            guard hasPermission else {
                self?.failed(operationType: .deleteDuplicated, error: .notPremiumUser)
                return
            }
            self?.checkAnalyze()
            self?.currentOperation = .deleteDuplicated
            self?.contactSyncService.deleteDuplicates()
            onStart()
        }
    }
    
    func restore(onStart: @escaping VoidHandler) {
        startOperation(operationType: .restore, onStart: onStart)
    }
    
    func cancelAnalyze() {
        start(operationType: .cancel)
    }
    
    //MARK: - Private
    
    private func startOperation(operationType: SyncOperationType, onStart: @escaping VoidHandler) {
        requestAccess { [weak self] success in
            guard success else {
                self?.failed(operationType: operationType, error: .accessDenied)
                return
            }
            
            switch operationType {
                case .backup, .analyze:
                    if self?.getStoredContactsCount() == 0 {
                        self?.failed(operationType: operationType, error: .emptyStoredContacts)
                    } else {
                        onStart()
                        self?.proccessOperation(operationType)
                    }
                
                case .restore:
                    if self?.syncResponse?.totalNumberOfContacts == 0  {
                        self?.failed(operationType: operationType, error: .emptyLifeboxContacts)
                    } else {
                        onStart()
                        self?.proccessOperation(operationType)
                    }
                
                default:
                    onStart()
                    self?.proccessOperation(operationType)
            }
        }
    }
    
    private func getStoredContactsCount() -> Int {
        return localContactsService.getContactsCount() ?? 0
    }
    
    private func proccessOperation(_ operationType: SyncOperationType) {
        if !reachability.isReachable && operationType.isContained(in: [.backup, .restore, .analyze]) {
            failed(operationType: operationType, error: .syncError(SyncOperationErrors.networkError))
            return
        }
        
        start(operationType: operationType)
    }
    
    private func start(operationType: SyncOperationType) {
        updateAccessToken { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(_):
                self.currentOperation = operationType

                switch operationType {
                case .backup:
                    self.contactSyncService.cancelAnalyze()
                    self.performOperation(forType: .backup)
                
                case .restore:
                    self.contactSyncService.cancelAnalyze()
                    self.performOperation(forType: .restore)
                    
                case .cancel:
                    self.contactSyncService.cancelAnalyze()
                    self.delegate?.didCancelAnalyze()
                
                case .getBackUpStatus:
                    self.loadLastBackUp()
                
                case .analyze:
                    self.contactSyncService.cancelAnalyze()
                    self.checkAnalyze()
                
                default:
                    assertionFailure("operation is not allowed")
                }
            case .failed(let error):
                self.failed(operationType: operationType, error: .syncError(error))
            }
        }
    }
    
    private func checkAnalyze() {
        contactSyncService.analyze(progressCallback: { [weak self] progressPercentage, count, type in
            if progressPercentage == 0 && type == .deleteDuplicated {
                self?.delegate?.didDeleteDuplicates()
                self?.currentOperation = nil
            } else {
                self?.delegate?.progress(progress: progressPercentage, for: type)
            }
        }, successCallback: { [weak self] response in
            debugLog("contactsSyncService.analyze successCallback")
            
            self?.delegate?.didAnalyze(contacts: response)
            self?.currentOperation = nil
            
        }, cancelCallback: nil,
           errorCallback: { [weak self] errorType, type in
            debugLog("contactsSyncService.analyze errorCallback")
            self?.delegate?.didFailed(operationType: type, error: .syncError(errorType))
        })
    }
    
    private func loadLastBackUp() {
        let handler: ((ContactSync.SyncResponse?) -> Void) = { [weak self] model in
            self?.syncResponse = model
            self?.delegate?.didUpdateBackupStatus()
            self?.currentOperation = nil
        }
        
        contactSyncService.getBackUpStatus(completion: { model in
            debugLog("loadLastBackUp completion")
            handler(model)
        }, fail: {
            debugLog("loadLastBackUp fail")
            handler(nil)
        })
    }
    
    private func performOperation(forType type: SYNCMode) {
        UIApplication.setIdleTimerDisabled(true)

        // TODO: clear NumericConstants.limitContactsForBackUp
        contactSyncService.executeOperation(type: type, progress: { [weak self] progressPercentage, count, opertionType in
            self?.delegate?.progress(progress: progressPercentage, for: opertionType)
            
            }, finishCallback: { [weak self] result, operationType in
                self?.analyticsHelper.trackOperationSuccess(type: type)
                
                UIApplication.setIdleTimerDisabled(false)
                debugLog("contactsSyncService.executeOperation finishCallback: \(result)")
                
                (type == .backup) ? self?.delegate?.didBackup(result: result) :  self?.delegate?.didRestore()
                self?.currentOperation = nil
                
            }, errorCallback: { [weak self] errorType, operationType in
                self?.analyticsHelper.trackOperationFailure(type: type)
                
                debugLog("contactsSyncService.executeOperation errorCallback: \(errorType)")
                
                UIApplication.setIdleTimerDisabled(false)
                self?.failed(operationType: operationType, error: .syncError(errorType))
        })
    }

    //MARK:- Tokens + Contacts Access + Persmissions
    
    private func userHasPermissionFor(type: AuthorityType, completion: @escaping BoolHandler) {
        accountService.permissions { [weak self] response in
            switch response {
            case .success(let result):
                AuthoritySingleton.shared.refreshStatus(with: result)
                completion(result.hasPermissionFor(type))
                
            case .failed(let error):
                if let code = (error as? URLError)?.code, code.isContained(in: [.networkConnectionLost, .notConnectedToInternet]) {
                    self?.failed(operationType: .deleteDuplicated, error: .syncError(SyncOperationErrors.networkError))
                    return
                }
                
                completion(false)
            }
        }
    }
    
    private func requestAccess(completionHandler: @escaping ContactsLibraryGranted) {
        localContactsService.askPermissionForContactsFramework(redirectToSettings: false) { isGranted in
            AnalyticsPermissionNetmeraEvent.sendContactPermissionNetmeraEvents(isGranted)
            completionHandler(isGranted)
        }
    }
    
    private func updateAccessToken(complition: @escaping ResponseVoid) {
        auth.refreshTokens { [weak self] _, accessToken, error  in
            guard let accessToken = accessToken else {
                let syncError: SyncOperationErrors = error?.isNetworkError == true ? .networkError : .failed
                complition(.failed(syncError))
                return
            }
            
            self?.tokenStorage.accessToken = accessToken
            self?.contactSyncService.updateAccessToken()
            complition(.success(()))
        }
    }
    
    private func failed(operationType: SyncOperationType, error: ContactSyncHelperError) {
        currentOperation = nil
        delegate?.didFailed(operationType: operationType, error: error)
    }
}

private final class Analytics {
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    func trackOperationSuccess(type: SYNCMode) {
        analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                            eventActions: .contactOperation(type),
                                            eventLabel: .success)
        
        trackNetmera(operationType: type, status: .success)
    }
    
    func trackOperationFailure(type: SYNCMode) {
        analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                            eventActions: .contactOperation(type),
                                            eventLabel: .failure)
        
        trackNetmera(operationType: type, status: .failure)
    }

    private func trackNetmera(operationType: SYNCMode, status: NetmeraEventValues.GeneralStatus) {
        switch operationType {
            case .backup:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Contact(actionType: .backup, status: status))
            
            case .restore:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Contact(actionType: .restore, status: status))
            
            default: break
        }
    }
    
}


extension ContactSyncHelperDelegate where Self: ContactSyncControllerProtocol {
    
    func didFailed(operationType: SyncOperationType, error: ContactSyncHelperError) {
        DispatchQueue.main.async {
            self.hideSpinner()
            self.handleError(operationType: operationType, error: error)
        }
    }
    
    private func handleError(operationType: SyncOperationType, error: ContactSyncHelperError) {
        
        switch error {
        case .notPremiumUser:
            showPopup(type: .premium)
        case .accessDenied:
            showWarningPopup(type: .contactPermissionDenied)
        case .emptyStoredContacts:
            showEmptyContactsPopup()
        case .emptyLifeboxContacts:
            showEmptyLifeboxContactsPopup()
        case .syncError(let error):
            guard let syncError = error as? SyncOperationErrors else {
                debugLog("ContactSync error not expected type SyncOperationErrors ")
                assertionFailure("This should be Sync operation")
                return
            }
            handleSyncError(syncError: syncError, operationType: operationType)
        default:
            handle(error: error, operationType: operationType)
        }
    }
    
    private func handleSyncError(syncError: SyncOperationErrors, operationType: SyncOperationType) {
        
        switch syncError {
            
        case .remoteServerError(let code):
            handleRemoteServerSyncOperation(syncError: syncError, operationType: operationType, code: code)
            
        case .networkError:
            SnackbarManager.shared.show(type: .action, message: TextConstants.contactSyncErrorNetwork)
            
        case .accessDenied:
            showWarningPopup(type: .contactPermissionDenied)
            
        case .depoError:
            self.present(FullQuotaWarningPopUp(.contact(operationType.transformToContactSyncQuotaTypeOperation())), animated: false)
            
        case .internalError, .failed:
            let errorTitle = operationType.transformToContactOperationSyncType()?.title(result: .failed) ?? TextConstants.errorUnknown
            let errorView = ContactsOperationView.with(title: errorTitle, message: TextConstants.contactSyncErrorIternal, operationResult: .failed)
            showErrorView(view: errorView)
        }
    }
    
    private func handleRemoteServerSyncOperation(syncError: SyncOperationErrors, operationType: SyncOperationType, code: Int?) {
        guard let convertedOperationType = operationType.transformToContactOperationSyncType() else {
            assertionFailure("Unsupported type, please add additional implementaion or resolve the error")
            debugLog("ContactSync handle error on main screen: - unknown type of operation")
            return
        }

        guard let code = code else {
            showErrorView(view: ContactsOperationView.with(type: convertedOperationType, result: .failed))
            return
        }
        let message: String
        switch code {
        case 1101:
            message = TextConstants.contactSyncErrorRemoteServer1101
        case 2000:
            message = TextConstants.contactSyncErrorRemoteServer2000
        case 3000:
            message = TextConstants.contactSyncErrorRemoteServer3000
        case 4000:
            message = TextConstants.contactSyncErrorRemoteServer4000
        default:
            message = TextConstants.contactSyncErrorRemoteServer3000 ///3000 is default state
        }
        
        let errorView = ContactsOperationView.with(title: convertedOperationType.title(result: .failed), message: message, operationResult: .failed)
        showErrorView(view: errorView)
    }
    
    func showErrorView(view: ContactsOperationView) {
        ContentViewAnimator().showTransition(to: view, on: self.view, animated: true)
    }
    
    func showWarningPopup(type: WarningPopupType) {
        let popup = ContactSyncPopupFactory.createWarningPopup(type: type, handler: {})
        RouterVC().presentViewController(controller: popup, animated: false)
    }
    
    private func showEmptyContactsPopup() {
        SnackbarManager.shared.show(type: .critical, message: TextConstants.absentContactsForBackup, action: .ok)
    }
    
    private func showEmptyLifeboxContactsPopup() {
        SnackbarManager.shared.show(type: .critical, message: TextConstants.absentContactsInLifebox, action: .ok)
    }
    
}
