//
//  SpotifyImportedPlaylistsViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 8/9/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SpotifyImportedPlaylistsViewController: BaseViewController, NibInit {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var topBarContainer: UIView!
    
    private lazy var dataSource = SpotifyCollectionViewDataSource<SpotifyPlaylist>(collectionView: collectionView, delegate: self)
    
    private lazy var sortingManager = SpotifySortingManager(delegate: self)
    private lazy var navbarManager = SpotifyImportedPlaylistsNavbarManager(delegate: self)
    
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
        
        spotifyService.getImportedPlaylists(sortBy: sortedRule.sortingRules, sortOrder: sortedRule.sortOder, page: page, size: pageSize) { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.isLoadingNextPage = false
            
            switch result {
            case .success(let playlists):
                self.page += 1
                self.dataSource.append(playlists)
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func openTracks(for playlist: SpotifyPlaylist) {
        let controller = RouterVC().spotifyImportedTracksController(playlist: playlist)
        navigationController?.show(controller, sender: nil)
    }
}

// MARK: - SpotifyCollectionDataSourceDelegate

extension SpotifyImportedPlaylistsViewController: SpotifyCollectionDataSourceDelegate {

    func needLoadNextPage() {
        loadNextPage()
    }
    
    func onSelect(item: SpotifyObject) {
        if let playlist = item as? SpotifyPlaylist, !dataSource.isSelectionStateActive {
            openTracks(for: playlist)
        }
    }
    
    func didChangeSelectionCount(newCount: Int) {
        navbarManager.changeSelectionItems(count: newCount)
    }
    
    func onStartSelection() {
        
    }
}

// MARK: - SpotifySortingManagerDelegate

extension SpotifyImportedPlaylistsViewController: SpotifySortingManagerDelegate {
    
    func sortingRuleChanged(rule: SortedRules) {
        sortedRule = rule
    }
}

// MARK - SpotifyImportedPlaylistsNavbarManagerDelegate

extension SpotifyImportedPlaylistsViewController: SpotifyImportedPlaylistsNavbarManagerDelegate {
    
    func onCancel() {
        
    }
    
    func onMore() {
        
    }
    
    func onSearch() {
        
    }
}
