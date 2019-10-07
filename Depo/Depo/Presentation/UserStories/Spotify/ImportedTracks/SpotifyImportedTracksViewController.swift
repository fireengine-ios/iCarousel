//
//  SpotifyImportedTracksViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 8/9/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol SpotifyImportedTracksViewControllerDelegate: class {
    func didDeleteTracks(playlist: SpotifyPlaylist)
}

final class SpotifyImportedTracksViewController: BaseViewController, NibInit {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var topBarContainer: UIView!
    @IBOutlet private weak var noTracksView: UIView!
    @IBOutlet private weak var noTracksLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.Spotify.Playlist.noTracks
            newValue.textColor = ColorConstants.textGrayColor
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 14)
        }
    }
    
    private lazy var dataSource = SpotifyCollectionViewDataSource<SpotifyTrack>(collectionView: collectionView, delegate: self)
    
    private let sortTypes: [MoreActionsConfig.SortRullesType] = [.AlphaBetricAZ, .AlphaBetricZA, .TimeNewOld, .TimeOldNew]
    private lazy var sortingManager = SpotifySortingManager(sortTypes: sortTypes, delegate: self)
    private lazy var navbarManager = SpotifyImportedTracksNavbarManager(delegate: self, playlist: playlist)
    private lazy var bottomBarManager = SpotifyBottomBarManager(delegate: self)
    private lazy var threeDotsManager = SpotifyThreeDotMenuManager(delegate: self)
    private lazy var spotifyService: SpotifyService = factory.resolve()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var router = RouterVC()
    private var page = 0
    private let pageSize = 20
    private var isLoadingNextPage = false
    
    weak var delegate: SpotifyImportedTracksViewControllerDelegate?
    
    private var sortedRule: SortedRules = .timeUp {
        didSet {
            dataSource.sortedRule = sortedRule
            reloadData()
        }
    }
    
    var playlist: SpotifyPlaylist?
    
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
    }
    
    // MARK: -
    
    private func reloadData() {
        page = 0
        isLoadingNextPage = false
        dataSource.reset()
        loadNextPage()
    }
    
    private func loadNextPage() {
        guard let playlistId = playlist?.id else {
            assertionFailure()
            return
        }
        
        if isLoadingNextPage || dataSource.isPaginationDidEnd {
            return
        }
        
        isLoadingNextPage = true
        
        spotifyService.getImportedPlaylistTracks(playlistId: playlistId,
                                                 sortBy: sortedRule.sortingRules,
                                                 sortOrder: sortedRule.sortOder,
                                                 page: page, size: pageSize) { [weak self] result in
                                                    guard let self = self else {
                                                        return
                                                    }
                                                    
                                                    self.isLoadingNextPage = false
                                                    DispatchQueue.main.async {
                                                        switch result {
                                                        case .success(let tracks):
                                                            self.page += 1
                                                            self.dataSource.append(tracks)
                                                        case .failed(let error):
                                                            UIApplication.showErrorAlert(message: error.localizedDescription)
                                                        }
                                                        self.updateEmptyView()
                                                    }
                                                }
    }
    
    private func deleteSelectedTracks() {
        let popup = router.spotifyDeletePopup(deleteAction: { [weak self] in
            guard let self = self else {
                return
            }
            self.deleteItems(self.dataSource.selectedItems)
        })
        present(popup, animated: false)
    }
    
    private func deleteItems(_ items: [SpotifyTrack]) {
        let trackIds = items.compactMap { $0.id }
        if trackIds.isEmpty {
            assertionFailure("should not be empty")
            return
        }
        
        showSpinner()
        
        spotifyService.deletePlaylistTracks(trackIds: trackIds) {  [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(_):
                self.dataSource.remove(items) {

                    self.analyticsService.trackSpotify(eventActions: .delete,
                                                       eventLabel: .importSpotifyTrack,
                                                       trackNumber: trackIds.count,
                                                       playlistNumber: nil)
                    self.hideSpinner()
                    self.playlist?.count -= items.count
                    self.navbarManager.playlist = self.playlist
                    self.stopSelectionState()
                    if let playlist = self.playlist {
                        self.delegate?.didDeleteTracks(playlist: playlist)
                    }
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
        noTracksView.isHidden = !isEmpty
        navbarManager.setMoreButton(isEnabled: !isEmpty)
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
        collectionView.contentInset.bottom = 0
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
    
    func canShowDetails() -> Bool {
        return false
    }
    
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
