//
//  DeleteDuplicatesViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 5/25/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class DeleteDuplicatesViewController: BaseViewController, NibInit {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var contentView: UIView!
    
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var deleteAllButton: NavyButtonWithWhiteText! {
        willSet {
            newValue.setTitle(TextConstants.deleteDuplicatesDeleteAll, for: .normal)
        }
    }
    
    private lazy var deleteProgressView = ContactSyncProgressView.setup(type: .deleteDuplicates)
    private lazy var backupProgressView = ContactSyncProgressView.setup(type: .backup)
    private var resultView: ContactsOperationView?
    
    private let contactSyncHelper = ContactSyncHelper.shared
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var animator = ContentViewAnimator()
    
    private var contacts = [ContactSync.AnalyzedContact]()
    
    private lazy var router = RouterVC()
    
    // MARK: -
    
    static func with(contacts: [ContactSync.AnalyzedContact]) -> DeleteDuplicatesViewController {
        let controller = DeleteDuplicatesViewController.initFromNib()
        controller.contacts = contacts
        return controller
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactSyncHelper.delegate = self
        
        backButtonForNavigationItem(title: TextConstants.backTitle)
        setTitle(withString: TextConstants.deleteDuplicatesTitle)
        
        setupTableView()
        
        analyticsService.logScreen(screen: .contacSyncDeleteDuplicates)
        analyticsService.trackDimentionsEveryClickGA(screen: .contacSyncDeleteDuplicates)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        contactSyncHelper.cancelAnalyze()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let tableView = tableView, tableView.tableHeaderView == nil {
            setupHeader()
        }
    }
    
    private func setupTableView() {
        tableView.register(nibCell: DeleteDuplicatesCell.self)
        tableView.dataSource = self

        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.contentInset.bottom = bottomView.bounds.height
    }
    
    private func setupHeader() {
        let numberOfAllDuplicatedContacts = contacts.reduce(0) { $0 + $1.numberOfErrors }

        let header = DeleteDuplicatesHeader.initFromNib()
        header.setup(with: numberOfAllDuplicatedContacts)
        tableView.tableHeaderView = header
    }
    
    // MARK: - Actions
    
    @IBAction private func onDeleteAllTapped(_ sender: Any) {
        showPopup(type: .deleteDuplicates)
    }
    
    private func showResultView(type: ContactsOperationType, result: ContactsOperationResult) {
        resultView = ContactsOperationView.with(type: type, result: result)
                
        if result == .success {
            switch type {
            case .deleteDuplicates:
                let backUpCard = BackUpContactsCard.initFromNib()
                resultView?.add(card: backUpCard)
                
                backUpCard.backUpHandler = { [weak self] in
                    self?.showPopup(type: .backup)
                }
            default:
                break
            }
        }
        
        show(view: resultView!, animated: true)
    }
    
    private func show(view: UIView, animated: Bool) {
        contentView.isUserInteractionEnabled = true
        animator.showTransition(to: view, on: contentView, animated: animated)
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

    private func deleteDuplicates() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                            eventActions: .phonebook,
                                            eventLabel: .contact(.deleteDuplicates))

        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.DeleteDuplicateScreen())
        
        deleteProgressView.reset()
        showSpinner()
        contactSyncHelper.deleteDuplicates { [weak self] in
            self?.hideSpinner()
        }
    }
}

// MARK: - UITableViewDataSource

extension DeleteDuplicatesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusable: DeleteDuplicatesCell.self, for: indexPath)
        cell.configure(with: contacts[indexPath.row])
        
        return cell
    }
}

//MARK: - ContactSyncHelperDelegate

extension DeleteDuplicatesViewController: ContactSyncHelperDelegate {
    
    func didBackup(result: ContactSync.SyncResponse) {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Contact(actionType: .backup, status: .success))
        
        showResultView(type: .backUp(result), result: .success)
    }
    
    func didDeleteDuplicates() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Contact(actionType: .deleteDuplicate, status: .success))
        
        showResultView(type: .deleteDuplicates, result: .success)
    }
    
    func progress(progress: Int, for operationType: SyncOperationType) {
        switch operationType {
        case .backup:
            show(view: backupProgressView, animated: true)
            backupProgressView.update(progress: progress)
        case .deleteDuplicated:
            show(view: deleteProgressView, animated: true)
            deleteProgressView.update(progress: progress)
        default:
            break
        }
    }
}

extension DeleteDuplicatesViewController: ContactSyncControllerProtocol {
    
    func showPopup(type: ContactSyncPopupType) {
        let handler: VoidHandler = { [weak self] in
            guard let self = self else {
                return
            }
            
            switch type {
            case .backup:
                self.backup()
            case .deleteDuplicates:
                self.deleteDuplicates()
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
    
    func handle(error: ContactSyncHelperError, operationType: SyncOperationType) {
        switch error {
        case .syncError(_):
            switch operationType {
            case .backup:
                showResultView(type: .backUp(nil), result: .failed)
            case .deleteDuplicated:
                showResultView(type: .deleteDuplicates, result: .failed)
            default:
                break
            }
            
        default:
            break
        }
    }
}
