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
    
    private lazy var progressView: ContactSyncProgressView = {
        let view = ContactSyncProgressView.initFromNib()
//        view.delegate = self
        return view
    }()
    
    
    private let syncService = ContactsSyncService()
    private let periodicSyncHelper = PeriodicSync()
    private var animator = ContentViewAnimator()
    private let analyticsHelper = Analytics()
    private lazy var contactSyncHelper: ContactSyncHelper = {
        return ContactSyncHelper(delegate: self)
    }()
    
    private var syncModel: ContactSync.SyncResponse? {
        return contactSyncHelper.syncResponse
    }
    
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
        updateBackupStatus()
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
    
    private func updateBackupStatus() {
        showSpinner()
        contactSyncHelper.prepare()
    }
    
    private func showRelatedView() {
        guard let model = syncModel, model.totalNumberOfContacts != 0 else {
            self.show(view: self.noBackupView, animated: true)
            return
        }
        
        self.mainView.update(with: model, periodicSyncOption: periodicSyncHelper.settings.timeSetting.option)
        self.show(view: self.mainView, animated: true)
    }
    
    private func show(view: UIView, animated: Bool) {
        animator.showTransition(to: view, on: contentView, animated: true)
    }

}


//MARK:- protocols extensions

extension ContactSyncViewController: ContactsBackupActionProviderProtocol {
    func backUp() {
        showSpinner()
        contactSyncHelper.backup { [weak self] in
            guard let self = self else {
                return
            }
            
            self.hideSpinner()
            
            self.progressView.reset()
            self.show(view: self.progressView, animated: true)
        }
    }
}

extension ContactSyncViewController: ContactSyncMainViewDelegate {
    
    func showBackups() {
        //TODO: Open backups screen
        showSpinner()
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
    func didCancelAnalyze() {
        hideSpinner()
        showRelatedView()
    }
    
    func didRestore() {
        hideSpinner()
        showRelatedView()
        
        DispatchQueue.main.async {
            CardsManager.default.stopOperationWith(type: .contactBacupOld)
            CardsManager.default.stopOperationWith(type: .contactBacupEmpty)
        }
    }
    
    func didBackup() {
        hideSpinner()
        showRelatedView()
        
        DispatchQueue.main.async {
            CardsManager.default.stopOperationWith(type: .contactBacupOld)
            CardsManager.default.stopOperationWith(type: .contactBacupEmpty)
        }
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
        hideSpinner()
        showRelatedView()
    }
    
    func didFailed(error: ContactSyncHelperError) {
        DispatchQueue.main.async {
            self.hideSpinner()
            self.handleError(error)
        }
    }
    
    func progress(progress: Int, for operationType: SYNCMode) {
        if operationType == .backup {
             progressView.update(progress: progress)
        }
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
    func didRestore()
    func didCancelAnalyze()
    func didFailed(error: ContactSyncHelperError)
    func progress(progress: Int, for operationType: SYNCMode)
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
    private let reachability = ReachabilityService.shared
    private let auth: AuthorizationRepository = factory.resolve()
    let tokenStorage: TokenStorage = factory.resolve()
    
    private (set) var syncResponse: ContactSync.SyncResponse?
    
    
    required init(delegate: ContactSyncHelperDelegate) {
        self.delegate = delegate
    }
    
    
    //MARK: - Public
    
    func prepare() {
        //TODO: check logic, maybe just cancel and call .getBackUpStatus
        guard !ContactSyncSDK.isRunning() else {
            if AnalyzeStatus.shared().analyzeStep == AnalyzeStep.ANALYZE_STEP_INITAL {
                performOperation(forType: SyncSettings.shared().mode)
            } else if AnalyzeStatus.shared().analyzeStep != AnalyzeStep.ANALYZE_STEP_PROCESS_DUPLICATES {
                proccessOperation(.getBackUpStatus)
            }
            return
        }
        
        proccessOperation(.getBackUpStatus)
    }
    
    func backup(onStart: @escaping VoidHandler) {
        startOperation(operationType: .backup, onStart: onStart)
    }
    
    func analyze() {
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
    }
    
    func cancelAnalyze() {
        start(operationType: .cancel)
    }
    
    //MARK: - Private
    
    private func startOperation(operationType: SyncOperationType, onStart: @escaping VoidHandler) {
        requestAccess { [weak self] success in
            guard success else {
                return
            }
            
            switch operationType {
                case .backup:
                    if self?.getStoredContactsCount() == 0 {
                        self?.delegate?.didFailed(error: .emptyStoredContacts)
                    } else {
                        onStart()
                        self?.proccessOperation(operationType)
                    }
                
                case .restore:
                    if self?.syncResponse?.totalNumberOfContacts == 0  {
                        self?.delegate?.didFailed(error: .emptyLifeboxContacts)
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
//            TODO: router.goToConnectedToNetworkFailed()
            return
        }
        
        //TODO: show view related to operationType
        start(operationType: operationType)
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
        }
    }
    
    private func checkAnalyze() {
        contactSyncService.analyze(progressCallback: { [weak self] progressPercentage, count, type in
//            self?.delegate?.progress(progress: progressPercentage, for: .analyze)
            
        }, successCallback: { [weak self] response in
            debugLog("contactsSyncService.analyze successCallback")
            
            self?.delegate?.didAnalyze(contacts: response)
            
        }, cancelCallback: nil,
           errorCallback: { [weak self] errorType, type in
            debugLog("contactsSyncService.analyze errorCallback")
            self?.delegate?.didFailed(error: .syncError(errorType))
        })
    }
    
    private func loadLastBackUp() {
           contactSyncService.getBackUpStatus(completion: { [weak self] model in
               debugLog("loadLastBackUp completion")
               self?.syncResponse = model
               self?.delegate?.didUpdateBackupStatus()
               
           }, fail: { [weak self] in
               debugLog("loadLastBackUp fail")
               self?.syncResponse = nil
               self?.delegate?.didUpdateBackupStatus()
           })
       }
    
    private func performOperation(forType type: SYNCMode) {
        UIApplication.setIdleTimerDisabled(true)
        
        //            analyticsHelper.trackOperation(type: type)
        
        // TODO: clear NumericConstants.limitContactsForBackUp
        contactSyncService.executeOperation(type: type, progress: { [weak self] progressPercentage, count, opertionType in
            self?.delegate?.progress(progress: progressPercentage, for: type)
            
            }, finishCallback: { [weak self] result, operationType in
                self?.analyticsHelper.trackOperationSuccess(type: type)
                
                UIApplication.setIdleTimerDisabled(false)
                debugLog("contactsSyncService.executeOperation finishCallback: \(result)")
                
                (type == .backup) ? self?.delegate?.didBackup() :  self?.delegate?.didRestore()
                
            }, errorCallback: { [weak self] errorType, opertionType in
                self?.analyticsHelper.trackOperationFailure(type: type)
                
                debugLog("contactsSyncService.executeOperation errorCallback: \(errorType)")
                
                UIApplication.setIdleTimerDisabled(false)
                //TODO: show error
        })
    }
    
    
    //MARK:- Tokens + Contacts Access + Persmissions
    
    private func userHasPermissionFor(type: AuthorityType, completion: @escaping BoolHandler) {
        accountService.permissions { response in
            switch response {
                case .success(let result):
                    AuthoritySingleton.shared.refreshStatus(with: result)
                    completion(result.hasPermissionFor(type))
                
                case .failed(let error):
                    completion(false)
                //TODO: handle error
            }
        }
    }
    
    private func requestAccess(completionHandler: @escaping ContactsPermissionCallback) {
        localContactsService.askPermissionForContactsFramework(redirectToSettings: true) { isGranted in
            AnalyticsPermissionNetmeraEvent.sendContactPermissionNetmeraEvents(isGranted)
            completionHandler(isGranted)
        }
    }
    
    private func updateAccessToken(complition: @escaping VoidHandler) {
        auth.refreshTokens { [weak self] _, accessToken, error  in
            guard let accessToken = accessToken else {
                let syncError: SyncOperationErrors = error?.isNetworkError == true ? .networkError : .failed
                self?.delegate?.didFailed(error: .syncError(syncError))
                return
            }
            
            self?.tokenStorage.accessToken = accessToken
            self?.contactSyncService.updateAccessToken()
            complition()
        }
    }
}
