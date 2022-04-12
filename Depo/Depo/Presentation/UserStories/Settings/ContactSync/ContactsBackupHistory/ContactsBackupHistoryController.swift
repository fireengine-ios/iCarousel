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
        
        reloadBackups()
        showRelatedView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        contactSyncHelper.delegate = self
        navigationBarWithGradientStyle()
    }
    
    private func reloadBackups() {
        dataManager.setup(with: contactSyncHelper.backups)
    }
    
    private func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.BackupsScreen())
        analyticsService.logScreen(screen: .contactSyncBackupsScreen)
        analyticsService.trackDimentionsEveryClickGA(screen: .contactSyncBackupsScreen)
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
        showPopup(type: .restoreBackup, backup: dataManager.selectedBackup)
    }
    
    func deleteBackupTapped() {
        showPopup(type: .deleteBackup, backup: dataManager.selectedBackup)
    }
}

//MARK: - ContactSyncHelperDelegate
//MARK: - ContactSyncControllerProtocol

extension ContactsBackupHistoryController: ContactSyncControllerProtocol, ContactSyncHelperDelegate {

    var selectedBackupForRestore: ContactBackupItem? {
        return dataManager.selectedBackup
    }

    func show(view: UIView, animated: Bool) {
        animator.showTransition(to: view, on: self.view, animated: true)
    }
    
    func showRelatedView() {
        show(view: contactHistoryView, animated: true)
    }
    
    func didFinishOperation(operationType: ContactsOperationType) { }
    
    func didUpdateBackupList() {
        reloadBackups()
    }
}

//MARK: - ContactListViewDelegate

extension ContactsBackupHistoryController: ContactListViewDelegate {

    func didCreateNewBackup(_ backup: ContactSync.SyncResponse) { }
    
    func didDeleteContacts(for backup: ContactSync.SyncResponse) { }
}
