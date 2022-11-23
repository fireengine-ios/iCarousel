//
//  ContactListViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 5/29/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol ContactListViewDelegate: AnyObject {
    func didDeleteContacts(for backup: ContactSync.SyncResponse)
    func didCreateNewBackup(_ backup: ContactSync.SyncResponse)
}

final class ContactListViewController: BaseViewController {
    
    private lazy var mainView = ContactListMainView.with(backUpInfo: backUpInfo, delegate: self)
    var progressView: ContactOperationProgressView?
    private var searchBar: UISearchBar? {
        (tableView.tableHeaderView as? ContactListHeader)?.searchBar
    }
    private lazy var moreButton = UIBarButtonItem(image: Image.iconThreeDotsHorizontal.image, style: .plain, target: self, action: #selector(onMore))
    private var tableView: UITableView {
        mainView.tableView
    }
    
    private lazy var dataSource = ContactListDataSource(tableView: tableView, delegate: self)
    private lazy var contactsSyncService = ContactSyncApiService()
    private let contactSyncHelper = ContactSyncHelper.shared
    private lazy var router = RouterVC()
    private let animator = ContentViewAnimator()
    
    private var backUpInfo: ContactBackupItem?
    
    private var currentPage = 1
    private var numberOfPages = Int.max
    private var lastQuery: String?
    
    private var isLoadingData = false
    private var currentTask: URLSessionTask?
    
    private let analyticsService = AnalyticsService()
    
    private weak var delegate: ContactListViewDelegate?
    
    static func with(backUpInfo: ContactBackupItem, delegate: ContactListViewDelegate?) -> ContactListViewController {
        let controller = ContactListViewController()
        controller.backUpInfo = backUpInfo
        controller.delegate = delegate
        return controller
    }
    
    //MARK: - View lifecycle
    
    deinit {
        currentTask?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        trackScreen()
        setupNavigationBar()
        showRelatedView()
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    private func setupNavigationBar() {
        setTitle(withString: TextConstants.contactListNavBarTitle)
    }
}

//MARK: - Analytics

private extension ContactListViewController {
    
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.ContactListScreen())
        analyticsService.logScreen(screen: .contactSyncContactsListScreen)
        analyticsService.trackDimentionsEveryClickGA(screen: .contactSyncContactsListScreen)
    }
    
}
 
//MARK: - Private actions

private extension ContactListViewController {
    
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
            let indicator = UIActivityIndicatorView(style: .gray)
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
            let backupId = backUpInfo?.id ?? -1
            currentTask = contactsSyncService.getContacts(backupId: backupId, page: currentPage, handler: handler)
        }
    }
}

//MARK: - Popups

private extension ContactListViewController {
    
    func showMoreActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = AppColor.blackColor.color
        
        let deleteAllAction = UIAlertAction(title: TextConstants.contactListDeleteAll, style: .default) { [weak self] _ in
            self?.showPopup(type: .deleteAllContacts, backup: self?.backUpInfo)
        }
        actionSheet.addAction(deleteAllAction)
        
        let cancelAction = UIAlertAction(title: TextConstants.cancel, style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        actionSheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem

        present(actionSheet, animated: true)
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

//MARK: - ContactSyncHelperDelegate
//MARK: - ContactSyncControllerProtocol

extension ContactListViewController: ContactSyncControllerProtocol, ContactSyncHelperDelegate {

    var selectedBackupForRestore: ContactBackupItem? {
        return backUpInfo
    }

    func show(view: UIView, animated: Bool) {
        animator.showTransition(to: view, on: self.view, animated: true)
    }
    
    func showRelatedView() {
        show(view: mainView, animated: true)
        navigationItem.rightBarButtonItem = moreButton
    }
    
    func didFinishOperation(operationType: ContactsOperationType) {
        switch operationType {
        case .backUp(let result):
            if let result = result {
                delegate?.didCreateNewBackup(result)
            }
        case .deleteAllContacts:
            if let backUpInfo = backUpInfo {
//                delegate?.didDeleteContacts(for: backUpInfo)
            }
            
            //TODO: need to delete in future
            //For now we return to main page
            guard let viewControllers = navigationController?.viewControllers else {
                return
            }
            navigationController?.viewControllers = viewControllers.filter { !($0 is ContactsBackupHistoryController) }
            
        default:
            break
        }        
    }
}

//MARK: - ContactListMainViewDelegate

extension ContactListViewController: ContactListMainViewDelegate {
    
    func onRestoreTapped() {
        showPopup(type: .restoreContacts, backup: backUpInfo)
    }
    
    func onReloadData() {
        reloadData()
    }
    
    func search(query: String?) {
        lastQuery = query
        reloadData()
    }
    
    func cancelSearch() {
        lastQuery = nil
        reloadData()
    }
}
