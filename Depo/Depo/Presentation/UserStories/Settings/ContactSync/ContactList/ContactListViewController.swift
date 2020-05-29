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
    
    private lazy var dataSource = ContactListDataSource(tableView: tableView, delegate: self)
    private lazy var contactsSyncService = ContactsSyncService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupRefreshControl()
        loadContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
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
        showRestorePopup()
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
        
        let successHandler: ContactsOperation = { [weak self] response in
            guard let self = self else {
                return
            }
            
            self.numberOfPages = response.numberOfPages
            self.currentPage += 1
            self.dataSource.append(newContacts: response.contacts) { [weak self] in
                self?.hideSpinner()
            }
            self.isLoadingData = false
            self.tableView.tableFooterView = nil
        }
        
        let failureHandler: FailResponse = { [weak self] error in
            guard let self = self else {
                return
            }
            
            self.isLoadingData = false
            self.hideSpinner()
            self.tableView.tableFooterView = nil
            UIApplication.showErrorAlert(message: error.description)
        }
        
        if let query = lastQuery {
            contactsSyncService.searchRemoteContacts(with: query, page: currentPage, success: successHandler, fail: failureHandler)
        } else {
            contactsSyncService.getContacts(with: currentPage, success: successHandler, fail: failureHandler)
        }
    }
    
    func startRestore() {
        //TODO: 
    }
    
    func startDeleteAll() {
        //TODO:
    }
}

//MARK: - Popups

private extension ContactListViewController {
    
    private func showMoreActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let restoreAction = UIAlertAction(title: TextConstants.contactListRestore, style: .default) { [weak self] _ in
            self?.showRestorePopup()
        }
        actionSheet.addAction(restoreAction)
        
        let deleteAllAction = UIAlertAction(title: TextConstants.contactListDeleteAll, style: .default) { [weak self] _ in
            self?.showDeleteAllPopup()
        }
        actionSheet.addAction(deleteAllAction)
        
        let cancelAction = UIAlertAction(title: TextConstants.cancel, style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
    
    private func showRestorePopup() {
        let vc = PopUpController.with(title: TextConstants.restoreContactsConfirmTitle,
                                      message: TextConstants.restoreContactsConfirmMessage,
                                      image: .question,
                                      firstButtonTitle: TextConstants.cancel,
                                      secondButtonTitle: TextConstants.ok,
                                      secondAction: { [weak self] vc in
                                        vc.close()
                                        self?.startRestore()
                                    })
        present(vc, animated: false)
    }
    
    private func showDeleteAllPopup() {
        let vc = PopUpController.with(title: TextConstants.deleteContactsConfirmTitle,
                                      message: TextConstants.deleteContactsConfirmMessage,
                                      image: .question,
                                      firstButtonTitle: TextConstants.cancel,
                                      secondButtonTitle: TextConstants.ok,
                                      secondAction: { [weak self] vc in
                                        vc.close()
                                        self?.startDeleteAll()
                                    })
        present(vc, animated: false)
    }
}

//MARK: - ContactListDataSourceDelegate

extension ContactListViewController: ContactListDataSourceDelegate {
    func needLoadNextItemsPage() {
        loadContacts()
    }
}

//MARK: - ContactListHeaderDelegate

extension ContactListViewController: ContactListHeaderDelegate {
    func startSearch(query: String?) {
        lastQuery = query
        reloadData()
    }
    
    func cancelSearch() {
        lastQuery = nil
        reloadData()
    }
}
