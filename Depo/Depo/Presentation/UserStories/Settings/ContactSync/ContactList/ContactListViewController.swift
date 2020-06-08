//
//  ContactListViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 5/29/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ContactListViewController: BaseViewController, NibInit {

    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var restoreButton: NavyButtonWithWhiteText! {
        willSet {
            newValue.setTitle(TextConstants.contactListRestore, for: .normal)
        }
    }
    
    private lazy var backupProgressView = ContactSyncProgressView.setup(type: .backup)
    private lazy var restoreProgressView = ContactSyncProgressView.setup(type: .restore)
    private var resultView: UIView?
    private var searchBar: UISearchBar? {
        (tableView.tableHeaderView as? ContactListHeader)?.searchBar
    }
    
    private lazy var dataSource = ContactListDataSource(tableView: tableView, delegate: self)
    private lazy var contactsSyncService = ContactSyncApiService()
    private let contactSyncHelper = ContactSyncHelper.shared
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var router = RouterVC()
    private let animator = ContentViewAnimator()
    
    private var backUpInfo: ContactSync.SyncResponse?
    
    private var currentPage = 1
    private var numberOfPages = Int.max
    private var lastQuery: String?
    
    private var isLoadingData = false
    private var currentTask: URLSessionTask?
    
    static func with(backUpInfo: ContactSync.SyncResponse) -> ContactListViewController {
        let controller = Self.initFromNib()
        controller.backUpInfo = backUpInfo
        return controller
    }
    
    //MARK: - View lifecycle
    
    deinit {
        currentTask?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupRefreshControl()
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
        
        contactSyncHelper.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if searchBar?.text?.isEmpty == false {
            searchBar?.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchBar?.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if tableView.tableHeaderView == nil {
            setupHeader()
        }
    }
    
    private func setupHeader() {
        let header = ContactListHeader.with(delegate: self)
        header.setup(with: backUpInfo)
        
        let size = header.sizeToFit(width: tableView.bounds.width)
        header.frame.size = size
        
        tableView.tableHeaderView = header
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = ColorConstants.whiteColor
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupNavigationBar() {
        setTitle(withString: TextConstants.contactListNavBarTitle)
        backButtonForNavigationItem(title: TextConstants.backTitle)
        
        let moreButton = UIBarButtonItem(image: Images.threeDots, style: .plain, target: self, action: #selector(onMore))
        navigationItem.rightBarButtonItem = moreButton
    }
}

//MARK: - Private actions

private extension ContactListViewController {
    
    @IBAction func restore(_ sender: UIButton) {
        showPopup(type: .restoreContacts)
    }
    
    @objc func onMore() {
        showMoreActionSheet()
    }
    
    @objc func reloadData() {
        tableView.refreshControl?.endRefreshing()
        currentTask?.cancel()
        currentTask = nil
        isLoadingData = false
        currentPage = 1
        numberOfPages = Int.max
        dataSource.reset()
        showSpinner()
        loadContacts()
    }
    
    func loadContacts() {
        guard !isLoadingData else {
            return
        }
        
        guard currentPage <= numberOfPages else {
            return
        }
        isLoadingData = true
        
        if currentPage > 1 {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            indicator.startAnimating()
            tableView.tableFooterView = indicator
        }
        
        let handler: ContactSyncResponseHandler = { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.isLoadingData = false
            self.tableView.tableFooterView = nil
            
            switch result {
            case .success(let response):
                self.numberOfPages = response.numberOfPages
               self.currentPage += 1
               self.dataSource.append(newContacts: response.contacts) { [weak self] in
                   self?.hideSpinner()
               }
            
            case .failed(let error):
                self.hideSpinner()
                UIApplication.showErrorAlert(message: error.description)
            }
        }
        
        if let query = lastQuery {
            currentTask = contactsSyncService.searchContacts(query: query, page: currentPage, handler: handler)
        } else {
            currentTask = contactsSyncService.getContacts(page: currentPage, handler: handler)
        }
    }
    
    func backup() {
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
    
    func restore() {
        navigationItem.rightBarButtonItem = nil
        showSpinner()
        
        restoreProgressView.reset()
        contactSyncHelper.restore { [weak self] in
            self?.hideSpinner()
        }
    }
    
    func deleteAll() {
        navigationItem.rightBarButtonItem = nil
        showSpinner()
        
        currentTask = contactsSyncService.deleteAllContacts { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.hideSpinner()
            
            switch result {
            case .success(_):
                self.showResultView(type: .deleteAllContacts, result: .success)
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
}

//MARK: - Popups

private extension ContactListViewController {
    
    func showMoreActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let restoreAction = UIAlertAction(title: TextConstants.contactListRestore, style: .default) { [weak self] _ in
            self?.showPopup(type: .restoreContacts)
        }
        actionSheet.addAction(restoreAction)
        
        let deleteAllAction = UIAlertAction(title: TextConstants.contactListDeleteAll, style: .default) { [weak self] _ in
            self?.showPopup(type: .deleteAllContacts)
        }
        actionSheet.addAction(deleteAllAction)
        
        let cancelAction = UIAlertAction(title: TextConstants.cancel, style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        actionSheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem

        present(actionSheet, animated: true)
    }
    
    func showResultView(type: ContactsOperationType, result: ContactsOperationResult) {
        switch type {
        case .backUp(_):
            resultView = BackupContactsOperationView.with(type: type, result: result)
        default:
            let resultView = ContactsOperationView.with(type: type, result: result)
            
            if result == .success {
                switch type {
                case .deleteAllContacts:
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
    
    func show(view: UIView, animated: Bool) {
        animator.showTransition(to: view, on: self.view, animated: true)
    }
}

//MARK: - ContactListDataSourceDelegate

extension ContactListViewController: ContactListDataSourceDelegate {
    func needLoadNextItemsPage() {
        loadContacts()
    }
    
    func didSelectContact(_ contact: RemoteContact) {
        let controller = router.contactDetail(with: contact)
        router.pushViewController(viewController: controller)
    }
}

//MARK: - ContactListHeaderDelegate

extension ContactListViewController: ContactListHeaderDelegate {
    func search(query: String?) {
        lastQuery = query
        reloadData()
    }
    
    func cancelSearch() {
        lastQuery = nil
        reloadData()
    }
}

//MARK: - ContactSyncControllerProtocol

extension ContactListViewController: ContactSyncControllerProtocol {
    func showPopup(type: ContactSyncPopupType) {
        let handler: VoidHandler = { [weak self] in
            guard let self = self else {
                return
            }
            
            switch type {
            case .backup:
                self.backup()
            case .deleteAllContacts:
                self.deleteAll()
            case .restoreContacts:
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

//MARK: - ContactSyncHelperDelegate

extension ContactListViewController: ContactSyncHelperDelegate {
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
