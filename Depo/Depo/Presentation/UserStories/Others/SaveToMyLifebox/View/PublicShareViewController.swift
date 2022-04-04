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
    @IBOutlet private weak var noContentLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue?.textColor = ColorConstants.grayTabBarButtonsColor
            newValue?.font = UIFont.TurkcellSaturaRegFont(size: 20)
        }
    }
    
    //MARK: -Properties
    private let actionView = PublicSharedItemsActionView.initFromNib()
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    private lazy var storageVars: StorageVars = factory.resolve()
    private var publicDownloader = PublicShareDownloader.shared
    private var isLoading: Bool = false
    
    var isRootFolder: Bool = true
    var output: PublicShareViewOutput!
    var mainTitle: String?
    var alert: UIAlertController?

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
        
        if isRootFolder {
            output.getPublicSharedItemsCount()
            output.trackScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar()
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
        setTitle(withString: mainTitle ?? "")
        if isRootFolder == true {
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
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func displayErrorUI() {
        tableView.isHidden = true
        noContentLabel.isHidden = false
    }
    
    private func dismissDownloadAlert(handler: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.alert?.dismiss(animated: false, completion: nil)
            self.alert = nil
            handler()
        }
    }
    
    private func createDownloadFileName() -> String {
        let date = Date().createCurrentDate() + "-" + Date().createCurrentHour()
        return "lifebox-\(date).zip"
    }
    
    private func showDownloadAlert() {
        let fileName = createDownloadFileName()
        let message = String(format: localized(.publicShareDownloadMessage), Date().createCurrentDate(), Date().createCurrentHour())
        
        let alert = createAlert(title: nil, message: message, firstTitle: localized(.publicShareCancelTitle),
                                secondTitle: localized(.publicShareDownloadTitle)) { action in
            if action != .cancel {
                self.output.onSaveDownloadButton(with: fileName)
            }
        }
        present(alert, animated: true)
    }
}

//MARK: -PublicShareViewInput
extension PublicShareViewController: PublicShareViewInput {
    
    func listOperationFail(with message: String, isToastMessage: Bool) {
        displayErrorUI()
      
        if !isToastMessage {
            noContentLabel.text = localized(.publicShareNotFoundPlaceholder)
        } else {
            SnackbarManager.shared.show(type: .action, message: localized(.publicShareFileNotFoundError))
        }
    }
    
    func saveOperationSuccess() {
        SnackbarManager.shared.show(type: .nonCritical, message: localized(.publicShareSaveSuccess))
    }
    
    func saveOpertionFail(errorMessage: String) {
        SnackbarManager.shared.show(type: .nonCritical, message: errorMessage)
    }
    
    func createDownloadLinkFail() {
        SnackbarManager.shared.show(type: .action, message: localized(.publicShareFileNotFoundError))
    }
    
    func downloadOperationSuccess() {
        dismissDownloadAlert {
            let vc = PopUpController.with(title: TextConstants.success, message: TextConstants.popUpDownloadComplete, image: .success, buttonTitle: TextConstants.ok)
            DispatchQueue.main.async {
                self.present(vc, animated: false, completion: nil)
            }
        }
    }
    
    func downloadOperationFailed() {
        dismissDownloadAlert {
            let vc = PopUpController.with(title: TextConstants.errorAlert, message: localized(.publicShareDownloadErrorMessage), image: .error, buttonTitle: TextConstants.ok)
            DispatchQueue.main.async {
                self.present(vc, animated: false, completion: nil)
            }
        }
    }
    
    func downloadOperationStorageFail() {
        dismissDownloadAlert {
            DispatchQueue.main.async {
                let alert = self.createAlert(title: localized(.publicShareDownloadStorageErrorTitle),
                                             message: localized(.publicShareDownloadStorageErrorDescription),
                                             firstTitle: TextConstants.ok, cancelOnly: true) { _ in }
                self.present(alert, animated: true)
            }
        }
    }
    
    func didGetSharedItems(items: [SharedFileInfo]) {
        isLoading = false
        for item in items {
            let wrapData = WrapData(publicSharedFileInfo: item)
            dataSource.append(wrapData)
        }
        
        if dataSource.isEmpty {
            displayErrorUI()
            let message = isRootFolder ? localized(.publicShareNotFoundPlaceholder) : localized(.publicShareNoItemInFolder)
            noContentLabel.text = message
        }
    }
    
    func downloadOperationContinue(downloadedByte: String) {
        DispatchQueue.main.async {
            if self.alert != nil {
                self.alert?.message = downloadedByte
                return
            }
            
            self.alert = self.createAlert(title: TextConstants.popUpDownload, message: downloadedByte,
                                          firstTitle: localized(.publicShareCancelTitle), cancelOnly: true, handler: { _ in
                self.publicDownloader.stopDownload()
                self.dismissDownloadAlert {}
            })
            
            guard let alert = self.alert else { return }
            self.present(alert, animated: true)
        }
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

//MARK: -PublicSharedItemsActionViewDelegate
extension PublicShareViewController: PublicSharedItemsActionViewDelegate {
    func downloadButtonDidTapped() {
        showDownloadAlert()
    }
    
    func saveToMyLifeboxButtonDidTapped() {
        output.onSaveButton(isLoggedIn: tokenStorage.accessToken != nil)
    }
}
