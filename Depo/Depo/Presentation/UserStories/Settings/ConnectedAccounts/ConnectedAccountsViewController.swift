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
import AuthenticationServices


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
    private var appleGoogleUserType: AppleGoogleUserType?

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
        navigationController?.navigationItem.title = ""
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
    
    private func showPasswordPopup(with user: AppleGoogleUser) {
        let popup = RouterVC().passwordEnterPopup(with: user, disconnectAppleGoogleLogin: true)
        present(popup, animated: true)
    }
    
    private func getGoogleTokenIfNeeded(handler: @escaping (AppleGoogleUser?) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if user?.profile?.email == SingletonStorage.shared.accountInfo?.email,
               let email = user?.profile?.email,
               let idToken = user?.authentication.idToken {
                handler(AppleGoogleUser(idToken: idToken, email: email, type: .google))
            } else {
                guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                let config = GIDConfiguration(clientID: clientID, serverClientID: Credentials.googleServerClientID)
                
                GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
                    if error != nil {
                        handler(nil)
                        return
                    }
                    
                    if let idToken = user?.authentication.idToken, let email = user?.profile?.email {
                        handler(AppleGoogleUser(idToken: idToken, email: email, type: .google))
                    }
                }
            }
        }
    }
    
    private func connectAppleGoogleLogin(with user: AppleGoogleUser, handler: @escaping (Bool?) -> Void) {
        appleGoogleService.connectAppleGoogleLogin(with: user) { result in
            switch result {
            case .success:
                handler(true)
            case .preconditionFailed(let error):
                handler(false)
                DispatchQueue.toMain {
                    self.showErrorAlert(message: error?.errorMessage ?? TextConstants.temporaryErrorOccurredTryAgainLater)
                }
            case.badRequest(let error):
                handler(false)
                DispatchQueue.toMain {
                    self.showErrorAlert(message: error?.errorMessage ?? TextConstants.temporaryErrorOccurredTryAgainLater)
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    private func getAppleToken() {
        let controller = appleGoogleService.getAppleAuthorizationController()
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
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
    func appleGoogleDisconnectFailed(type: AppleGoogleUserType) {
        DispatchQueue.toMain {
            self.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater)
        }
    }
    
    func connectGoogleLogin(callback: @escaping (Bool) -> Void) {
        getGoogleTokenIfNeeded { user in
            if let user = user {
                self.connectAppleGoogleLogin(with: user) { isSuccess in
                    callback(isSuccess ?? false)
                }
            } else {
                callback(false)
            }
        }
    }
    
    func showPasswordRequiredPopup(type: AppleGoogleUserType) {
        self.appleGoogleUserType = type
        let message = type == .google ? localized(.googlePasswordRequired) : localized(.applePasswordRequired)
        let popUp = RouterVC().messageAndButtonPopup(with: message,
                                                     buttonTitle: TextConstants.nextTitle)
        
        popUp.delegate = self
        present(popUp, animated: true)
    }

}

extension ConnectedAccountsViewController: MessageAndButtonPopupDelegate {
    func onActionButton() {
        dismiss(animated: true)
        
        if appleGoogleUserType == .google {
            getGoogleTokenIfNeeded { user in
                guard let user = user else { return }
                self.showPasswordPopup(with: user)
            }
        } else if appleGoogleUserType == .apple {
            if #available(iOS 13.0, *) {
                getAppleToken()
            }
        }
    }
}

@available(iOS 13.0, *)
extension ConnectedAccountsViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credentials = authorization.credential as? ASAuthorizationAppleIDCredential {
            appleGoogleService.getAppleCredentials(with: credentials) { user in
                guard let user = user else { return }
                let appleUser = AppleGoogleUser(idToken: user.idToken, email: user.email, type: .apple)
                showPasswordPopup(with: appleUser)
            } fail: { error in
                debugLog(error)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        debugLog("Apple auth didCompleteWithError: \(error.localizedDescription)")
    }
}

@available(iOS 13.0, *)
extension ConnectedAccountsViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}




