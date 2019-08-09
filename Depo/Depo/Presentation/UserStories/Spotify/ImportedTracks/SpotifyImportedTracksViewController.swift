//
//  SpotifyImportedTracksViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 8/9/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SpotifyImportedTracksViewController: BaseViewController, NibInit {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var topBarContainer: UIView!
    
    private lazy var dataSource = SpotifyCollectionViewDataSource<SpotifyTrack>(collectionView: collectionView, delegate: self)
    
    private lazy var sortingManager = SpotifySortingManager(delegate: self)
    private lazy var navbarManager = SpotifyImportedTracksNavbarManager(delegate: self, playlist: playlist)
    
    private lazy var spotifyService: SpotifyService = factory.resolve()
    private var page = 0
    private let pageSize = 20
    private var isLoadingNextPage = false
    
    private var sortedRule: SortedRules = .timeDown {
        didSet {
            dataSource.sortedRule = sortedRule
            reloadData()
        }
    }
    
    var playlist: SpotifyPlaylist!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navbarManager.setDefaultState()
        sortingManager.addBarView(to: topBarContainer)
        loadNextPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
    }
    
    // MARK: -
    
    private func reloadData() {
        page = 0
        isLoadingNextPage = false
        dataSource.reset()
        loadNextPage()
    }
    
    private func loadNextPage() {
        if isLoadingNextPage || dataSource.isPaginationDidEnd {
            return
        }
        
        isLoadingNextPage = true
        
        spotifyService.getImportedPlaylistTracks(playlistId: playlist.id!, sortBy: sortedRule.sortingRules, sortOrder: sortedRule.sortOder, page: page, size: pageSize) { [weak self] result in
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

// MARK: - SpotifyCollectionDataSourceDelegate

extension SpotifyImportedTracksViewController: SpotifyCollectionDataSourceDelegate {
    
    func needLoadNextPage() {
        loadNextPage()
    }
    
    func onSelect(item: SpotifyObject) {
        
    }
    
    func didChangeSelectionCount(newCount: Int) {
        
    }
    
    func onStartSelection() {
        
    }
}

// MARK: - SpotifySortingManagerDelegate

extension SpotifyImportedTracksViewController: SpotifySortingManagerDelegate {
    
    func sortingRuleChanged(rule: SortedRules) {
        sortedRule = rule
    }
}

// MARK - SpotifyImportedPlaylistsNavbarManagerDelegate

extension SpotifyImportedTracksViewController: SpotifyImportedPlaylistsNavbarManagerDelegate {
    
    func onCancel() {
        
    }
    
    func onMore() {
        
    }
    
    func onSearch() {
        
    }
}
