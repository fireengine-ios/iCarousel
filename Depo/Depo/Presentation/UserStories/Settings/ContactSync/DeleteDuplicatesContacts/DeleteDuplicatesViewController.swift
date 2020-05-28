//
//  DeleteDuplicatesViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 5/25/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol DeleteDuplicatesDelegate: class {
    func startBackUp()
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
    
    private var contacts = [ContactSync.AnalyzedContact]()
    private weak var delegate: DeleteDuplicatesDelegate?
    private var resultView: ContactsOperationView?
    
    // MARK: -
    
    static func with(contacts: [ContactSync.AnalyzedContact], delegate: DeleteDuplicatesDelegate?) -> DeleteDuplicatesViewController {
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
        hideSpinner()
        showResultView(result: .success)
        
        let backUpCard = BackUpContactsCard.initFromNib()
        resultView?.add(card: backUpCard)
        
        backUpCard.backUpHandler = { [weak self] in
            self?.showBackUpPop()
        }
    }
    
    private func deleteDuplicatesFailed(error: SyncOperationErrors) {
        hideSpinner()
        showResultView(result: .failed)
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
    
    private func showBackUpPop() {
        let vc = PopUpController.with(title: TextConstants.backUpContactsConfirmTitle,
                                      message: TextConstants.backUpContactsConfirmMessage,
                                      image: .question,
                                      firstButtonTitle: TextConstants.cancel,
                                      secondButtonTitle: TextConstants.ok,
                                      secondAction: { [weak self] vc in
                                        self?.delegate?.startBackUp()
                                        vc.close(isFinalStep: false) {
                                            self?.navigationController?.popViewController(animated: true)
                                        }
                                    })
        present(vc, animated: false)
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
//                TODO: view.showPremiumPopup()
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
        contactsSyncService.analyze(progressCallback: { [weak self] progress, count, type in
            if type == .deleteDuplicated, progress == 0 {
                self?.deleteDuplicatesSuccess()
            }
        }, successCallback: nil,
           cancelCallback: nil,
        errorCallback: { [weak self] error, type in
            if type == .deleteDuplicated {
                self?.deleteDuplicatesFailed(error: error)
            }
        })
        contactsSyncService.deleteDuplicates()
    }
    
    func userHasPermissionFor(type: AuthorityType, completion: @escaping BoolHandler) {
        accountService.permissions { response in
            switch response {
            case .success(let result):
                AuthoritySingleton.shared.refreshStatus(with: result)
                completion(result.hasPermissionFor(type))
                
            case .failed(let error):
                completion(false)
                //TODO: handle error
//                    self?.output?.didObtainFailUserStatus(errorMessage: error.description)
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
            } else {
//                self?.output?.showError(errorType: error?.isNetworkError == true ? .networkError : .failed)
            }
        }
    }
}
