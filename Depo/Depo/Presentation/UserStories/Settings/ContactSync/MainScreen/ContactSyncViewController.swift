//
//  ContactSyncViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 19.05.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit
import Contacts


protocol ContactsBackupActionProviderProtocol: class {
    func backUp()
}

final class ContactSyncViewController: BaseViewController, NibInit {
    
    @IBOutlet private weak var contentView: UIView!
    
    private var tabBarIsVisible = false
    
    private lazy var noBackupView: ContactSyncNoBackupView = {
        let view = ContactSyncNoBackupView.initFromNib()
        view.delegate = self
        return view
    }()
    
    private lazy var mainView: ContactSyncMainView = {
        let view = ContactSyncMainView.initFromNib()
        view.delegate = self
        return view
    }()
    
    
    private let syncService = ContactsSyncService()
    private let periodicSyncHelper = PeriodicSync()
    private var animator = ContentViewAnimator()
    private let analyticsHelper = Analytics()
    private lazy var contactSyncHelper: ContactSyncHelper = {
        return ContactSyncHelper(delegate: self)
    }()
    
    private var syncModel: ContactSync.SyncResponse?
    
    private lazy var router = RouterVC()
    
    //MARK:- Override
    
    deinit {
        syncService.cancelAnalyze()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        analyticsHelper.trackScreen()
        
        if tabBarIsVisible {
            needToShowTabBar = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
        setupContentView()
        
        contactSyncHelper.prepare()
    }
    
    
    //MARK: - Public
    
    func setTabBar(isVisible: Bool) {
        tabBarIsVisible = isVisible
    }
    
    
    //MARK:- Private
    
    private func setupNavBar() {
        if tabBarIsVisible {
            homePageNavigationBarStyle()
        } else {
            navigationBarWithGradientStyle()
            setTitle(withString: TextConstants.backUpMyContacts)
        }
    }
    
    private func setupContentView() {
//        showSpinner()
        getBackupStatus { [weak self] in
//            guard let self = self else {
//                return
//            }
//            self.hideSpinner()
//            self.showRelatedView()
        }
    }
    
    private func showRelatedView() {
        guard let model = syncModel, model.totalNumberOfContacts != 0 else {
            self.show(view: self.noBackupView, animated: true)
            return
        }
        
        self.mainView.update(with: model, periodicSyncOption: periodicSyncHelper.settings.timeSetting.option)
        self.show(view: self.mainView, animated: true)
    }
    
    private func getBackupStatus(completion: @escaping VoidHandler) {
        
//        syncService.getBackUpStatus(completion: { [weak self] model in
//            debugLog("loadLastBackUp completion")
//
//            guard let self = self else {
//                return
//            }
//
//            self.syncModel = model
//            completion()
//
//        }, fail: { [weak self] in
//            debugLog("loadLastBackUp fail")
//
//            guard let self = self else {
//                return
//            }
//
//            //TODO: show error?
//            self.syncModel = nil
//            completion()
//        })
    }
    
    private func show(view: UIView, animated: Bool) {
        animator.showTransition(to: view, on: contentView, animated: true)
    }

}


//MARK:- protocols extensions

extension ContactSyncViewController: ContactsBackupActionProviderProtocol {
    func backUp() {
        contactSyncHelper.backup()
    }
}

extension ContactSyncViewController: ContactSyncMainViewDelegate {
    
    func showBackups() {
        //TODO: Open backups screen
        showRelatedView()
    }
    
    func deleteDuplicates() {
        showSpinner()
        contactSyncHelper.analyze()
    }
    
    func changePeriodicSync(to option: PeriodicContactsSyncOption) {
        periodicSyncHelper.save(option: option)
    }
}


extension ContactSyncViewController: ContactSyncHelperDelegate {
    func didBackup() {
        showRelatedView()
    }
    
    func didAnalyze(contacts: [ContactSync.AnalyzedContact]) {
        hideSpinner()
        
        if contacts.isEmpty {
            noDuplicatesPopup()
            contactSyncHelper.cancelAnalyze()
        } else {
            let controller = router.deleteContactDuplicates(analyzeResponse: contacts, delegate: self)
            router.pushViewController(viewController: controller)
        }
    }
   
    func didUpdateBackupStatus() {
        syncModel = contactSyncHelper.syncResponse
        showRelatedView()
    }
    
    func didFailed(error: ContactSyncHelperError) {
        DispatchQueue.main.async {
            self.hideSpinner()
            self.handleError(error)
        }
    }
}

//MARK: - DeleteDuplicatesDelegate

extension ContactSyncViewController: DeleteDuplicatesDelegate {

    func startBackUp() {
        contactSyncHelper.backup()
    }
}

//MARK: - Popups

extension ContactSyncViewController {
    
    private func handleError(_ error: ContactSyncHelperError) {
        switch error {
        case .notPremiumUser:
            showPremiumPopup()
        case .noBackUp:
            showRelatedView()
        case .emptyStoredContacts:
            showEmptyContactsPopup()
        case .emptyLifeboxContacts:
            showEmptyLifeboxContactsPopup()
        case .syncError(let error):
            UIApplication.showErrorAlert(message: error.description)
        }
    }
    
    private func showPremiumPopup() {
        let popup = PopUpController.with(title: TextConstants.contactSyncConfirmPremiumPopupTitle,
                                         message: TextConstants.contactSyncConfirmPremiumPopupText,
                                         image: .none,
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.ok,
                                         firstAction: { vc in
                                            vc.close()
                                         }, secondAction: { vc in
                                            vc.close(isFinalStep: false) { [weak self] in
                                                guard let self = self else {
                                                    return
                                                }
                                                
                                                let controller = self.router.premium(source: .contactSync)
                                                self.router.pushViewController(viewController: controller)
                                            }
                                         })
        present(popup, animated: true)
    }
    
    private func noDuplicatesPopup() {
        let controller = PopUpController.with(title: nil,
                                              message: TextConstants.errorAlertTextNoDuplicatedContacts,
                                              image: .none, buttonTitle: TextConstants.ok)
        present(controller, animated: false)
    }
    
    private func showEmptyContactsPopup() {
        SnackbarManager.shared.show(type: .critical, message: TextConstants.absentContactsForBackup, action: .ok)
    }
    
    private func showEmptyLifeboxContactsPopup() {
        SnackbarManager.shared.show(type: .critical, message: TextConstants.absentContactsInLifebox, action: .ok)
    }
}

//MARK: - Private classes - helpers

private final class ContentViewAnimator {
    
    func showTransition(to newView: UIView, on contentView: UIView, animated: Bool) {
        let currentView = contentView.subviews.first
        
        guard newView != currentView else {
            return
        }
        
        DispatchQueue.main.async {
            newView.frame = contentView.bounds
            
            if let oldView = currentView {
                let duration = animated ? 0.25 : 0.0
                UIView.transition(from: oldView, to: newView, duration: duration, options: [.curveLinear], completion: nil)
            } else {
                contentView.addSubview(newView)
            }
        }
    }
}

private final class PeriodicSync {
    
    private let contactsService = ContactService()
    private let dataStorage = PeriodicContactSyncDataStorage()
    
    var settings: PeriodicContactsSyncSettings {
        return dataStorage.settings
    }
    
    
    func save(option: PeriodicContactsSyncOption) {
        let setting = PeriodicContactsSyncSetting(option: option)
        settings.set(periodicContactsSync: setting)
        dataStorage.save(periodicContactSyncSettings: settings)
        
        var periodicBackUp: SYNCPeriodic = SYNCPeriodic.none
        
        switch option {
            case .daily:
                periodicBackUp = SYNCPeriodic.daily
            case .weekly:
                periodicBackUp = SYNCPeriodic.every7
            case .monthly:
                periodicBackUp = SYNCPeriodic.every30
            case .off:
                periodicBackUp = SYNCPeriodic.none
        }
        
        contactsService.setPeriodicForContactsSync(periodic: periodicBackUp)
    }
}


private final class Analytics {
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    func trackScreen() {
        analyticsService.logScreen(screen: .contactSyncGeneral)
        analyticsService.trackDimentionsEveryClickGA(screen: .contactSyncGeneral)
    }
    
    func trackOperation(type: SyncOperationType) {
        switch type {
            case .backup:
                //TODO: to related view
//                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.ContactBackUpScreen())
//                analyticsService.logScreen(screen: .contactSyncBackUp)
//                analyticsService.trackDimentionsEveryClickGA(screen: .contactSyncBackUp)
                
                
                analyticsService.track(event: .contactBackup)
                analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                    eventActions: .phonebook,
                                                    eventLabel: .contact(.backup))
            case .restore:
                analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                    eventActions: .phonebook,
                                                    eventLabel: .contact(.restore))
            
            case .deleteDuplicated:
                analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                    eventActions: .phonebook,
                                                    eventLabel: .contact(.deleteDuplicates))
            default: break
        }
    }
    
    func trackOperation(type: SYNCMode) {
        if type == .backup {
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.ContactsSyncScreen())
            analyticsService.logScreen(screen: .contactSyncBackUp)
            analyticsService.trackDimentionsEveryClickGA(screen: .contactSyncBackUp)
        }
    }
    
    func trackDeleteDuplicates() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Contact(actionType: .deleteDuplicate, status: .success))
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.DeleteDuplicateScreen())
        analyticsService.logScreen(screen: .contacSyncDeleteDuplicates)
        analyticsService.trackDimentionsEveryClickGA(screen: .contacSyncDeleteDuplicates)
    }
    
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


protocol ContactSyncHelperDelegate: class {
    func didUpdateBackupStatus()
    func didAnalyze(contacts: [ContactSync.AnalyzedContact])
    func didBackup()
    func didFailed(error: ContactSyncHelperError)
}

enum ContactSyncHelperError {
    case notPremiumUser
    case emptyStoredContacts
    case emptyLifeboxContacts
    case noBackUp
    case syncError(Error)
}

private class ContactSyncHelper {
    
    private weak var delegate: ContactSyncHelperDelegate?
    
    private let localContactsService = ContactService()
    private let contactSyncService = ContactsSyncService()
    private let analyticsHelper = Analytics()
    private let accountService = AccountService()
    
    private (set) var syncResponse: ContactSync.SyncResponse?
    
    
    required init(delegate: ContactSyncHelperDelegate) {
        self.delegate = delegate
    }
    
    func prepare() {
        guard !ContactSyncSDK.isRunning() else {
            if AnalyzeStatus.shared().analyzeStep == AnalyzeStep.ANALYZE_STEP_INITAL {
                performOperation(forType: SyncSettings.shared().mode)
            } else if AnalyzeStatus.shared().analyzeStep != AnalyzeStep.ANALYZE_STEP_PROCESS_DUPLICATES {
                startOperation(operationType: .getBackUpStatus)
            }
            return
        }
        
        proccessOperation(.getBackUpStatus)
    }
    
    private func startOperation(operationType: SyncOperationType) {
        guard operationType != .analyze else {
            userHasPermissionFor(type: .deleteDublicate) { [weak self] hasPermission in
                guard hasPermission else {
                    self?.delegate?.didFailed(error: .notPremiumUser)
                    return
                }
                
                self?.requestAccess { [weak self] success in
                    guard success, let self = self else {
                        return
                    }
                    
                    if self.getStoredContactsCount() == 0 {
                        self.delegate?.didFailed(error: .emptyStoredContacts)
                    } else {
                        self.proccessOperation(.analyze)
                    }
                }
                
            }
            return
        }
        
        guard operationType != .getBackUpStatus else {
            proccessOperation(.getBackUpStatus)
            return
        }
        
        requestAccess { [weak self] success in
            guard success else {
                return
            }
            
            switch operationType {
                case .backup:
                    if self?.getStoredContactsCount() == 0 {
                        self?.delegate?.didFailed(error: .emptyStoredContacts)
                    } else {
                        self?.proccessOperation(operationType)
                    }
                
                case .restore:
                    if self?.syncResponse?.totalNumberOfContacts == 0  {
                        self?.delegate?.didFailed(error: .emptyLifeboxContacts)
                    } else {
                        self?.proccessOperation(operationType)
                    }
                
                default:
                    self?.proccessOperation(operationType)
            }
        }
    }
    
    private func getStoredContactsCount() -> Int {
        return localContactsService.getContactsCount() ?? 0
    }
    
    private func proccessOperation(_ operationType: SyncOperationType) {
        //            if !reachability.isReachable && operationType.isContained(in: [.backup, .restore, .analyze]) {
        //                router.goToConnectedToNetworkFailed()
        //                return
        //            }
        
        //TODO: show view related to operationType
        start(operationType: operationType)
    }
    
    private func requestAccess(completionHandler: @escaping ContactsPermissionCallback) {
        localContactsService.askPermissionForContactsFramework(redirectToSettings: true) { isGranted in
            AnalyticsPermissionNetmeraEvent.sendContactPermissionNetmeraEvents(isGranted)
            completionHandler(isGranted)
        }
    }
    
    private func updateAccessToken(complition: @escaping VoidHandler) {
        let auth: AuthorizationRepository = factory.resolve()
        //        output?.asyncOperationStarted()
        auth.refreshTokens { [weak self] _, accessToken, error  in
            if let accessToken = accessToken {
                let tokenStorage: TokenStorage = factory.resolve()
                tokenStorage.accessToken = accessToken
                self?.contactSyncService.updateAccessToken()
                complition()
            } else {
                let syncError: SyncOperationErrors = error?.isNetworkError == true ? .networkError : .failed
                self?.delegate?.didFailed(error: .syncError(syncError))
            }
        }
    }
    
    private func start(operationType: SyncOperationType) {
        updateAccessToken { [weak self] in
            guard let self = self else {
                return
            }
            switch operationType {
                case .backup:
                    //                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.ContactBackUpScreen())
                    //                self.analyticsService.track(event: .contactBackup)
                    //                self.analyticsService.logScreen(screen: .contactSyncBackUp)
                    //                self.analyticsService.trackDimentionsEveryClickGA(screen: .contactSyncBackUp)
                    //                self.analyticsService.trackCustomGAEvent(eventCategory: .functions,
                    //                                                         eventActions: .phonebook,
                    //                                                         eventLabel: .contact(.backup))
                    
                    self.contactSyncService.cancelAnalyze()
                    self.performOperation(forType: .backup)
//                case .restore:
//                    //                self.analyticsService.trackCustomGAEvent(eventCategory: .functions,
//                    //                                                         eventActions: .phonebook,
//                    //                                                         eventLabel: .contact(.restore))
//
//                    self.contactSyncService.cancelAnalyze()
//                    self.performOperation(forType: .restore)
                case .cancel:
                    self.contactSyncService.cancelAnalyze()
//                    self.output?.cancelSuccess()
                case .getBackUpStatus:
                    self.loadLastBackUp()
                
                case .analyze:
                    self.contactSyncService.cancelAnalyze()
                    self.checkAnalyze()
                
                default: break
//                case .deleteDuplicated:
//                    //                self.analyticsService.trackCustomGAEvent(eventCategory: .functions,
//                    //                                                         eventActions: .phonebook,
//                    //                                                         eventLabel: .contact(.deleteDuplicates))
//
//                    self.deleteDuplicated()
            }
            
            /// workaround of bug that asyncOperationStarted not working in loadLastBackUp
//            if operationType != .getBackUpStatus {
//                self.output?.asyncOperationFinished()
//            }
        }
    }
    
    func backup() {
        startOperation(operationType: .backup)
    }
    
    func analyze() {
        startOperation(operationType: .analyze)
    }
    
    private func checkAnalyze() {
//        output?.showProgress(progress: 0, count: 0, forOperation: .analyze)
        contactSyncService.analyze(progressCallback: { [weak self] progressPercentage, count, type in
//            DispatchQueue.main.async {
//                self?.output?.showProgress(progress: progressPercentage, count: count, forOperation: type)
//            }
        }, successCallback: { [weak self] response in
            debugLog("contactsSyncService.analyze successCallback")
            
            self?.delegate?.didAnalyze(contacts: response)
//            DispatchQueue.main.async {
//                self?.output?.analyzeSuccess(response: response)
//            }
        }, cancelCallback: nil,
           errorCallback: { [weak self] errorType, type in
            debugLog("contactsSyncService.analyze errorCallback")
            self?.delegate?.didFailed(error: .syncError(errorType))
        })
    }
    
    func cancelAnalyze() {
        startOperation(operationType: .cancel)
    }
    
    private func deleteDuplicated() {
        //
    }
    
    private func userHasPermissionFor(type: AuthorityType, completion: @escaping BoolHandler) {
        accountService.permissions { response in
            switch response {
                case .success(let result):
                    AuthoritySingleton.shared.refreshStatus(with: result)
                    completion(result.hasPermissionFor(type))
                
                case .failed(let error):
                    completion(false)
                    self.delegate?.didFailed(error: .syncError(error))
            }
        }
    }
    
    private func performOperation(forType type: SYNCMode) {
        UIApplication.setIdleTimerDisabled(true)
        
        //            analyticsHelper.trackOperation(type: type)
        
        // TODO: clear NumericConstants.limitContactsForBackUp
        contactSyncService.executeOperation(type: type, progress: { [weak self] progressPercentage, count, opertionType in
            //            DispatchQueue.main.async {
            //                self?.output?.showProgress(progress: progressPercentage, count: 0, forOperation: opertionType)
            //            }
            }, finishCallback: { [weak self] result, operationType in
                self?.analyticsHelper.trackOperationSuccess(type: type)
                
                UIApplication.setIdleTimerDisabled(false)
                debugLog("contactsSyncService.executeOperation finishCallback: \(result)")
                
                DispatchQueue.main.async {
                    //                self?.output?.success(response: result, forOperation: opertionType)
                    CardsManager.default.stopOperationWith(type: .contactBacupOld)
                    CardsManager.default.stopOperationWith(type: .contactBacupEmpty)
                }
            }, errorCallback: { [weak self] errorType, opertionType in
                self?.analyticsHelper.trackOperationFailure(type: type)
                
                debugLog("contactsSyncService.executeOperation errorCallback: \(errorType)")
                
                self?.delegate?.didFailed(error: .syncError(errorType))
                UIApplication.setIdleTimerDisabled(false)
        })
    }
    
    private func loadLastBackUp() {
        contactSyncService.getBackUpStatus(completion: { [weak self] model in
            debugLog("loadLastBackUp completion")
            self?.syncResponse = model
            self?.delegate?.didUpdateBackupStatus()
//            self?.output?.success(response: model, forOperation: .getBackUpStatus)
        }, fail: { [weak self] in
            debugLog("loadLastBackUp fail")
            self?.delegate?.didFailed(error: .noBackUp)
        })
    }
}
