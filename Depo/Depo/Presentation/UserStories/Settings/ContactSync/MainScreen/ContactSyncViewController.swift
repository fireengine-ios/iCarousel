//
//  ContactSyncViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 19.05.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit


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
    
    private var syncModel: ContactSync.SyncResponse?
    
    
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
        showSpinner()
        getBackupStatus { [weak self] in
            guard let self = self else {
                return
            }
            self.hideSpinner()
            self.showRelatedView()
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
        syncService.getBackUpStatus(completion: { [weak self] model in
            debugLog("loadLastBackUp completion")
            
            guard let self = self else {
                return
            }
            
            self.syncModel = model
            completion()
            
        }, fail: { [weak self] in
            debugLog("loadLastBackUp fail")
            
            guard let self = self else {
                return
            }
            
            //TODO: show error?
            self.syncModel = nil
            completion()
        })
    }
    
    private func show(view: UIView, animated: Bool) {
        animator.showTransition(to: view, on: contentView, animated: true)
    }

}


//MARK:- protocols extensions

extension ContactSyncViewController: ContactsBackupActionProviderProtocol {
    func backUp() {
        //TODO: BackUp
        showRelatedView()
    }
}

extension ContactSyncViewController: ContactSyncMainViewDelegate {
    
    func showBackups() {
        //TODO: Open backups screen
        showRelatedView()
    }
    
    func deleteDuplicates() {
        //TODO: Open delete duplicates screen
        showRelatedView()
    }
    
    func changePeriodicSync(to option: PeriodicContactsSyncOption) {
        periodicSyncHelper.save(option: option)
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
