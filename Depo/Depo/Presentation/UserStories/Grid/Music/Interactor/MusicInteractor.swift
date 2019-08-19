//
//  MusicInteractor.swift
//  Depo_LifeTech
//
//  Created by Harbros12 on 8/16/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class MusicInteractor: BaseFilesGreedInteractor {

    private var spotifyService: SpotifyRoutingService
    
    var spotifyStatus: SpotifyStatus?
    
    init(remoteItems: RemoteItemsService, spotifyService: SpotifyRoutingService) {
        self.spotifyService = spotifyService
        super.init(remoteItems: remoteItems)
        self.spotifyService.delegates.add(self)
    }
    
    deinit {
        spotifyService.delegates.remove(self)
    }
    
    override func viewIsReady() {
        super.viewIsReady()
        
        getSpotifyStatus()
    }
    
    private func getSpotifyStatus() {
        spotifyService.getSpotifyStatus { [weak self] result in
            switch result {
            case .success(let status):
                self?.spotifyStatus = status
                (self?.output as? MusicInteractorOutput)?.didSpotifyStatus(status)
            case .failed(let error):
                (self?.output as? MusicInteractorOutput)?.failedObtainSpotifyStatus()
            }
        }
    }
}

// MARK: - SpotifyRoutingServiceDelegate

extension MusicInteractor: MusicInteractorInput {
    
    func processSpotifyStatusViewTap() {
        spotifyService.showImportedPlayLists()
    }
    
}

// MARK: - SpotifyRoutingServiceDelegate

extension MusicInteractor: SpotifyRoutingServiceDelegate {
    
    func importDidComplete() {
        getSpotifyStatus()
    }
    
    func importDidCanceled() {
        getSpotifyStatus()
    }
    
    func importSendToBackground() {
        (output as? MusicInteractorOutput)?.didImportSendToBackground()
    }
    
    func spotifyStatusDidChange(_ newStatus: SpotifyStatus) {
       (output as? MusicInteractorOutput)?.didSpotifyStatusChange(newStatus)
    }
    
}
