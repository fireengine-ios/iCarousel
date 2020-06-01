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
    private lazy var contactsSyncService = ContactSyncApiService()
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
    
    deinit {
        currentTask?.cancel()
    }
    
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
    
    func startRestore() {
        //TODO: 
    }
    
    func startDeleteAll() {
        showSpinner()
        
        currentTask = contactsSyncService.deleteAllContacts { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.hideSpinner()
            
            switch result {
            case .success(_):
                self.navigationItem.rightBarButtonItem = nil
                self.showDeleteResultView()
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
    
    func showRestorePopup() {
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
    
    func showDeleteAllPopup() {
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
    
    func showBackUpPopup() {
        let vc = PopUpController.with(title: TextConstants.backUpContactsConfirmTitle,
                                      message: TextConstants.backUpContactsConfirmMessage,
                                      image: .question,
                                      firstButtonTitle: TextConstants.cancel,
                                      secondButtonTitle: TextConstants.ok,
                                      secondAction: { [weak self] vc in
                                        //TODO: need start backup
//                                        self?.delegate?.backUp(isConfirmed: true)
                                        vc.close(isFinalStep: false) {
                                            self?.navigationController?.popViewController(animated: true)
                                        }
                                    })
        present(vc, animated: false)
    }
    
    func showDeleteResultView() {
        let resultView = ContactsOperationView.with(type: .deleteAllContacts, result: .success)
        resultView.frame = view.bounds
        resultView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(resultView)
        
        let backUpCard = BackUpContactsCard.initFromNib()
        resultView.add(card: backUpCard)
        
        backUpCard.backUpHandler = { [weak self] in
            self?.showBackUpPopup()
        }
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
    func search(query: String?) {
        lastQuery = query
        reloadData()
    }
    
    func cancelSearch() {
        lastQuery = nil
        reloadData()
    }
}
