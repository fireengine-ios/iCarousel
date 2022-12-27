//
//  ViewController.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 8/15/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class MusicViewController: BaseFilesGreedViewController {
    
    private let spotifyStatusView = SpotifyStatusView.initFromNib()

    override func viewDidLoad() {
        super.viewDidLoad()

//        FACELIFT: Spotify is removed
//        spotifyStatusView.delegate = self
    }
    
    override func showNoFilesWith(text: String, image: UIImage, createFilesButtonText: String, needHideTopBar: Bool) {
        super.showNoFilesWith(text: text, image: image, createFilesButtonText: createFilesButtonText, needHideTopBar: needHideTopBar)
        refreshSpotifyStatusView(isHidden: true)
    }
    
    @objc override func loadData() {
        super.loadData()
        refreshSpotifyStatusView(isHidden: true)
    }
    
    // MARK: Private methods
    
    private func refreshSpotifyStatusView(isHidden: Bool) {
        cardsContainerView.setFooter(view: isHidden ? nil : spotifyStatusView)
    }
}

// MARK: - MusicViewInput

extension MusicViewController: MusicViewInput {
    
    func didRefreshSpotifyStatusView(isHidden: Bool, status: SpotifyStatus?) {
        refreshSpotifyStatusView(isHidden: isHidden)
        spotifyStatusView.setStatus(status)
    }
    
    func importSendToBackground() {
        spotifyStatusView.importSendToBackground()
    }
    
    func spotifyStatusDidChange(_ newStatus: SpotifyStatus) {
        spotifyStatusView.spotifyStatusDidChange(newStatus)
    }
    
}

// MARK:

extension MusicViewController: SpotifyStatusViewDelegate {
    
    func onViewTap() {
        (output as? MusicViewOutput)?.onSpotifyStatusViewTap()
    }
    
}

