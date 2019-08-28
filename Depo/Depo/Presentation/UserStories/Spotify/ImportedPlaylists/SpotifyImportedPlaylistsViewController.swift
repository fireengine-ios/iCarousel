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
    @IBOutlet private weak var noPlaylistsView: UIView!
    @IBOutlet private weak var noPlaylistsLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.Spotify.Playlist.noImportedPlaylists
            newValue.textColor = ColorConstants.textGrayColor
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 14)
        }
    }
    
    private lazy var dataSource = SpotifyCollectionViewDataSource<SpotifyPlaylist>(collectionView: collectionView, delegate: self)
    
    private let sortTypes: [MoreActionsConfig.SortRullesType] = [.AlphaBetricAZ, .AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest]
    private lazy var sortingManager = SpotifySortingManager(sortTypes: sortTypes, delegate: self)
    private lazy var navbarManager = SpotifyImportedPlaylistsNavbarManager(delegate: self)
    private lazy var bottomBarManager = SpotifyBottomBarManager(delegate: self)
    private lazy var threeDotsManager = SpotifyThreeDotMenuManager(delegate: self)
    private lazy var spotifyService: SpotifyService = factory.resolve()
    private lazy var router = RouterVC()
    private var page = 0
    private let pageSize = 20
    private var isLoadingNextPage = false
    
    private var sortedRule: SortedRules = .timeUp {
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
        bottomBarManager.setup()
        loadNextPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
        
        //need to fix crash on show bottom bar
        bottomBarManager.editingTabBar?.view.layoutIfNeeded()
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
        
        spotifyService.getImportedPlaylists(sortBy: sortedRule.sortingRules,
                                            sortOrder: sortedRule.sortOder,
                                            page: page,
                                            size: pageSize) { [weak self] result in
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
                                                self.updateEmptyView()
                                            }
    }
    
    private func openTracks(for playlist: SpotifyPlaylist) {
        let controller = router.spotifyImportedTracksController(playlist: playlist, delegate: self)
        navigationController?.show(controller, sender: nil)
    }
    
    private func deleteSelectedPlaylists() {
        let popup = router.spotifyDeletePopup(deleteAction: { [weak self] in
            guard let self = self else {
                return
            }
            self.deleteItems(self.dataSource.selectedItems)
        })
        present(popup, animated: false)
    }
    
    private func deleteItems(_ items: [SpotifyPlaylist]) {
        let playlistIds = items.compactMap { $0.id }
        if playlistIds.isEmpty {
            assertionFailure("should not be empty")
            return
        }
        
        showSpinner()
        
        spotifyService.deletePlaylists(playlistIds: playlistIds) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(_):
                self.dataSource.remove(items) {
                    self.hideSpinner()
                    self.stopSelectionState()
                }
            case .failed(let error):
                self.hideSpinner()
                UIApplication.showErrorAlert(message: error.localizedDescription)
            }
            self.updateEmptyView()
        }
    }
    
    private func updateEmptyView() {
        let isEmpty = dataSource.allItems.isEmpty
        topBarContainer.isHidden = isEmpty
        noPlaylistsView.isHidden = !isEmpty
        navbarManager.setMoreButton(isEnabled: !isEmpty)
    }
    
    // MARK: - Selection State
    
    private func startSelectionState() {
        navigationItem.hidesBackButton = true
        navbarManager.setSelectionState()
    }
    
    private func stopSelectionState() {
        dataSource.cancelSelection()
        navigationItem.hidesBackButton = false
        navbarManager.setDefaultState()
        bottomBarManager.hide()
        collectionView.contentInset.bottom = 0
        setMoreButton()
    }
    
    private func updateBarsForSelectedObjects(count: Int) {
        navbarManager.changeSelectionItems(count: count)

        if count == 0 {
            bottomBarManager.hide()
            collectionView.contentInset.bottom = 0
        } else {
            bottomBarManager.show()
            collectionView.contentInset.bottom = bottomBarManager.editingTabBar?.editingBar.bounds.height ?? 0
        }
    }
    
    private func setMoreButton() {
        if dataSource.allItems.isEmpty {
            navbarManager.setMoreButton(isEnabled: false)
        }
    }
}

// MARK: - SpotifyCollectionDataSourceDelegate

extension SpotifyImportedPlaylistsViewController: SpotifyCollectionDataSourceDelegate {
    
    func canShowDetails() -> Bool {
        return true
    }

    func needLoadNextPage() {
        loadNextPage()
    }
    
    func onSelect(item: SpotifyObject) {
        if let playlist = item as? SpotifyPlaylist, !dataSource.isSelectionStateActive {
            openTracks(for: playlist)
        }
    }
    
    func didChangeSelectionCount(newCount: Int) {
        updateBarsForSelectedObjects(count: newCount)
    }
    
    func onStartSelection() {
        startSelectionState()
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

extension SpotifyImportedPlaylistsViewController: SpotifyBottomBarManagerDelegate {
    func onBottomBarManagerDelete() {
        deleteSelectedPlaylists()
    }
}

// MARK: - SpotifyThreeDotMenuManagerDelegate

extension SpotifyImportedPlaylistsViewController: SpotifyThreeDotMenuManagerDelegate {
    
    func onThreeDotsManagerDelete() {
        deleteSelectedPlaylists()
    }
    
    func onThreeDotsManagerSelect() {
        dataSource.startSelection()
    }
}

// MARK: - spotifyImportedTracksControllerDelegate

extension SpotifyImportedPlaylistsViewController: SpotifyImportedTracksViewControllerDelegate {
    func didDeleteTracks(playlist: SpotifyPlaylist) {
        dataSource.update(playlist)
        // TODO: need a detailed description of the case
        // now only update playlist count
        if playlist.count == 0 {
            navigationController?.popViewController(animated: true)
//            dataSource.remove([playlist], completion: {})
        } else {
//            dataSource.update(playlist)
        }
    }
}
