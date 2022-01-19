//
//  PublicShareViewController.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

class PublicShareViewController: BaseViewController, ControlTabBarProtocol {
    
    //MARK: -IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: -Properties
    private let actionView = PublicSharedItemsActionView.initFromNib()
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    private lazy var storageVars: StorageVars = factory.resolve()
    private var isLoading: Bool = false
    var output: PublicShareViewOutput!
    var mainTitle: String?
    var isMainFolder: Bool?

    private var dataSource: [WrapData] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        configureUI()
        output.viewIsReady()
        isLoading = true
        actionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar()
        navigationBarWithGradientStyle()
    }
    
    //MARK: -Helpers
    private func setupTableView() {
        tableView.register(nibCell: PublicSharedItemsTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset.bottom = actionView.frame.size.height
        tableView.tableFooterView = UIView()
    }
    
    private func configureUI() {
        self.setTitle(withString: self.mainTitle ?? "")
        navigationBarWithGradientStyle(isHidden: false, hideLogo: true)
        if isMainFolder == true {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: TextConstants.cancel,
                                                               target: self,
                                                               selector: #selector(onCancelTapped))
        }

        view.addSubview(actionView)
        actionView.translatesAutoresizingMaskIntoConstraints = false
        actionView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).activate()
        actionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        actionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        actionView.heightAnchor.constraint(equalToConstant: NumericConstants.saveToMyLifeboxActionViewHeight).activate()
    }
    
    @objc private func onCancelTapped() {
        if tokenStorage.accessToken == nil {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
        storageVars.publicSharedItemsToken = nil
        output.popViewController()
    }
}

//MARK: -SaveToMyLifeboxViewInput
extension PublicShareViewController: PublicShareViewInput {
    func saveOperationSuccess() {
        SnackbarManager.shared.show(type: .nonCritical, message: "Kaydetme işlemi başarılı oldu")
    }
    
    func didGetSharedItems(items: [SharedFileInfo]) {
        isLoading = false
        for item in items {
            let wrapData = WrapData(publicSharedFileInfo: item)
            dataSource.append(wrapData)
        }
    }
    
    func saveOpertionFail(errorMessage: String) {
        SnackbarManager.shared.show(type: .nonCritical, message: errorMessage)
    }
}

//MARK: -UITableViewDataSource
extension PublicShareViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusable: PublicSharedItemsTableViewCell.self, for: indexPath)
        let item = dataSource[indexPath.row]
        cell.configure(With: item)
        return cell
    }
}

//MARK: -UITableViewDelegate
extension PublicShareViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NumericConstants.saveToMyLifeboxCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource[indexPath.row]
        if item.fileType == .folder {
            output.onSelect(item: item)
        } else {
            let items = dataSource.filter { $0.isFolder == false }
            output.onSelect(item: item, items: items)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let tableView = tableView else { return }
        guard scrollView.contentOffset.y > 0 else { return }
        if scrollView.contentOffset.y > (tableView.contentSize.height - tableView.frame.size.height) {
            if !isLoading {
                output.fetchMoreIfNeeded()
                isLoading = true
            }
        }
    }
}

//MARK: -SaveToMyLifeboxActionViewDelegate
extension PublicShareViewController: PublicSharedItemsActionViewDelegate {
    func downloadButtonDidTapped() {
        return
    }
    
    func saveToMyLifeboxButtonDidTapped() {
        output.onSaveButton(isLoggedIn: tokenStorage.accessToken != nil)
    }
}
