//
//  SyncContactsSyncContactsInteractor.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

enum SyncOperationType {
    case backup
    case restore
    case analyze
    case deleteDuplicated
    case getBackUpStatus
    case cancel
}

enum SyncOperationErrors {
    case accessDenied
    case failed
    case remoteServerError
    case networkError
    case internalError
}

class SyncContactsInteractor: SyncContactsInteractorInput {

    weak var output: SyncContactsInteractorOutput?
    
    private let contactsSyncService = ContactsSyncService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private let contactService: ContactService = ContactService()
    private let accountService: AccountService = AccountService()
    
    deinit {
        contactsSyncService.cancelAnalyze()
    }
    
    func startOperation(operationType: SyncOperationType) {
        updateAccessToken { [weak self] in
            guard let `self` = self else {
                return
            }
            switch operationType {
            case .backup:
                MenloworksAppEvents.onContactUploaded()
                self.analyticsService.track(event: .contactBackup)
                self.analyticsService.logScreen(screen: .contactSyncBackUp)
                self.analyticsService.trackDimentionsEveryClickGA(screen: .contactSyncBackUp)
                self.analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                         eventActions: .phonebook,
                                                         eventLabel: .contact(.backup))
                
                self.contactsSyncService.cancelAnalyze()
                self.performOperation(forType: .backup)
            case .restore:
                MenloworksAppEvents.onContactDownloaded()
                self.analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                         eventActions: .phonebook,
                                                         eventLabel: .contact(.restore))
                
                self.contactsSyncService.cancelAnalyze()
                self.performOperation(forType: .restore)
            case .cancel:
                self.contactsSyncService.cancelAnalyze()
                self.output?.cancelSuccess()
            case .getBackUpStatus:
                self.loadLastBackUp()
            case .analyze:
                self.contactsSyncService.cancelAnalyze()
                self.analyze()
            case .deleteDuplicated:
                self.analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                         eventActions: .phonebook,
                                                         eventLabel: .contact(.deleteDuplicates))
                
                self.deleteDuplicated()
            }
            
            /// workaround of bug that asyncOperationStarted not working in loadLastBackUp
            if operationType != .getBackUpStatus {
                self.output?.asyncOperationFinished()
            }
        }
    }
    
    func trackScreen() {
        analyticsService.logScreen(screen: .contactSyncGeneral)
        analyticsService.trackDimentionsEveryClickGA(screen: .contactSyncGeneral)
    }
    
    private func updateAccessToken(complition: @escaping VoidHandler) {
        let auth: AuthorizationRepository = factory.resolve()
        output?.asyncOperationStarted()
        auth.refreshTokens { [weak self] _, accessToken, error  in
            if let accessToken = accessToken {
                let tokenStorage: TokenStorage = factory.resolve()
                tokenStorage.accessToken = accessToken
                self?.contactsSyncService.updateAccessToken()
                complition()
            } else {
                self?.output?.showError(errorType: error?.isNetworkError == true ? .networkError : .failed)
            }
        }
    }
    
    func performOperation(forType type: SYNCMode) {
        if type == .backup {
            analyticsService.logScreen(screen: .contactSyncBackUp)
            analyticsService.trackDimentionsEveryClickGA(screen: .contactSyncBackUp)
        }
        // TODO: clear NumericConstants.limitContactsForBackUp
        contactsSyncService.executeOperation(type: type, progress: { [weak self] progressPercentage, count, opertionType in
            DispatchQueue.main.async {
                self?.output?.showProggress(progress: progressPercentage, count: 0, forOperation: opertionType)
            }
        }, finishCallback: { [weak self] result, opertionType in
            self?.trackNetmera(operationType: type, status: .success)
            self?.analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                      eventActions: .contactOperation(type),
                                                      eventLabel: .success)
            
            debugLog("contactsSyncService.executeOperation finishCallback: \(result)")
            DispatchQueue.main.async {
                self?.output?.success(response: result, forOperation: opertionType)
                CardsManager.default.stopOperationWithType(type: .contactBacupOld)
                CardsManager.default.stopOperationWithType(type: .contactBacupEmpty)
            }
        }, errorCallback: { [weak self] errorType, opertionType in
            self?.trackNetmera(operationType: type, status: .failure)
            self?.analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                      eventActions: .contactOperation(type),
                                                      eventLabel: .failure)

            debugLog("contactsSyncService.executeOperation errorCallback: \(errorType)")
            DispatchQueue.main.async {
                self?.output?.showError(errorType: errorType)
            }
        })
    }
    
    private func trackNetmera(operationType: SYNCMode, status: NetmeraEventValues.GeneralStatus) {
        switch operationType {
        case .backup:
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Contact(actionType: .backup, staus: status))
        case .restore:
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Contact(actionType: .restore, staus: status))
        }

    }
    
    func getUserStatus() {
        output?.asyncOperationStarted()

        accountService.permissions { [weak self] response in
            self?.output?.asyncOperationFinished()
            
            switch response {
            case .success(let result):
                AuthoritySingleton.shared.refreshStatus(with: result)
                DispatchQueue.toMain {
                    self?.output?.didObtainUserStatus(isPremiumUser: result.hasPermissionFor(.deleteDublicate))
                }
            case .failed(let error):
                DispatchQueue.toMain {
                    self?.output?.didObtainFailUserStatus(errorMessage: error.description)
                }
            }
        }
    }
    
    private func loadLastBackUp() {
        contactsSyncService.getBackUpStatus(completion: { [weak self] model in
            debugLog("loadLastBackUp completion")
            self?.output?.success(response: model, forOperation: .getBackUpStatus)
            self?.output?.asyncOperationFinished()
        }, fail: { [weak self] in
            debugLog("loadLastBackUp fail")
            self?.output?.showNoBackUp()
            self?.output?.asyncOperationFinished()
        })
    }
    
    func analyze() {
        output?.showProggress(progress: 0, count: 0, forOperation: .analyze)
        contactsSyncService.analyze(progressCallback: { [weak self] progressPercentage, count, type in
            DispatchQueue.main.async {
                self?.output?.showProggress(progress: progressPercentage, count: count, forOperation: type)
            }
        }, successCallback: { [weak self] response in
            debugLog("contactsSyncService.analyze successCallback")
            DispatchQueue.main.async {
                self?.output?.analyzeSuccess(response: response)
            }
        }, cancelCallback: nil,
           errorCallback: { [weak self] errorType, type in
            debugLog("contactsSyncService.analyze errorCallback")
            DispatchQueue.main.async {
                self?.output?.showError(errorType: errorType)
            }
        })
    }
    
    private func deleteDuplicated() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Contact(actionType: .deleteDuplicate, staus: .success))
        analyticsService.logScreen(screen: .contacSyncDeleteDuplicates)
        analyticsService.trackDimentionsEveryClickGA(screen: .contacSyncDeleteDuplicates)
        contactsSyncService.deleteDuplicates()
    }
    
    
}
