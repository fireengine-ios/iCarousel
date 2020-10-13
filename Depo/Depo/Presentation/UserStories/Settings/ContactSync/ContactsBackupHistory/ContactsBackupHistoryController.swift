//
//  ContactsBuckupDetails.swift
//  Depo
//
//  Created by Maxim Soldatov on 6/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ContactsBackupHistoryController: BaseViewController {

    private lazy var contactHistoryView: ContactsBackupHistoryView = {
        let view = ContactsBackupHistoryView.initFromNib()
        view.delegate = self
        return view
    }()
    var progressView: ContactOperationProgressView?
    
    private lazy var dataManager = ContactBackupHistoryDataManager(tableView: contactHistoryView.tableView, delegate: self)
    private let router = RouterVC()
    private let animator = ContentViewAnimator()
    private let contactSyncHelper = ContactSyncHelper.shared
    private lazy var contactsSyncService = ContactSyncApiService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private var task: URLSessionTask?
    
    deinit {
        task?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackScreen()
        
        setNavigationTitle(title: TextConstants.contactBackupHistoryNavbarTitle)
        backButtonForNavigationItem(title: TextConstants.backTitle)
        
        showRelatedView()
        
        loadBackups(needShowSpinner: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        contactSyncHelper.delegate = self
        navigationBarWithGradientStyle()
    }
    
    private func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.BackupsScreen())
        analyticsService.logScreen(screen: .contactSyncBackupsScreen)
        analyticsService.trackDimentionsEveryClickGA(screen: .contactSyncBackupsScreen)
    }
    
    private func loadBackups(needShowSpinner: Bool) {
        if needShowSpinner {
            showSpinner()
        }
        
        task = contactsSyncService.getBackups { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.hideSpinner()
            
            switch result {
            case .success(let response):
                self.dataManager.setup(with: response.list)
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
}

extension ContactsBackupHistoryController: ContactBackupHistoryDataManagerDelegate {
    func showDetailsForBackupItem(item: ContactBackupItem) {
        let controller = router.contactList(backUpInfo: item, delegate: self)
        router.pushViewController(viewController: controller)
    }
}

//MARK: - ContactsBackupHistoryViewDelegate

extension ContactsBackupHistoryController: ContactsBackupHistoryViewDelegate {
    func restoreBackupTapped() {
        showPopup(type: .restoreBackup)
    }
    
    func deleteBackupTapped() {
        showPopup(type: .deleteBackup)
    }
}

//MARK: - ContactSyncHelperDelegate
//MARK: - ContactSyncControllerProtocol

extension ContactsBackupHistoryController: ContactSyncControllerProtocol, ContactSyncHelperDelegate {
    
    func show(view: UIView, animated: Bool) {
        animator.showTransition(to: view, on: self.view, animated: true)
    }
    
    func showRelatedView() {
        show(view: contactHistoryView, animated: true)
    }
    
    func didFinishOperation(operationType: ContactsOperationType) { }
}

//MARK: - ContactListViewDelegate

extension ContactsBackupHistoryController: ContactListViewDelegate {

    func didCreateNewBackup(_ backup: ContactSync.SyncResponse) {
        loadBackups(needShowSpinner: false)
    }
    
    func didDeleteContacts(for backup: ContactSync.SyncResponse) {
        loadBackups(needShowSpinner: false)
    }
}
