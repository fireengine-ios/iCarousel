//
//  ConnectedAccountsViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 24/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit


final class ConnectedAccountsViewController: ViewController, NibInit, ErrorPresenter {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var activityManager: ActivityIndicatorManager = {
        let manager = ActivityIndicatorManager()
        manager.delegate = self
        return manager
    }()
    
    private lazy var spotyfyRouter: SpotifyRoutingService = factory.resolve()
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
                           CellsIdConstants.socialAccountRemoveConnectionCell,
                           CellsIdConstants.spotifyAccountConnectionCell]
        
        for id in reusableIds {
            let nib = UINib(nibName: id, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: id)
        }
    }
    
    private func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.ConnectedAccountsScreen())
        analyticsService.logScreen(screen: .connectedAccounts)
        analyticsService.trackDimentionsEveryClickGA(screen: .connectedAccounts)
    }
}


// MARK: - UITableViewDelegate
extension ConnectedAccountsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == Section.SocialAccount.spotify.rawValue) ? 0 : 14
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return (section == Section.SocialAccount.spotify.rawValue) ? nil : SettingHeaderView.viewFromNib()
    }
}

// MARK: - SocialConnectionCellDelegate
extension ConnectedAccountsViewController: SocialConnectionCellDelegate {
    func didConnectSuccessfully(section: Section) {
        /// DispatchQueue.toMain invokes too fast
        DispatchQueue.main.async {
            if section.set(expanded: true) {
                let indexPath = IndexPath(row: Section.ExpandState.expanded.rawValue,
                                          section: section.account.rawValue)
                self.tableView.insertRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func didDisconnectSuccessfully(section: Section) {
        DispatchQueue.main.async {
            if section.set(expanded: false) {
                let indexPath = IndexPath(row: Section.ExpandState.expanded.rawValue,
                                          section: section.account.rawValue)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func showError(message: String) {
        DispatchQueue.toMain {
            self.showErrorAlert(message: message)
        }
    }
    
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
}







