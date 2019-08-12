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
    private lazy var bottomBarManager = SpotifyBottomBarManager(delegate: self)
    private lazy var threeDotsManager = SpotifyThreeDotMenuManager(delegate: self)
    private lazy var spotifyService: SpotifyService = factory.resolve()
    private lazy var router = RouterVC()
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
        bottomBarManager.setup()
        loadNextPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
        bottomBarManager.editingTabBar?.view.layoutIfNeeded()
        
        if let searchController = navigationController?.topViewController as? SearchViewController {
            searchController.dismissController(animated: false)
        }
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
    
    private func deleteSelectedTracks() {
        
    }
    
    // MARK: - Selection State
    
    private func startSelectionState() {
        navigationItem.hidesBackButton = true
        navbarManager.setSelectionState()
    }
    
    private func stopSelectionState() {
        navigationItem.hidesBackButton = false
        dataSource.cancelSelection()
        navbarManager.setDefaultState()
        bottomBarManager.hide()
    }
    
    private func updateBarsForSelectedObjects(count: Int) {
        navbarManager.changeSelectionItems(count: count)
        
        if count == 0 {
            bottomBarManager.hide()
        } else {
            bottomBarManager.show()
        }
    }
}

// MARK: - SpotifyCollectionDataSourceDelegate

extension SpotifyImportedTracksViewController: SpotifyCollectionDataSourceDelegate {
    
    func needLoadNextPage() {
        loadNextPage()
    }
    
    func onSelect(item: SpotifyObject) {}
    
    func didChangeSelectionCount(newCount: Int) {
        updateBarsForSelectedObjects(count: newCount)
    }
    
    func onStartSelection() {
        startSelectionState()
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
        stopSelectionState()
    }
    
    func onMore(_ sender: UIBarButtonItem) {
        threeDotsManager.showActions(isSelectingMode: dataSource.isSelectionStateActive, sender: sender)
    }
    
    func onSearch() {
        let controller = router.searchView(navigationController: navigationController)
        router.pushViewController(viewController: controller)
    }
}

// MARK: - SpotifyBottomBarManagerDelegate

extension SpotifyImportedTracksViewController: SpotifyBottomBarManagerDelegate {
    func onBottomBarManagerDelete() {
        deleteSelectedTracks()
    }
}

// MARK: - SpotifyThreeDotMenuManagerDelegate

extension SpotifyImportedTracksViewController: SpotifyThreeDotMenuManagerDelegate {
    
    func onThreeDotsManagerDelete() {
        deleteSelectedTracks()
    }
    
    func onThreeDotsManagerSelect() {
        dataSource.startSelection()
    }
}
