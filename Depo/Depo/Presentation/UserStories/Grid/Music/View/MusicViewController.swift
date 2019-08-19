//
//  ViewController.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 8/15/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class MusicViewController: BaseFilesGreedViewController {
    
    private enum Constants {
        static let spotifyStatusViewHeight: CGFloat = 78
        static let bottomInsetCollectionView: CGFloat = 25
    }
    
    private let spotifyStatusView = SpotifyStatusView.initFromNib()

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareDesign()
    }
    
    override func showNoFilesWith(text: String, image: UIImage, createFilesButtonText: String, needHideTopBar: Bool) {
        super.showNoFilesWith(text: text, image: image, createFilesButtonText: createFilesButtonText, needHideTopBar: needHideTopBar)
        spotifyStatusView.isHidden = true
    }
    
    @objc override func loadData() {
        super.loadData()
        refreshSpotifyStatusView(isHidden: true)
    }
    
    // MARK: Private methods
    
    private func prepareDesign() {
        collectionView.addSubview(spotifyStatusView)
        collectionView.contentInset = UIEdgeInsets(top: Constants.spotifyStatusViewHeight, left: 0, bottom: Constants.bottomInsetCollectionView, right: 0)

        prepareSpotifyStatusView()
    }
    
    private func prepareSpotifyStatusView() {
        spotifyStatusView.delegate = self
        spotifyStatusView.isHidden = true
        spotifyStatusView.translatesAutoresizingMaskIntoConstraints = false
        spotifyStatusView.heightAnchor.constraint(equalToConstant: Constants.spotifyStatusViewHeight).isActive = true
        spotifyStatusView.bottomAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        spotifyStatusView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        spotifyStatusView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func refreshSpotifyStatusView(isHidden: Bool) {
        let spotifyStatusViewHeight = isHidden ? 0 : Constants.spotifyStatusViewHeight
        collectionView.contentInset = UIEdgeInsets(top: spotifyStatusViewHeight, left: 0, bottom: Constants.bottomInsetCollectionView, right: 0)
        /// To not update offset when new page is loading
        if Constants.spotifyStatusViewHeight > collectionView.contentOffset.y, spotifyStatusView.isHidden != isHidden {
            self.collectionView.setContentOffset(CGPoint(x: 0, y: -spotifyStatusViewHeight), animated: true)
        }
        spotifyStatusView.isHidden = isHidden
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

