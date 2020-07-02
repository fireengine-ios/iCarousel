//
//  ContactListViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 5/29/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ContactListViewController: BaseViewController {
    
    private lazy var mainView = ContactListMainView.with(backUpInfo: backUpInfo, delegate: self)
    var progressView: ContactOperationProgressView?
    private var searchBar: UISearchBar? {
        (tableView.tableHeaderView as? ContactListHeader)?.searchBar
    }
    private lazy var moreButton = UIBarButtonItem(image: Images.threeDots, style: .plain, target: self, action: #selector(onMore))
    private var tableView: UITableView {
        mainView.tableView
    }
    
    private lazy var dataSource = ContactListDataSource(tableView: tableView, delegate: self)
    private lazy var contactsSyncService = ContactSyncApiService()
    private let contactSyncHelper = ContactSyncHelper.shared
    private lazy var router = RouterVC()
    private let animator = ContentViewAnimator()
    
    private var backUpInfo: ContactSync.SyncResponse?
    
    private var currentPage = 1
    private var numberOfPages = Int.max
    private var lastQuery: String?
    
    private var isLoadingData = false
    private var currentTask: URLSessionTask?
    
    static func with(backUpInfo: ContactSync.SyncResponse) -> ContactListViewController {
        let controller = ContactListViewController()
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
        showRelatedView()
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
    
    private func setupNavigationBar() {
        setTitle(withString: TextConstants.contactListNavBarTitle)
        backButtonForNavigationItem(title: TextConstants.backTitle)
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
}

//MARK: - Popups

private extension ContactListViewController {
    
    func showMoreActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAllAction = UIAlertAction(title: TextConstants.contactListDeleteAll, style: .default) { [weak self] _ in
            self?.showPopup(type: .deleteAllContacts)
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
    
    func show(view: UIView, animated: Bool) {
        animator.showTransition(to: view, on: self.view, animated: true)
    }
    
    func showRelatedView() {
        show(view: mainView, animated: true)
        navigationItem.rightBarButtonItem = moreButton
    }
    
    func handle(error: ContactSyncHelperError, operationType: SyncOperationType) { }
    func didFinishOperation(operationType: SyncOperationType) { }
}

//MARK: - ContactListMainViewDelegate

extension ContactListViewController: ContactListMainViewDelegate {
    
    func onRestoreTapped() {
        showPopup(type: .restoreContacts)
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
