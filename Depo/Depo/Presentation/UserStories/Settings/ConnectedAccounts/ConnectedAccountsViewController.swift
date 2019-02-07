//
//  ConnectedAccountsViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 24/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class Section {
    enum SocialAccount: Int {
        case instagram
        case facebook
        case dropbox
    }
    
    enum ExpandState: Int {
        case shrinked = 1
        case expanded = 2
    }
    
    private (set) var account: SocialAccount
    private (set) var state: ExpandState
    
    
    init(account: SocialAccount, state: ExpandState) {
        self.account = account
        self.state = state
    }
    
    
    func toggleState() {
        state = (state == .shrinked) ? .expanded : .shrinked
    }
}

protocol ConnectedAccountsView: SocialConnectionCellDelegate, SocialRemoveConnectionCellDelegate {
    
}


final class ConnectedAccountsDataSource: NSObject {
    
    weak var view: ConnectedAccountsView?
    
    private let tableSections = [Section(account: .instagram, state: .shrinked),
                           Section(account: .facebook, state: .shrinked),
                           Section(account: .dropbox, state: .shrinked)]
    
    func changeState(sectionIndex: Int) {
        if let section = tableSections[safe: sectionIndex] {
            section.toggleState()
        }
    }
}


// MARK: - UITableViewDataSource
extension ConnectedAccountsDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSections[safe: section]?.state.rawValue ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = cellIdentifier(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        (cell as? SocialConnectionCell)?.delegate = view
        (cell as? SocialRemoveConnectionCell)?.delegate = view
        
        return cell
    }
    
    private func cellIdentifier(for indexPath: IndexPath) -> String {
        guard let section = tableSections[safe: indexPath.section] else {
            assertionFailure("wrong section index")
            return ""
        }
        
        switch (section.account, section.state) {
        case (.instagram, .shrinked):
            return CellsIdConstants.instagramAccountConnectionCell
        case (.facebook, .shrinked):
            return CellsIdConstants.facebookAccountConnectionCell
        case (.dropbox, .shrinked):
            return CellsIdConstants.dropboxAccountConnectionCell
            
        case (_, .expanded):
            return CellsIdConstants.socialAccountRemoveConnectionCell
        }
    }
}




final class ConnectedAccountsViewController: ViewController, NibInit, ErrorPresenter {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var activityManager: ActivityIndicatorManager = {
        let manager = ActivityIndicatorManager()
        manager.delegate = self
        return manager
    }()
    private let analyticsService: AnalyticsService = factory.resolve()

    private let dataSource = ConnectedAccountsDataSource()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.view = self
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
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 124.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.separatorStyle = .none
        
        let reusableIds = [CellsIdConstants.instagramAccountConnectionCell,
                           CellsIdConstants.facebookAccountConnectionCell,
                           CellsIdConstants.dropboxAccountConnectionCell,
                           CellsIdConstants.socialAccountRemoveConnectionCell]
        
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




// MARK: - UITableViewDelegate
//TODO: maybe move to datasource
extension ConnectedAccountsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == Section.SocialAccount.instagram.rawValue) ? 0 : 14
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return (section == Section.SocialAccount.instagram.rawValue) ? nil : SettingHeaderView.viewFromNib()
    }
}

// MARK: - SocialAccountConnectionCellDelegate
extension ConnectedAccountsViewController: ConnectedAccountsView {
    
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






