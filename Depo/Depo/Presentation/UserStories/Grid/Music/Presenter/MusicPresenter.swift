//
//  MusicPresenter.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 8/15/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class MusicPresenter: DocumentsGreedPresenter {
    
    override func updateNoFilesView() {
        super.updateNoFilesView()
        
        DispatchQueue.main.async {
            let isHiddenSpotifyStatusView = !((self.interactor as? MusicInteractorInput)?.spotifyStatus?.jobStatus != .unowned)
            
            (self.view as? MusicViewInput)?.didRefreshSpotifyStatusView(isHidden: isHiddenSpotifyStatusView,
                                                                        status: (self.interactor as? MusicInteractorInput)?.spotifyStatus)
        }
    }
    
}

// MARK: - MusicInteractorOutput

extension MusicPresenter: MusicInteractorOutput {
    
    func didSpotifyStatus(_ status: SpotifyStatus) {
        (view as? MusicViewInput)?.didRefreshSpotifyStatusView(isHidden: !status.isConnected, status: status)
    }
    
    func failedObtainSpotifyStatus() {
        (view as? MusicViewInput)?.didRefreshSpotifyStatusView(isHidden: true, status: nil)
    }
    
    func didImportSendToBackground() {
        (view as? MusicViewInput)?.importSendToBackground()
    }
    
    func didSpotifyStatusChange(_ newStatus: SpotifyStatus) {
        (view as? MusicViewInput)?.spotifyStatusDidChange(newStatus)
    }
}

// MARK: - MusicViewOutput

extension MusicPresenter: MusicViewOutput {
    
    func onSpotifyStatusViewTap() {
        (interactor as? MusicInteractorInput)?.processSpotifyStatusViewTap()
    }
    
}
