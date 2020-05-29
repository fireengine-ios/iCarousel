//
//  DeleteDuplicatesViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 5/25/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

private enum DeleteDuplicatesError {
    case notPremiumUser
    case deleteDuplicatesFailed
    case syncError(Error)
}

final class DeleteDuplicatesViewController: BaseViewController, NibInit {
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var deleteAllButton: NavyButtonWithWhiteText! {
        willSet {
            newValue.setTitle(TextConstants.deleteDuplicatesDeleteAll, for: .normal)
        }
    }
    
    private let contactsSyncService = ContactsSyncService()
    private let localContactsService = ContactService()
    private let accountService = AccountService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    private var contacts = [ContactSync.AnalyzedContact]()
    private weak var delegate: ContactsBackupActionProviderProtocol?
    private var resultView: ContactsOperationView?
    
    private lazy var router = RouterVC()
    
    // MARK: -
    
    static func with(contacts: [ContactSync.AnalyzedContact], delegate: ContactsBackupActionProviderProtocol?) -> DeleteDuplicatesViewController {
        let controller = DeleteDuplicatesViewController.initFromNib()
        controller.contacts = contacts
        controller.delegate = delegate
        return controller
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        if contactsSyncService.getCurrentOperationType() != .backup {
            contactsSyncService.cancelAnalyze()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if tableView.tableHeaderView == nil {
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
        showDeletePopup()
    }
    
    private func deleteDuplicates() {
        showSpinner()
        startDeleteDuplicates()
    }
    
    private func deleteDuplicatesSuccess() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Contact(actionType: .deleteDuplicate, status: .success))
        
        hideSpinner()
        showResultView(result: .success)
        
        let backUpCard = BackUpContactsCard.initFromNib()
        resultView?.add(card: backUpCard)
        
        backUpCard.backUpHandler = { [weak self] in
            self?.showBackUpPopup()
        }
    }
    
    private func deleteDuplicatesFailure() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Contact(actionType: .deleteDuplicate, status: .failure))
        handleError(.deleteDuplicatesFailed)
    }
    
    private func showResultView(result: ContactsOperationResult) {
        deleteResultView()
        
        resultView = ContactsOperationView.with(type: .deleteDuplicates, result: result)
        resultView?.frame = view.bounds
        resultView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(resultView!)
    }
    
    private func deleteResultView() {
        resultView?.removeFromSuperview()
        resultView = nil
    }
    
    private func handleError(_ error: DeleteDuplicatesError) {
        hideSpinner()
        
        switch error {
        case .notPremiumUser:
            break
            
        case .deleteDuplicatesFailed:
            showResultView(result: .failed)
            
        case .syncError(let error):
            UIApplication.showErrorAlert(message: error.description)
        }
    }
    
    private func showDeletePopup() {
        let vc = PopUpController.with(title: TextConstants.deleteDuplicatesConfirmTitle,
                                      message: TextConstants.deleteDuplicatesConfirmMessage,
                                      image: .question,
                                      firstButtonTitle: TextConstants.cancel,
                                      secondButtonTitle: TextConstants.ok,
                                      secondAction: { [weak self] vc in
                                        vc.close()
                                        self?.deleteDuplicates()
                                    })
        present(vc, animated: false)
    }
    
    private func showBackUpPopup() {
        let vc = PopUpController.with(title: TextConstants.backUpContactsConfirmTitle,
                                      message: TextConstants.backUpContactsConfirmMessage,
                                      image: .question,
                                      firstButtonTitle: TextConstants.cancel,
                                      secondButtonTitle: TextConstants.ok,
                                      secondAction: { [weak self] vc in
                                        self?.delegate?.backUp(isConfirmed: true)
                                        vc.close(isFinalStep: false) {
                                            self?.navigationController?.popViewController(animated: true)
                                        }
                                    })
        present(vc, animated: false)
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

private extension DeleteDuplicatesViewController {
    
    func startDeleteDuplicates() {
        userHasPermissionFor(type: .deleteDublicate) { [weak self] hasPermission in
            guard hasPermission else {
                self?.handleError(.notPremiumUser)
                return
            }
            
            self?.requestAccess { [weak self] success in
                guard success, let self = self else {
                    return
                }
                
                self.continueDeleteDuplicates()
            }
        }
    }
    
    func continueDeleteDuplicates() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                            eventActions: .phonebook,
                                            eventLabel: .contact(.deleteDuplicates))
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.DeleteDuplicateScreen())
        
        contactsSyncService.analyze(progressCallback: { [weak self] progress, count, type in
            if type == .deleteDuplicated, progress == 0 {
                self?.deleteDuplicatesSuccess()
            }
        }, successCallback: nil,
           cancelCallback: nil,
        errorCallback: { [weak self] _, type in
            if type == .deleteDuplicated {
                self?.deleteDuplicatesFailure()
            }
        })
        contactsSyncService.deleteDuplicates()
    }
    
    func userHasPermissionFor(type: AuthorityType, completion: @escaping BoolHandler) {
        accountService.permissions { [weak self] response in
            switch response {
            case .success(let result):
                AuthoritySingleton.shared.refreshStatus(with: result)
                completion(result.hasPermissionFor(type))
                
            case .failed(let error):
                completion(false)
                self?.handleError(.syncError(error))
            }
        }
    }
    
    func requestAccess(completionHandler: @escaping ContactsPermissionCallback) {
        localContactsService.askPermissionForContactsFramework(redirectToSettings: true) { isGranted in
            AnalyticsPermissionNetmeraEvent.sendContactPermissionNetmeraEvents(isGranted)
            completionHandler(isGranted)
        }
    }
    
    func updateAccessToken(complition: @escaping VoidHandler) {
        let auth: AuthorizationRepository = factory.resolve()
        auth.refreshTokens { [weak self] _, accessToken, error  in
            if let accessToken = accessToken {
                let tokenStorage: TokenStorage = factory.resolve()
                tokenStorage.accessToken = accessToken
                self?.contactsSyncService.updateAccessToken()
                complition()
            } else if error?.isNetworkError == true {
                self?.handleError(.syncError(SyncOperationErrors.networkError))
            } else {
                self?.handleError(.syncError(SyncOperationErrors.failed))
            }
        }
    }
}
