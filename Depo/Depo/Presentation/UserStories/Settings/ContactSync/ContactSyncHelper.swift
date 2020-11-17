//
//  ContactSyncHelper.swift
//  Depo
//
//  Created by Andrei Novikau on 6/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import WidgetKit

protocol ContactSyncHelperDelegate: class {
    func didUpdateBackupList()
    func didAnalyze(contacts: [ContactSync.AnalyzedContact])
    func didBackup(result: ContactSync.SyncResponse)
    func didRestore()
    func didDeleteDuplicates()
    func didCancelAnalyze()
    func didFailed(operationType: SyncOperationType, error: ContactSyncHelperError)
    func progress(progress: Int, for operationType: SyncOperationType)
}

extension ContactSyncHelperDelegate {
    func didUpdateBackupList() {}
    func didAnalyze(contacts: [ContactSync.AnalyzedContact]) {}
    func didBackup(result: ContactSync.SyncResponse) {}
    func didRestore() {}
    func didDeleteDuplicates() {}
    func didCancelAnalyze() {}
    func didFailed(operationType: SyncOperationType, error: ContactSyncHelperError) {}
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
    private let contactSyncApiService = ContactSyncApiService()
    private let analyticsHelper = Analytics()
    private let accountService = AccountService()
    private let reachability = ReachabilityService.shared
    private let auth: AuthorizationRepository = factory.resolve()
    let tokenStorage: TokenStorage = factory.resolve()
    
    private(set) var backups = [ContactBackupItem]()
    var lastBackup: ContactBackupItem? {
        backups.first
    }
    
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
            if let currentOperation = currentOperation, currentOperation.isContained(in: [.backup, .restore]) {
                return false
            }
            if AnalyzeStatus.shared().analyzeStep == AnalyzeStep.ANALYZE_STEP_INITAL {
                performOperation(forType: SyncSettings.shared().mode)
            } else if AnalyzeStatus.shared().analyzeStep != AnalyzeStep.ANALYZE_STEP_PROCESS_DUPLICATES {
                proccessOperation(.getBackupList)
            }
            return false
        }
        
        proccessOperation(.getBackupList)
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
            
            guard let self = self else {
                return
            }
            
            self.analyticsHelper.trackStartOperation(type: .deleteDuplicated)
            self.checkAnalyze()
            self.currentOperation = .deleteDuplicated
            self.contactSyncService.deleteDuplicates()
            onStart()
        }
    }
    
    func restore(backup: ContactBackupItem, onStart: @escaping VoidHandler) {
        startOperation(operationType: .restore, backup: backup, onStart: onStart)
    }
    
    func cancelAnalyze() {
        start(operationType: .cancel)
    }
    
    //MARK: - Private
    
    private func startOperation(operationType: SyncOperationType, backup: ContactBackupItem? = nil, onStart: @escaping VoidHandler) {
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
                    if backup?.total == 0  {
                        self?.failed(operationType: operationType, error: .emptyLifeboxContacts)
                    } else {
                        onStart()
                        self?.proccessOperation(operationType, backup: backup)
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
    
    private func proccessOperation(_ operationType: SyncOperationType, backup: ContactBackupItem? = nil) {
        if !reachability.isReachable && operationType.isContained(in: [.backup, .restore, .analyze]) {
            failed(operationType: operationType, error: .syncError(SyncOperationErrors.networkError))
            return
        }
        
        start(operationType: operationType, backup: backup)
    }
    
    private func start(operationType: SyncOperationType, backup: ContactBackupItem? = nil) {
    debugLog("CONTACT SYNC: start")
        updateAccessToken { [weak self] result in
            debugLog("CONTACT SYNC: start updateAccessToken")
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(_):
                self.currentOperation = operationType
                self.analyticsHelper.trackStartOperation(type: operationType)

                switch operationType {
                case .backup:
                    self.contactSyncService.cancelAnalyze()
                    self.performOperation(forType: .backup)
                
                case .restore:
                    self.contactSyncService.cancelAnalyze()
                    self.performOperation(forType: .restore, backup: backup)
                    
                case .cancel:
                    self.contactSyncService.cancelAnalyze()
                    self.delegate?.didCancelAnalyze()
                
                case .getBackupList:
                    self.loadBackupList()
                
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
                self?.analyticsHelper.trackFinishOperation(type: type, status: .success)
                self?.delegate?.didDeleteDuplicates()
                self?.currentOperation = nil
                AnalyzeStatus.shared().reset()
            } else {
                self?.delegate?.progress(progress: progressPercentage, for: type)
            }
        }, successCallback: { [weak self] response in
            debugLog("contactsSyncService.analyze successCallback")
            self?.delegate?.didAnalyze(contacts: response)
            self?.currentOperation = nil
            
        }, cancelCallback: { [weak self] in
            self?.currentOperation = nil
        }, errorCallback: { [weak self] errorType, type in
            self?.analyticsHelper.trackFinishOperation(type: type, status: .failed)
            debugLog("contactsSyncService.analyze errorCallback")
            self?.delegate?.didFailed(operationType: type, error: .syncError(errorType))
        })
    }
    
    private func loadBackupList() {
        let handler: ValueHandler<[ContactBackupItem]> = { [weak self] backups in
            self?.currentOperation = nil
            self?.backups = backups
            self?.delegate?.didUpdateBackupList()
        }
        
        contactSyncApiService.getBackups { result in
            switch result {
            case .success(let response):
                let list = response.list.filter { $0.total > 0 && !$0.isDeleted }
                handler(list)
            case .failed(let error):
                debugLog("loadBackupList fail \(error.description)")
                handler([])
            }
        }
    }
    
    private func performOperation(forType type: SYNCMode, backup: ContactBackupItem? = nil) {
        UIApplication.setIdleTimerDisabled(true)

        contactSyncService.executeOperation(type: type, backupKey: backup?.key ?? "", progress: { [weak self] progressPercentage, count, opertionType in
            DispatchQueue.main.async {
                //progress may be later than the end of the operation
                if self?.isRunning == true {
                    self?.delegate?.progress(progress: progressPercentage, for: opertionType)
                }
            }
            
            }, finishCallback: { [weak self] result, operationType in
                self?.analyticsHelper.trackFinishOperation(type: operationType, status: .success)
                
                UIApplication.setIdleTimerDisabled(false)
                debugLog("contactsSyncService.executeOperation finishCallback: \(result)")
                
                self?.currentOperation = nil
                if type == .backup {
                    self?.delegate?.didBackup(result: result)
                    self?.startOperation(operationType: .getBackupList, onStart: {})
                } else {
                    self?.delegate?.didRestore()
                }
                
            }, errorCallback: { [weak self] errorType, operationType in
                self?.analyticsHelper.trackFinishOperation(type: operationType, status: .failed)
                
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
            debugLog("CONTACT SYNC: updateAccessToken refreshTokens")
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
    
    func trackStartOperation(type: SyncOperationType) {
        switch type {
        case .backup:
            trackBackup()
        case .deleteDuplicated:
            trackDeleteDuplicates()
        case .restore:
            trackRestore()
        default:
            break
        }
    }
    
    func trackFinishOperation(type: SyncOperationType, status: ContactsOperationResult) {
        let netmeraStatus: NetmeraEventValues.GeneralStatus = status == .success ? .success : .failure
        let gaEventLabel: GAEventLabel = status.analyticsGALabel
        
        switch type {
        case .backup:
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Contact(actionType: .backup, status: netmeraStatus))
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .contactOperation(.backup), eventLabel: gaEventLabel)
        case .restore:
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Contact(actionType: .restore, status: netmeraStatus))
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .contactOperation(.restore), eventLabel: gaEventLabel)
        case .deleteDuplicated:
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Contact(actionType: .deleteDuplicate, status: netmeraStatus))
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .contactOperation(.deleteDuplicates), eventLabel: gaEventLabel)
        case .deleteBackup:
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Contact(actionType: .deleteBackup, status: netmeraStatus))
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .contactOperation(.deleteBackup), eventLabel: gaEventLabel)
        default:
            break
        }
    }
    
    private func trackBackup() {
        analyticsService.track(event: .contactBackup)
        analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                            eventActions: .phonebook,
                                            eventLabel: .contact(.backup))
    }
    
    private func trackDeleteDuplicates() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                            eventActions: .phonebook,
                                            eventLabel: .contact(.deleteDuplicates))
    }
    
    private func trackRestore() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                            eventActions: .phonebook,
                                            eventLabel: .contact(.restore))
    }
}


extension ContactSyncHelperDelegate where Self: ContactSyncControllerProtocol {
    
    func didRestore() {
        showResultView(type: .restore, result: .success)
        finishOperation(operationType: .restore)
    }
    
    func didBackup(result: ContactSync.SyncResponse) {
        showResultView(type: .backUp(result), result: .success)
        finishOperation(operationType: .backUp(result))
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func didDeleteDuplicates() {
        //delete contacts is very fast, a delay is needed so that progress can be seen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.showResultView(type: .deleteDuplicates, result: .success)
        }
    }
    
    private func finishOperation(operationType: ContactsOperationType) {
        DispatchQueue.main.async {
            CardsManager.default.stopOperationWith(type: .contactBacupOld)
            CardsManager.default.stopOperationWith(type: .contactBacupEmpty)
            
            self.didFinishOperation(operationType: operationType)
        }
    }
    
    func progress(progress: Int, for operationType: SyncOperationType) {
        hideSpinner()
        
        if progressView?.type != operationType {
            progressView = createProgressView(for: operationType)
        }
        
        if let progressView = progressView {
            show(view: progressView, animated: true)
            progressView.update(progress: progress)
        } else {
            showRelatedView()
        }
    }
    
    private func createProgressView(for operationType: SyncOperationType) -> ContactOperationProgressView? {
        var progressView: ContactOperationProgressView?
        
        switch operationType {
        case .analyze:
            let analyzeProgressView = ContactSyncAnalyzeProgressView.initFromNib()
            analyzeProgressView.delegate = self as? ContactSyncAnalyzeProgressViewDelegate
            progressView = analyzeProgressView
        case .backup, .deleteDuplicated, .restore:
            progressView = ContactSyncProgressView.setup(type: operationType)
        default:
            break
        }
        
        return progressView
    }
    
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
        case .noBackUp:
            showRelatedView()
        case .syncError(let error):
            guard let syncError = error as? SyncOperationErrors else {
                debugLog("ContactSync error not expected type SyncOperationErrors ")
                assertionFailure("This should be Sync operation")
                return
            }
            handleSyncError(syncError: syncError, operationType: operationType)
        }
    }
    
    private func handleSyncError(syncError: SyncOperationErrors, operationType: SyncOperationType) {
        
        switch syncError {
            
        case .remoteServerError(let code):
            handleRemoteServerSyncOperation(syncError: syncError, operationType: operationType, code: code)
            
        case .networkError:
            SnackbarManager.shared.show(type: .action, message: TextConstants.contactSyncErrorNetwork)
            showRelatedView()
            
        case .accessDenied:
            showWarningPopup(type: .contactPermissionDenied)
            showRelatedView()
            
        case .depoError:
            let warningPopUp = ContactSyncPopupFactory.createWarningPopup(type: .lifeboxStorageLimit) { }
            self.present(warningPopUp, animated: false)
            showRelatedView()
            
        case .internalError, .failed:
            let type = operationType.transformToContactOperationSyncType()
            let errorTitle = type?.title(result: .failed) ?? TextConstants.errorUnknown
            let errorView = ContactsOperationView.with(title: errorTitle, message: TextConstants.contactSyncErrorIternal, operationResult: .failed)
            showResultView(view: errorView, title: type?.navBarTitle ?? "")
        }
    }
    
    private func handleRemoteServerSyncOperation(syncError: SyncOperationErrors, operationType: SyncOperationType, code: Int?) {
        guard let convertedOperationType = operationType.transformToContactOperationSyncType() else {
            assertionFailure("Unsupported type, please add additional implementaion or resolve the error")
            debugLog("ContactSync handle error on main screen: - unknown type of operation")
            return
        }

        guard let code = code else {
            showResultView(view: ContactsOperationView.with(type: convertedOperationType, result: .failed), title: convertedOperationType.navBarTitle)
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
        showResultView(view: errorView, title: convertedOperationType.navBarTitle)
    }
    
    func showWarningPopup(type: WarningPopupType) {
        let popup = ContactSyncPopupFactory.createWarningPopup(type: type, handler: {})
        RouterVC().presentViewController(controller: popup, animated: false)
    }
    
    private func showEmptyContactsPopup() {
        RouterVC().popToRootViewController()
        SnackbarManager.shared.show(type: .critical, message: TextConstants.absentContactsForBackup, action: .ok)
        showRelatedView()
    }
    
    private func showEmptyLifeboxContactsPopup() {
        SnackbarManager.shared.show(type: .critical, message: TextConstants.absentContactsInLifebox, action: .ok)
        showRelatedView()
    }
}

//MARK: - Popups and Result views
extension ContactSyncControllerProtocol {
    
    func showPopup(type: ContactSyncPopupType, backup: ContactBackupItem? = nil) {
        let handler: VoidHandler = { [weak self] in
            guard let self = self else {
                return
            }
            
            switch type {
            case .backup:
                self.startBackup()
            case .deleteAllContacts, .deleteBackup:
                if let backup = backup {
                    self.deleteContacts(backupId: backup.id, type: type == .deleteAllContacts ? .deleteAllContacts : .deleteBackUp)
                }
            case .deleteDuplicates:
                self.deleteDuplicates()
            case .restoreBackup, .restoreContacts:
                if let backup = backup {
                    self.restore(backup: backup)
                }
            case .premium:
                let router = RouterVC()
                let controller = router.premium(source: .contactSync)
                router.pushViewController(viewController: controller)
            }
        }
        
        let popup = ContactSyncPopupFactory.createPopup(type: type) { vc in
            vc.close(isFinalStep: false, completion: handler)
        }
        
        present(popup, animated: true)
    }
    
    func showResultView(type: ContactsOperationType, result: ContactsOperationResult) {
        hideSpinner()
        
        let resultView: UIView
        
        switch type {
        case .backUp(_):
            resultView = BackupContactsOperationView.with(type: type, result: result)
        default:
            resultView = ContactsOperationView.with(type: type, result: result)
            
            if result == .success {
                switch type {
                case .deleteDuplicates, .deleteAllContacts, .deleteBackUp:
                    let backUpCard = BackUpContactsCard.initFromNib()
                    (resultView as? ContactsOperationView)?.add(card: backUpCard)
                    
                    backUpCard.backUpHandler = { [weak self] in
                        self?.showPopup(type: .backup)
                    }
                default:
                    break
                }
            }
        }
        
        DispatchQueue.main.async {
            self.showResultView(view: resultView, title: type.navBarTitle)
        }
    }
    
    func showResultView(view: UIView, title: String) {
        show(view: view, animated: true)
    }
    
    //MARK: - Operations
    
    func startBackup() {
        navigationItem.rightBarButtonItem = nil
        progressView?.reset()
        
        showSpinner()
        ContactSyncHelper.shared.backup { }
    }
    
    private func deleteDuplicates() {
        navigationItem.rightBarButtonItem = nil
        progressView?.reset()
        
        showSpinner()
        ContactSyncHelper.shared.deleteDuplicates { }
    }
    
    private func deleteContacts(backupId: Int64, type: ContactsOperationType) {
        navigationItem.rightBarButtonItem = nil
        showSpinner()
        
        ContactSyncApiService().deleteBackup(id: backupId) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(_):
                self.showResultView(type: type, result: .success)
                self.didFinishOperation(operationType: type)
                Analytics().trackFinishOperation(type: .deleteBackup, status: .success)
               
            case .failed(_):
                self.showResultView(type: type, result: .failed)
                Analytics().trackFinishOperation(type: .deleteBackup, status: .failed)
            }
        }
    }
    
    private func restore(backup: ContactBackupItem) {
        navigationItem.rightBarButtonItem = nil
        showSpinner()
        
        progressView?.reset()
        ContactSyncHelper.shared.restore(backup: backup, onStart: {})
    }
}
