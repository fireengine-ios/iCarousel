//
//  SpotifyRoutingService.swift
//  Depo
//
//  Created by Maxim Soldatov on 7/26/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol SpotifyRoutingServiceDelegate: class {
    func importDidComplete()
    func importDidCanceled()
    func importSendToBackground()
    func spotifyStatusDidChange(_ newStatus: SpotifyStatus)
}

final class SpotifyRoutingService: NSObject {
    
    private var spotifyUrl: URL?
    private lazy var spotifySDKService = SpotifySDKService(url: spotifyUrl, delegate: self)
    
    private lazy var spotifyService: SpotifyService = factory.resolve()
    private(set) var lastSpotifyStatus: SpotifyStatus? {
        didSet {
            if let status = lastSpotifyStatus {
                delegates.invoke(invocation: { $0.spotifyStatusDidChange(status)} )
            }
        }
    }
    private lazy var router = RouterVC()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    var delegates = MulticastDelegate<SpotifyRoutingServiceDelegate>()
    private var importInProgress = false
    
    deinit {
        delegates.removeAll()
    }
    
    func getSpotifyStatus(completion: ResponseHandler<SpotifyStatus>?) {
        spotifyService.getStatus { [weak self] result in
            switch result {
            case .success(let status):
                self?.analyticsService.trackDimentionsEveryClickGA(screen: .spotifyAuthentification)
                self?.lastSpotifyStatus = status
                
                SingletonStorage.shared.isSpotifyEnabled = status.isConnected
                
                completion?(.success(status))
            case .failed(let error):
                completion?(.failed(error))
            }
        }
    }
    
    func getLastSpotifyStatus(completion: @escaping ResponseHandler<SpotifyStatus>) {
        if let status = lastSpotifyStatus {
            completion(.success(status))
        } else {
            getSpotifyStatus(completion: completion)
        }
    }
    
    func connectToSpotify(isSettingCell: Bool, completion: (() -> Void)?) {
        getSpotifyStatus { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let status):
                if status.isConnected {
                    self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .login, eventLabel: .success)
                    self.showPlayListsForImport()
                } else {
                    self.prepareAuthWebPage()
                }
            case .failed(let error):
                //completion(.failed(error))
                debugPrint(error.localizedDescription)
            }
            completion?()
        }
    }
    
    func disconnectFromSpotify(handler: @escaping ResponseHandler<SpotifyStatus>) {
        spotifyService.disconnect { [weak self] result in
            switch result {
            case .success(_):
                self?.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .login, eventLabel: .success)
                self?.getSpotifyStatus(completion: handler)
            case .failed(let error):
                handler(.failed(error))
            }
        }
    }
    
    func showImportedPlayLists() {
        let controller = router.spotifyImportedPlaylistsController()
        self.router.pushViewController(viewController: controller)
    }
    
    func showImportedPlayListsAfterImporting() {
        let controller = router.spotifyImportedPlaylistsController()
        router.replaceTopViewControllerWithViewController(controller)
    }
    
    private func showPlayListsForImport() {
        let controller = self.prepareImportPlaylistsController()
        self.router.pushViewController(viewController: controller)
    }
    
    private func prepareAuthWebPage() {
        spotifyService.getAuthUrl { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let url):
                self.spotifyUrl = url
                self.connectToSpotify()
            case .failed(let error):
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    private func connectToSpotify() {
        spotifySDKService.connectToSporify()
    }
    
    func onSpotifyAuthWebViewController() {
        guard let url = spotifyUrl else {
            assertionFailure()
            return
        }
        let controller = self.router.spotifyAuthWebViewController(url: url, delegate: self)
        router.pushViewController(viewController: controller)
    }
    
    private func prepareImportPlaylistsController() -> UIViewController {
        return router.spotifyPlaylistsController(delegate: self)
    }
    
    private func showOverwritePopup(handler: @escaping VoidHandler) {
        let popup = router.spotifyOverwritePopup(importAction: handler)
        router.presentViewController(controller: popup, animated: false)
    }
    
    private func importPlaylists(_ playlists: [SpotifyPlaylist]) {
        let controller = router.spotifyImportController(delegate: self)
        let navigationController = NavigationController(rootViewController: controller)
        navigationController.navigationBar.isHidden = false
        router.presentViewController(controller: navigationController)

        let ids = playlists.map { $0.playlistId }
        importInProgress = true
        
        spotifyService.start(playlistIds: ids) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(_):
                self.checkImportStatus { [weak self] shouldClosePlaylist in
                    
                    func passcodeSafeCloseImportVC() {
                        /// in case of import error need to hide screen with albums for import
                        if shouldClosePlaylist {
                            self?.router.popViewController()
                        }
                        navigationController.dismiss(animated: true, completion: {
                            /// not called if there were no popup
                            (UIApplication.shared.delegate as? AppDelegate)?.showPasscodeIfNeedInBackground()
                        })
                    }
                    
                    func changePasscodeSuccessCompletionOrInvoke(completion: @escaping () -> Void) {
                        if let passcodeVC = UIApplication.topController() as? PasscodeEnterViewController {
                            /// background
                            let currentPasscodeVCSuccess = passcodeVC.success
                            passcodeVC.success = {
                                currentPasscodeVCSuccess?()
                                completion()
                            }
                        } else {
                            /// foreground
                            completion()
                        }
                    }
                    
                    changePasscodeSuccessCompletionOrInvoke {
                        
                        /// check for cancel popup or import vc
                        if navigationController.presentedViewController != nil {
                            
                            navigationController.dismiss(animated: true, completion: {
                                (UIApplication.shared.delegate as? AppDelegate)?.showPasscodeIfNeedInBackground()
                                
                                /// close spotifyImportController if need
                                changePasscodeSuccessCompletionOrInvoke {
                                    passcodeSafeCloseImportVC()
                                }
                            })
                        } else {
                            /// close spotifyImportController
                            passcodeSafeCloseImportVC()
                        }
                        
                        self?.delegates.invoke(invocation: { $0.importDidComplete() })
                    }
                }
            case .failed(let error):
                self.importDidFailed(navigationController, error: error)
            }
        }
    }
    
    private func checkImportStatus(completion: @escaping BoolHandler) {
        guard importInProgress else {
            return
        }
        
        spotifyService.getStatus { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let status):
                SingletonStorage.shared.isSpotifyEnabled = status.isConnected

                switch status.jobStatus {
                case .finished:
                    self.importInProgress = false
                    self.lastSpotifyStatus = status
                    
                    completion(false)
                case .failed:
                    let popUpController = PopUpController.with(title: TextConstants.errorAlert,
                                                     message: TextConstants.Spotify.Import.lastImportFromSpotifyFailedError,
                                                     image: .error,
                                                     buttonTitle: TextConstants.ok) { controller in
                                                        controller.close {
                                                            completion(true)
                                                        }
                    }
                    
                    UIApplication.topController()?.present(popUpController, animated: true, completion: nil)
                default:
                    DispatchQueue.main.asyncAfter(deadline: .now() + NumericConstants.spotifyStatusUpdateTimeInterval, execute: { [weak self] in
                        self?.checkImportStatus(completion: completion)
                    })
                }
            case .failed(let error):
                debugPrint(error.localizedDescription)
                self.checkImportStatus(completion: completion)
            }
        }
    }
    
    private func importDidFailed(_ controller: UIViewController, error: Error) {
        //TODO: Control correct work with real server error
        guard error.errorCode != 412 else {
            return
        }
        
        let popup = PopUpController.with(title: TextConstants.errorAlert,
                                         message: TextConstants.Spotify.Playlist.transferingPlaylistError,
                                         image: .error,
                                         buttonTitle: TextConstants.ok,
                                         action: { popup in
                                            popup.close {
                                                controller.dismiss(animated: true)
                                            }
                                        })
        controller.present(popup, animated: true)
    }
    
    private func importAnalytics(playlists: [SpotifyPlaylist], result: ResponseResult<SpotifyStatus>) {
        var trackCount = 0
        for playlist in playlists {
            trackCount += playlist.count
        }
        switch result {
        case .success(_):
            let status = GAEventLabel.success.text

            self.analyticsService.trackSpotify(eventActions: .connectedAccounts,
                                               eventLabel: .importSpotifyResult(status),
                                               trackNumber: trackCount,
                                               playlistNumber: playlists.count)
        case .failed(_):
            let status = GAEventLabel.failure.text
            self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .connectedAccounts, eventLabel: .importSpotifyResult(status))
            self.analyticsService.trackImportEvent(error: .networkError)
            self.analyticsService.trackImportEvent(error: .importError)
        }
    }
}

// MARK: - SpotifyAuthViewControllerDelegate

extension SpotifyRoutingService: SpotifyAuthViewControllerDelegate {
    
    func spotifyAuthSuccess(with code: String) {
        spotifyService.connect(code: code) { [weak self] result in
            
            self?.getSpotifyStatus { [weak self] result in
                guard let self = self else {
                    return
                }
                
                switch result {
                case .success(_):
                    let controller = self.prepareImportPlaylistsController()
                    self.router.replaceTopViewControllerWithViewController(controller)
                case .failed(let error):
                    //TODO: Handle error
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }
    
    func spotifyAuthCancel() { }
}

// MARK: - SpotifyPlaylistsViewControllerDelegate

extension SpotifyRoutingService: SpotifyPlaylistsViewControllerDelegate {
    func onImport(playlists: [SpotifyPlaylist]) {
        getSpotifyStatus { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let status):
                self.importAnalytics(playlists: playlists, result: result)
                if status.lastModifiedDate == nil {
                    self.importPlaylists(playlists)
                } else {
                    self.showOverwritePopup { [weak self] in
                        self?.importPlaylists(playlists)
                    }
                }
            case .failed(let error):
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    func onShowImported() {
        showImportedPlayLists() 
    }
    
    func onShowImportedAfterImporting() {
        showImportedPlayListsAfterImporting()
    }
    
    func onOpenPlaylist(_ playlist: SpotifyPlaylist) {
        analyticsService.logScreen(screen: .spotifyImportPlaylistDetails)
        let controller = router.spotifyTracksController(playlist: playlist)
        router.pushViewController(viewController: controller)
    }
}

// MARK: - SpotifyImportControllerDelegate

extension SpotifyRoutingService: SpotifyImportControllerDelegate {
    
    func importDidCancel(_ controller: SpotifyImportViewController) {
        importInProgress = false
        router.navigationController?.popViewController(animated: false)
        controller.dismiss(animated: true, completion: nil)
        
        spotifyService.stop { [weak self] result in
            switch result {
            case .success(_):
                debugPrint("Spotify import cancelled")
            case .failed(let error):
                debugPrint(error.localizedDescription)
            }
            
            self?.delegates.invoke(invocation: { $0.importDidCanceled() })
        }
    }
    
    func importSendToBackground(_ controller: SpotifyImportViewController) {
        delegates.invoke(invocation: { $0.importSendToBackground() })
        router.navigationController?.popViewController(animated: false)
        controller.dismiss(animated: true)
    }
    
    func handleRedirectUrl(url: URL) -> Bool {
       return spotifySDKService.handleRedirectUrl(url: url)
    }
}

extension SpotifyRoutingService: SpotifySDKServiceDelegate {
    
    func continueSpotifySDKConnectionWithCode(code: String) {
        spotifyAuthSuccess(with: code)
    }
    
    func showSpotifyAuthWebViewController() {
        onSpotifyAuthWebViewController()
    }
}

 
