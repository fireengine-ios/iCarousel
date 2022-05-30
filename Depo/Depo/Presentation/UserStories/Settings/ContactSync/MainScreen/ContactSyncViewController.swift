//
//  ContactSyncViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 19.05.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit
import Contacts
import MBProgressHUD


protocol ContactsBackupActionProviderProtocol: AnyObject {
    func backUp(isConfirmed: Bool)
}

protocol ContactSyncControllerProtocol: ViewController {
    var progressView: ContactOperationProgressView? { get set }
    var selectedBackupForRestore: ContactBackupItem? { get }
    func show(view: UIView, animated: Bool)
    func showRelatedView()
    func showResultView(view: UIView, title: String)
    func didFinishOperation(operationType: ContactsOperationType)
}

extension ContactSyncControllerProtocol {
    var selectedBackupForRestore: ContactBackupItem? { nil }
}

final class ContactSyncViewController: BaseViewController, NibInit, HeaderContainingViewControllerChild {
    
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
    
    var progressView: ContactOperationProgressView?
    
    private let syncService = ContactsSyncService()
    private let periodicSyncHelper = PeriodicSync()
    private var animator = ContentViewAnimator()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private let contactSyncHelper = ContactSyncHelper.shared
    
    private var syncModel: ContactBackupItem? {
        return contactSyncHelper.lastBackup
    }
    
    private lazy var router = RouterVC()
    
    //MARK:- Override
    
    deinit {
        syncService.cancelAnalyze()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackScreen()
        floatingButtonsArray = [.takePhoto, .upload, .createAStory, .newFolder]

        if tabBarIsVisible {
            needToShowTabBar = true
        }

        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateBackupStatus()
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
    
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.ContactsSyncScreen())
        analyticsService.logScreen(screen: .contactSyncGeneral)
        analyticsService.trackDimentionsEveryClickGA(screen: .contactSyncGeneral)
    }
    
    //MARK: - Public
    
    func setTabBar(isVisible: Bool) {
        tabBarIsVisible = isVisible
    }
    
    
    //MARK:- Private
    
    private func setupNavBar() {
        setTitle(withString: TextConstants.backUpMyContacts)
    }
    
    private func updateBackupStatus() {
        if contactSyncHelper.prepare() {
            showSpinner()
        }
    }
    
    func showRelatedView() {
        guard !contactSyncHelper.isRunning || AnalyzeStatus.shared().analyzeStep == .ANALYZE_STEP_PROCESS_DUPLICATES else {
            return
        }
        
        guard let model = syncModel, model.total != 0 else {
            show(view: noBackupView, animated: true)
            return
        }
        
        mainView.update(with: model, periodicSyncOption: periodicSyncHelper.settings.timeSetting.option)
        show(view: mainView, animated: true)
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
            startBackup()
        } else {
            showPopup(type: .backup)
        }
    }
}

extension ContactSyncViewController: ContactSyncMainViewDelegate {
    
    func showContacts() {
        guard let info = contactSyncHelper.lastBackup else {
            return
        }
        
        let contactList = router.contactList(backUpInfo: info, delegate: nil)
        router.pushViewController(viewController: contactList)
    }
    
    func showBackups() {
        let backupList = router.backupHistory()
        router.pushViewController(viewController: backupList)
    }
    
    func deleteDuplicates() {
        showSpinner()
        
        progressView?.reset()
        contactSyncHelper.analyze { }
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
    
    func didFinishOperation(operationType: ContactsOperationType) {
        switch operationType {
        case .backUp(_):
            updateBackupStatus()
            fallthrough
        default:
            showRelatedView()
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
   
    func didUpdateBackupList() {
        hideSpinner()
        showRelatedView()
    }
}

//MARK: - ContactSyncControllerProtocol

extension ContactSyncViewController: ContactSyncControllerProtocol {
    
    func show(view: UIView, animated: Bool) {
        animator.showTransition(to: view, on: contentView, animated: true)
    }
    
    private func noDuplicatesPopup() {
        SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.errorAlertTextNoDuplicatedContacts)
    }
    
    func showResultView(view: UIView, title: String) {
        let controller = router.contactSyncResultController(with: view, navBarTitle: title)
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - Private classes - helpers

final class ContentViewAnimator {
    
    func showTransition(to newView: UIView, on contentView: UIView, animated: Bool) {
        let currentView = contentView.subviews.first { subView in
            subView is MBProgressHUD == false
        }
        
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
