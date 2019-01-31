//
//  ConnectedAccountsViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 24/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

enum SocialAccount: Int {
    case instagram
    case facebook
    case dropbox
}


final class ConnectedAccountsViewController: ViewController, NibInit, ErrorPresenter {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var activityManager: ActivityIndicatorManager = {
        let manager = ActivityIndicatorManager()
        manager.delegate = self
        return manager
    }()
    private let analyticsService: AnalyticsService = factory.resolve()
    
    private let sections: [SocialAccount] = [.instagram, .facebook, .dropbox]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScreen()
        setupTableView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        trackScreen()
    }
    
    
    private func setupScreen() {
        setTitle(withString: TextConstants.settingsViewCellConnectedAccounts)
        navigationController?.navigationItem.title = TextConstants.backTitle
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        
        let reusableIds = [CellsIdConstants.instagramAccountConnectionCell,
                           CellsIdConstants.facebookAccountConnectionCell,
                           CellsIdConstants.dropboxAccountConnectionCell]
        
        for id in reusableIds {
            let nib = UINib(nibName: id, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: id)
        }
    }
    
    private func trackScreen() {
        analyticsService.logScreen(screen: .connectedAccounts)
        analyticsService.trackDimentionsEveryClickGA(screen: .connectedAccounts)
    }
}


// MARK: - UITableViewDataSource
extension ConnectedAccountsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = cellIdentifier(for: indexPath.section)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        (cell as? SocialAccountConnectionCell)?.delegate = self
        
        return cell
    }
 
    private func cellIdentifier(for section: Int) -> String {
        guard let accountType = SocialAccount(rawValue: section) else {
            assertionFailure("wrong index")
            return ""
        }
        
        switch accountType {
        case .instagram:
            return CellsIdConstants.instagramAccountConnectionCell
        case .facebook:
            return CellsIdConstants.facebookAccountConnectionCell
        case .dropbox:
            return CellsIdConstants.dropboxAccountConnectionCell
        }
    }
}


// MARK: - UITableViewDelegate
extension ConnectedAccountsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == SocialAccount.instagram.rawValue) ? 0 : 14
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return (section == SocialAccount.instagram.rawValue) ? nil : SettingHeaderView.viewFromNib()
    }
}

// MARK: - SocialAccountConnectionCellDelegate
extension ConnectedAccountsViewController: SocialAccountConnectionCellDelegate {
    
    func willChangeHeight() {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    func showError(message: String) {
        showErrorAlert(message: message)
    }
    
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
}






