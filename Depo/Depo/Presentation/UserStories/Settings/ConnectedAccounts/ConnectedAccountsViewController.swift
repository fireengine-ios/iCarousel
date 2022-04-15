//
//  ConnectedAccountsViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 24/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseCore


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
    private lazy var appleGoogleService = AppleGoogleLoginService()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.view = self
        dataSource.appleGoogleDelegate = self
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
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.separatorStyle = .none
        
        let reusableIds = [CellsIdConstants.instagramAccountConnectionCell,
                           CellsIdConstants.facebookAccountConnectionCell,
                           CellsIdConstants.dropboxAccountConnectionCell,
                           CellsIdConstants.socialAccountRemoveConnectionCell,
                           CellsIdConstants.spotifyAccountConnectionCell,
                           CellsIdConstants.appleGoogleAccountConnectionCell]
        
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
    
    private func showPasswordPopup(with idToken: String) {
        let popup = RouterVC().passwordEnterPopup(with: idToken, disconnectGoogleLogin: true)
        present(popup, animated: true)
    }
    
    private func getGoogleTokenIfNeeded(handler: @escaping (String?) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if user?.profile?.email == SingletonStorage.shared.accountInfo?.email {
                handler(user?.authentication.idToken)
            } else {
                guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                let config = GIDConfiguration(clientID: clientID, serverClientID: Keys.googleServerClientID)
                
                GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
                    if error != nil {
                        handler(nil)
                    }
                    
                    if let idToken = user?.authentication.idToken {
                        handler(idToken)
                    }
                }
            }
        }
    }
    
    private func connectGoogleLogin(with idToken: String, handler: @escaping (Bool?) -> Void) {
        appleGoogleService.connectGoogleLogin(with: idToken) { result in
            switch result {
            case .success:
                handler(true)
            case .preconditionFailed:
                handler(false)
                DispatchQueue.toMain {
                    self.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater)
                }
            case.badRequest:
                handler(false)
                DispatchQueue.toMain {
                    self.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater)
                }
            }
        }
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

extension ConnectedAccountsViewController: AppleGoogleAccountConnectionCellDelegate {
    func connectGoogleLogin(callback: @escaping (Bool) -> Void) {
        getGoogleTokenIfNeeded { idToken in
            if let idToken = idToken {
                self.connectGoogleLogin(with: idToken) { isSuccess in
                    callback(isSuccess ?? false)
                }
            } else {
                callback(false)
            }
        }
    }
    
    func showPasswordRequiredPopup() {
        let popUp = RouterVC().messageAndButtonPopup(with: localized(.googlePasswordRequired),
                                                     buttonTitle: TextConstants.nextTitle)
        popUp.delegate = self
        present(popUp, animated: true)
    }
    
    func googleDisconnectFailed() {
        DispatchQueue.toMain {
            self.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater)
        }
    }
}

extension ConnectedAccountsViewController: MessageAndButtonPopupDelegate {
    func onActionButton() {
        dismiss(animated: true)
        
        getGoogleTokenIfNeeded { token in
            guard let token = token else { return }
            self.showPasswordPopup(with: token)
        }
    }
}




