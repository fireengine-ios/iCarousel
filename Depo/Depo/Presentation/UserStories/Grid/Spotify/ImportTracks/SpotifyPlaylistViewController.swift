//
//  SpotifyPlaylistViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SpotifyPlaylistViewController: BaseViewController, NibInit {

    @IBOutlet private weak var collectionView: UICollectionView!
    
    private lazy var dataSource: SpotifyCollectionViewDataSource<SpotifyTrack> = {
        let dataSource = SpotifyCollectionViewDataSource<SpotifyTrack>(collectionView: collectionView, delegate: self)
        dataSource.canChangeSelectionState = false
        dataSource.isSelectionStateActive = false
        return dataSource
    }()
    
    private lazy var spotifyService: SpotifyService = factory.resolve()
    var playlist: SpotifyPlaylist!
    private var page = 0
    private let pageSize = 20
    private var isLoadingNextPage = false
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTitle(withString: playlist.name, andSubTitle: String(format: TextConstants.Spotify.Playlist.songsCount, playlist.count))
        loadNextPage()
        collectionView.allowsSelection = false
    }
    
    // MARK: -
    
    private func loadNextPage() {
        if isLoadingNextPage || dataSource.isPaginationDidEnd {
            return
        }
        
        isLoadingNextPage = true
        
        spotifyService.getPlaylistTracks(playlistId: playlist.id, page: page, size: pageSize) { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.isLoadingNextPage = false
            
            switch result {
            case .success(let tracks):
                self.page += 1
                self.dataSource.append(tracks)
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
}

// MARK: - SpotifyPlaylistsDataSourceDelegate

extension SpotifyPlaylistViewController: SpotifyCollectionDataSourceDelegate {
    func onStartSelection() { }
    
    func onSelect(item: SpotifyObject) { }
    
    func needLoadNextPage() {
//        loadNextPage()
    }
    
    func didChangeSelectionCount(newCount: Int) { }
}
