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
    func backUp(isConfirmed: Bool)
}

protocol ContactSyncControllerProtocol: ViewController {
    func showPopup(type: ContactSyncPopupType)
    func handle(error: ContactSyncHelperError, operationType: SyncOperationType)
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
    
    private lazy var backupProgressView = ContactSyncProgressView.setup(type: .backup)
    
    private lazy var analyzeProgressView: ContactSyncAnalyzeProgressView = {
        let view = ContactSyncAnalyzeProgressView.initFromNib()
        view.delegate = self
        return view
    }()
    
    
    private let syncService = ContactsSyncService()
    private let periodicSyncHelper = PeriodicSync()
    private var animator = ContentViewAnimator()
    private let analyticsHelper = Analytics()
    private let contactSyncHelper = ContactSyncHelper.shared
    
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
        contactSyncHelper.delegate = self
        updateBackupStatus()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        showRelatedView()
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
        if contactSyncHelper.prepare() {
            showSpinner()
        }
    }
    
    private func showRelatedView() {
        guard !contactSyncHelper.isRunning else {
            return
        }
        
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

extension ContactSyncViewController: ContactSyncAnalyzeProgressViewDelegate {
    func cancelAnalyze() {
        contactSyncHelper.cancelAnalyze()
    }
}

extension ContactSyncViewController: ContactsBackupActionProviderProtocol {
    func backUp(isConfirmed: Bool) {
        if isConfirmed {
            startBackUp()
        } else {
            showPopup(type: .backup)
        }
    }
    
    private func startBackUp() {
        analyzeProgressView.reset()
        backupProgressView.reset()
        
        showSpinner()
        contactSyncHelper.backup { [weak self] in
            guard let self = self else {
                return
            }
            
            self.analyticsHelper.trackBackupScreen()
            self.hideSpinner()
        }
    }
}

extension ContactSyncViewController: ContactSyncMainViewDelegate {
    
    func showContacts() {
        guard let info = contactSyncHelper.syncResponse else {
            return
        }
        
        let contactList = router.contactList(backUpInfo: info)
        router.pushViewController(viewController: contactList)
    }
    
    func showBackups() {
        guard let info = contactSyncHelper.syncResponse else {
            return
        }
        
        let backupList = router.backupHistory(backUpInfo: info)
        router.pushViewController(viewController: backupList)
    }
    
    func deleteDuplicates() {
        showSpinner()
        
        analyzeProgressView.reset()
        contactSyncHelper.analyze { [weak self] in
            self?.hideSpinner()
        }
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
    
    func didBackup(result: ContactSync.SyncResponse) {
        hideSpinner()
        updateBackupStatus()
        
        DispatchQueue.main.async {
            self.showRelatedView()
            
            let controller = self.router.contactSyncSuccessController(syncResult: result, periodicSync: self.periodicSyncHelper)
            
            self.navigationController?.pushViewController(controller, animated: true)
            
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
            let controller = router.deleteContactDuplicates(analyzeResponse: contacts)
            router.pushViewController(viewController: controller)
        }
    }
    
    func didDeleteDuplicates() { }
   
    func didUpdateBackupStatus() {
        hideSpinner()
        showRelatedView()
    }
    
    func progress(progress: Int, for operationType: SyncOperationType) {
        switch operationType {
            case .backup:
                show(view: backupProgressView, animated: true)
                backupProgressView.update(progress: progress)
            case .analyze:
                show(view: analyzeProgressView, animated: true)
                analyzeProgressView.update(progress: progress)
            default:
                showRelatedView()
        }
    }
}

//MARK: - ContactSyncControllerProtocol

extension ContactSyncViewController: ContactSyncControllerProtocol {
    
    func handle(error: ContactSyncHelperError, operationType: SyncOperationType) {
        switch error {
        case .noBackUp:
            showRelatedView()
        default:
            break
        }
    }
    
    func showPopup(type: ContactSyncPopupType) {
        let handler: VoidHandler = { [weak self] in
            guard let self = self else {
                return
            }
            
            switch type {
            case .backup:
                self.startBackUp()
            case .premium:
                let controller = self.router.premium(source: .contactSync)
                self.router.pushViewController(viewController: controller)
            default:
                break
            }
        }

        let popup = ContactSyncPopupFactory.createPopup(type: type) { vc in
            vc.close(isFinalStep: false, completion: handler)
        }
        
        present(popup, animated: true)
    }
    
    private func noDuplicatesPopup() {
        SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.errorAlertTextNoDuplicatedContacts)
    }
}


//MARK: - Private classes - helpers

final class ContentViewAnimator {
    
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

final class PeriodicSync {
    
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
    
    func trackBackupScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.ContactsSyncScreen())
        analyticsService.logScreen(screen: .contactSyncBackUp)
        analyticsService.trackDimentionsEveryClickGA(screen: .contactSyncBackUp)
    }
    
    func trackOperation(type: SyncOperationType) {
        switch type {
            case .backup:
                analyticsService.track(event: .contactBackup)
                analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                    eventActions: .phonebook,
                                                    eventLabel: .contact(.backup))
            case .restore:
                analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                    eventActions: .phonebook,
                                                    eventLabel: .contact(.restore))
            
            default: break
        }
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
