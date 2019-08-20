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

final class SpotifyRoutingService {
    
    private lazy var spotifyService: SpotifyService = factory.resolve()
    private(set) var lastSpotifyStatus: SpotifyStatus? {
        didSet {
            if let status = lastSpotifyStatus {
                delegates.invoke(invocation: { $0.spotifyStatusDidChange(status)} )
            }
        }
    }
    private lazy var router = RouterVC()
    var delegates = MulticastDelegate<SpotifyRoutingServiceDelegate>()
    private var importInProgress = false
    
    deinit {
        delegates.removeAll()
    }
    
    func getSpotifyStatus(completion: ResponseHandler<SpotifyStatus>?) {
        spotifyService.getStatus { [weak self] result in
            switch result {
            case .success(let status):
                self?.lastSpotifyStatus = status
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
    
    func connectToSpotify(isSettingCell: Bool) {
        getSpotifyStatus { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let status):
                if status.isConnected {
                    self.showPlayListsForImport()
                } else {
                    self.prepareAuthWebPage()
                }
            case .failed(let error):
                //completion(.failed(error))
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    func disconnectFromSpotify(handler: @escaping ResponseHandler<SpotifyStatus>) {
        spotifyService.disconnect { [weak self] result in
            switch result {
            case .success(_):
                self?.getSpotifyStatus(completion: handler)
            case .failed(let error):
                handler(.failed(error))
            }
        }
    }
    
    func showImportedPlayLists() {
        let controller = router.spotifyImportedPlaylistsController()
        router.pushViewController(viewController: controller)
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
                let controller = self.router.spotifyAuthWebViewController(url: url, delegate: self)
                self.router.pushViewController(viewController: controller)
            case .failed(let error):
                debugPrint(error.localizedDescription)
            }
        }
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
                self.checkImportStatus { [weak self] in
                    /// hide cancel popup if needed
                    if navigationController.presentedViewController != nil {
                        navigationController.dismiss(animated: false, completion: {
                            navigationController.dismiss(animated: true)
                        })
                    } else {
                        navigationController.dismiss(animated: true)
                    }
                    self?.delegates.invoke(invocation: { $0.importDidComplete() })
                }
            case .failed(let error):
                self.importDidFailed(navigationController, error: error)
            }
        }
    }
    
    private func checkImportStatus(completion: @escaping VoidHandler) {
        guard importInProgress else {
            return
        }
        
        spotifyService.getStatus { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let status):
                if status.jobStatus == .finished {
                    self.importInProgress = false
                    self.lastSpotifyStatus = status
                
                    completion()
                } else {
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
    
    func onOpenPlaylist(_ playlist: SpotifyPlaylist) {
        let controller = router.spotifyTracksController(playlist: playlist)
        router.pushViewController(viewController: controller)
    }
}

// MARK: - SpotifyImportControllerDelegate

extension SpotifyRoutingService: SpotifyImportControllerDelegate {
    
    func importDidCancel(_ controller: SpotifyImportViewController) {
        delegates.invoke(invocation: { $0.importDidCanceled() })
        
        importInProgress = false
        controller.dismiss(animated: true)
        
        spotifyService.stop { result in
            switch result {
            case .success(_):
                debugPrint("Spotify import cancelled")
            case .failed(let error):
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    func importSendToBackground(_ controller: SpotifyImportViewController) {
        delegates.invoke(invocation: { $0.importSendToBackground() })
        router.navigationController?.popViewController(animated: false)
        controller.dismiss(animated: true)
    }
}
