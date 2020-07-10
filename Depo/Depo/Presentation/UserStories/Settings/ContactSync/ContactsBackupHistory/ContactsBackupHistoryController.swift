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
    
    private var dataManager: ContactBackupHistoryDataManagerProtocol?
    private let router = RouterVC()
    private let animator = ContentViewAnimator()
    private let contactSyncHelper = ContactSyncHelper.shared
    private lazy var contactsSyncService = ContactSyncApiService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    init(with backup: ContactBackupItem) {
        super.init(nibName: nil, bundle: nil)
        dataManager = ContactBackupHistoryDataManager(tableView: contactHistoryView.tableView, delegate: self)
        dataManager?.appendItemsForPresent(items: [backup])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackScreen()
        
        setNavigationTitle(title: TextConstants.contactBackupHistoryNavbarTitle)
        backButtonForNavigationItem(title: TextConstants.backTitle)
        
        showRelatedView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        contactSyncHelper.delegate = self
        navigationBarWithGradientStyle()
    }
    
    private func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.ContactBackUpScreen())
        analyticsService.logScreen(screen: .contactSyncBackupsScreen)
        analyticsService.trackDimentionsEveryClickGA(screen: .contactSyncBackupsScreen)
    }
}

extension ContactsBackupHistoryController: ContactBackupHistoryDataManagerDelegate {
    func showDetailsForBuckupItem(item: ContactBackupItem) {
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
    
    func handle(error: ContactSyncHelperError, operationType: SyncOperationType) { }
    func didFinishOperation(operationType: ContactsOperationType) { }
}

//MARK: - ContactListViewDelegate

extension ContactsBackupHistoryController: ContactListViewDelegate {

    func didCreateNewBackup(_ backup: ContactSync.SyncResponse) {
        //TODO: - add new backup
    }
    
    func didDeleteContacts(for backup: ContactSync.SyncResponse) {
        //TODO: - remove backup from list
    }
}
