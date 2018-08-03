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
                self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .phonebook, eventLabel: .phoneBookBackUp)
                self.performOperation(forType: .backup)
            case .restore:
                self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .phonebook, eventLabel: .phoneRestore)
                MenloworksAppEvents.onContactDownloaded()
                self.performOperation(forType: .restore)
            case .cancel:
                self.contactsSyncService.cancel()
                self.output?.cancelSuccess()
            case .getBackUpStatus:
                self.loadLastBackUp()
            case .analyze:
                self.analyze()
            case .deleteDuplicated:
                self.analyticsService.logScreen(screen: .contacSyncDeleteDuplicates)
                self.deleteDuplicated()
            }
        }
    }
    
    func trackScreen() {
        analyticsService.logScreen(screen: .contactSyncGeneral)
    }
    
    private func updateAccessToken(complition: @escaping VoidHandler) {
        let auth: AuthorizationRepository = factory.resolve()
        auth.refreshTokens { [weak self] _, accessToken in
            let tokenStorage: TokenStorage = factory.resolve()
            tokenStorage.accessToken = accessToken
            self?.contactsSyncService.updateAccessToken()
            complition()
        }
    }
    func performOperation(forType type: SYNCMode) {
        if type == .backup {
            analyticsService.logScreen(screen: .contactSyncBackUp)
        }
        // TODO: clear NumericConstants.limitContactsForBackUp
        contactsSyncService.executeOperation(type: type, progress: { [weak self] progressPercentage, count, type in
            DispatchQueue.main.async {
                self?.output?.showProggress(progress: progressPercentage, count: 0, forOperation: type)
            }
        }, finishCallback: { [weak self] result, type in
            debugLog("contactsSyncService.executeOperation finishCallback: \(result)")
            DispatchQueue.main.async {
                self?.output?.success(response: result, forOperation: type)
                CardsManager.default.stopOperationWithType(type: .contactBacupOld)
                CardsManager.default.stopOperationWithType(type: .contactBacupEmpty)
            }
        }, errorCallback: { [weak self] errorType, type in
            debugLog("contactsSyncService.executeOperation errorCallback: \(errorType)")
            DispatchQueue.main.async {
                self?.output?.showError(errorType: errorType)
            }
        })
    }
    
    private func loadLastBackUp() {
        output?.asyncOperationStarted()
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
    
    private func analyze() {
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
        analyticsService.logScreen(screen: .contacSyncDeleteDuplicates)
        contactsSyncService.deleteDuplicates()
    }
    
    
}
