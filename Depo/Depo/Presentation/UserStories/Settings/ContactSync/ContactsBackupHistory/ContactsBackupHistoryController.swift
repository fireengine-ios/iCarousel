//
//  ContactsBuckupDetails.swift
//  Depo
//
//  Created by Maxim Soldatov on 6/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ContactsBackupHistoryController: BaseViewController {

    private let contactHistoryView = ContactsBackupHistoryView.initFromNib()
    private lazy var backupProgressView = ContactSyncProgressView.setup(type: .backup)
    private lazy var restoreProgressView = ContactSyncProgressView.setup(type: .restore)
    private var resultView: UIView?
    
    private var dataManager: ContuctBackupHistoryDataManagerProtocol?
    private let router = RouterVC()
    private let animator = ContentViewAnimator()
    private let contactSyncHelper = ContactSyncHelper.shared
    private lazy var contactsSyncService = ContactSyncApiService()
    
    override func loadView() {
        view = contactHistoryView
        contactHistoryView.delegate = self
    }
    
    init(with backup: ContactBuckupItem) {
        super.init(nibName: nil, bundle: nil)
        dataManager = ContuctBackupHistoryDataManager(tableView: contactHistoryView.tableView, delegate: self)
        dataManager?.appendItemsForPresent(items: [backup])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitle(title: TextConstants.contactBackupHistoryNavbarTitle)
        backButtonForNavigationItem(title: TextConstants.backTitle)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        contactSyncHelper.delegate = self
        navigationBarWithGradientStyle()
    }
    
    private func deleteBackup() {
        showSpinner()
        
        contactsSyncService.deleteAllContacts { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.hideSpinner()
            
            switch result {
            case .success(_):
                self.showResultView(type: .deleteBackUp, result: .success)
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
    
    private func restore() {
        showSpinner()
        
        restoreProgressView.reset()
        contactSyncHelper.restore { [weak self] in
            self?.hideSpinner()
        }
    }
    
    private func backup() {
        backupProgressView.reset()
        
        showSpinner()
        contactSyncHelper.backup { [weak self] in
            guard let self = self else {
                return
            }
            
//            self.analyticsHelper.trackBackupScreen()
            self.hideSpinner()
        }
    }

    
    private func show(view: UIView, animated: Bool) {
        animator.showTransition(to: view, on: self.view, animated: true)
    }
    
    private func showResultView(type: ContactsOperationType, result: ContactsOperationResult) {
        switch type {
        case .backUp(_):
            resultView = BackupContactsOperationView.with(type: type, result: result)
        default:
            let resultView = ContactsOperationView.with(type: type, result: result)
            
            if result == .success {
                switch type {
                case .deleteBackUp:
                    let backUpCard = BackUpContactsCard.initFromNib()
                    resultView.add(card: backUpCard)
                    
                    backUpCard.backUpHandler = { [weak self] in
                        self?.showPopup(type: .backup)
                    }
                default:
                    break
                }
            }
            
            self.resultView = resultView
        }

        show(view: resultView!, animated: true)
    }
}

extension ContactsBackupHistoryController: ContuctBackupHistoryDataManagerDelegate {
    func showDetailsForBuckupItem(item: ContactBuckupItem) {
        let controller = router.contactList(backUpInfo: item)
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

extension ContactsBackupHistoryController: ContactSyncHelperDelegate {
    func didRestore() {
        showResultView(type: .restore, result: .success)
    }
    
    func didBackup(result: ContactSync.SyncResponse) {
        showResultView(type: .backUp(result), result: .success)
    }
    
    func progress(progress: Int, for operationType: SyncOperationType) {
        switch operationType {
        case .backup:
            show(view: backupProgressView, animated: true)
            backupProgressView.update(progress: progress)
        case .restore:
            show(view: restoreProgressView, animated: true)
            restoreProgressView.update(progress: progress)
        default:
            break
        }
    }
}

//MARK: - ContactSyncControllerProtocol

extension ContactsBackupHistoryController: ContactSyncControllerProtocol {
    func showPopup(type: ContactSyncPopupType) {
        let handler: VoidHandler = { [weak self] in
            guard let self = self else {
                return
            }
            
            switch type {
            case .backup:
                self.backup()
            case .deleteBackup:
                self.deleteBackup()
            case .restoreBackup:
                self.restore()
            default:
                break
            }
        }

        let popup = ContactSyncPopupFactory.createPopup(type: type) { vc in
            vc.close(isFinalStep: false, completion: handler)
        }
        
        router.presentViewController(controller: popup)
    }
    
    func handle(error: ContactSyncHelperError, operationType: SyncOperationType) {
        switch error {
        case .syncError(_):
            switch operationType {
            case .restore:
                showResultView(type: .restore, result: .failed)
            default:
                break
            }
            
        default:
            break
        }
    }

}
