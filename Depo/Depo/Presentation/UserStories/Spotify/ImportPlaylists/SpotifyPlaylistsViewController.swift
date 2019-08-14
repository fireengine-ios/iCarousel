//
//  SpotifyPlaylistsViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol SpotifyPlaylistsViewControllerDelegate: class {
    func onOpenPlaylist(_ playlist: SpotifyPlaylist)
    func onImport(playlists: [SpotifyPlaylist])
    func onShowImported()
}

final class SpotifyPlaylistsViewController: BaseViewController, NibInit {

    @IBOutlet private weak var successImportView: UIView!
    @IBOutlet private weak var successImportLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.Spotify.Playlist.successImport
            newValue.textColor = .white
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 20)
        }
    }
    @IBOutlet private weak var collectionViewTopOffset: NSLayoutConstraint!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var importButton: BlueButtonWithMediumWhiteText! {
        willSet {
            newValue.setTitle(TextConstants.Spotify.Playlist.importButton, for: .normal)
            newValue.isHidden = true
        }
    }
    @IBOutlet private weak var gradientView: TransparentGradientView! {
        willSet {
            newValue.backgroundColor = .white
            newValue.style = .vertical
        }
    }

    private lazy var dataSource: SpotifyCollectionViewDataSource<SpotifyPlaylist> = {
        let dataSource = SpotifyCollectionViewDataSource<SpotifyPlaylist>(collectionView: collectionView, delegate: self)
        dataSource.canChangeSelectionState = false
        dataSource.isSelectionStateActive = true
        dataSource.isHeaderless = true
        dataSource.selectionFullCell = false
        return dataSource
    }()
    private lazy var navbarManager = SpotifyPlaylistsNavbarManager(delegate: self)
    
    private lazy var router = RouterVC()
    
    private lazy var routingService: SpotifyRoutingService = factory.resolve()
    private lazy var spotifyService: SpotifyService = factory.resolve()
    private var page = 0
    private let pageSize = 20
    private var isLoadingNextPage = false
    
    weak var delegate: SpotifyPlaylistsViewControllerDelegate?
    
    // MARK: - View lifecycle
    
    deinit {
        routingService.delegates.remove(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        collectionView.contentInset.bottom = gradientView.bounds.height
        navbarManager.setSelectionState()
        loadNextPage()
        
        routingService.delegates.add(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
    }
    
    // MARK: -
    
    private func loadNextPage() {
        if isLoadingNextPage || dataSource.isPaginationDidEnd {
            return
        }
        
        isLoadingNextPage = true
        
        spotifyService.getPlaylists(page: page, size: pageSize) { [weak self] result in
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
    
    private func selectedItemsCountChange(with count: Int) {
        navbarManager.changeSelectionItems(count: count)
        importButton.isHidden = count == 0
    }
    
    @IBAction private func importSelected(_ sender: UIButton) {
        if dataSource.isSelectionStateActive {
            delegate?.onImport(playlists: dataSource.selectedItems)
        } else {
            delegate?.onShowImported()
        }
    }
}

// MARK: - SpotifyPlaylistsDataSourceDelegate

extension SpotifyPlaylistsViewController: SpotifyCollectionDataSourceDelegate {
    
    func canShowDetails() -> Bool {
        return dataSource.isSelectionStateActive
    }
    
    func onSelect(item: SpotifyObject) {
        guard let playlist = item as? SpotifyPlaylist else {
            return
        }
        delegate?.onOpenPlaylist(playlist)
    }

    func needLoadNextPage() {
        loadNextPage()
    }
    
    func didChangeSelectionCount(newCount: Int) {
        selectedItemsCountChange(with: newCount)
    }
    
    func onStartSelection() { }
}

// MARK: - SpotifyPlaylistsNavbarManagerDelegate

extension SpotifyPlaylistsViewController: SpotifyPlaylistsNavbarManagerDelegate {
    
    func onCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    func onSelectAll() {
        dataSource.selectAll()
    }
    
    func onDone() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - SpotifyRoutingServiceDelegate

extension SpotifyPlaylistsViewController: SpotifyRoutingServiceDelegate {
    
    func importDidComplete() {
        importButton.setTitle(TextConstants.Spotify.Playlist.seeImported, for: .normal)
        importButton.isHidden = false
        
        navbarManager.setSuccessImportState()
        dataSource.isSelectionStateActive = false
        dataSource.showOnlySelected = true
        
        collectionView.reloadData()
        collectionViewTopOffset.constant = successImportView.bounds.height
        view.layoutIfNeeded()
    }
    
    func spotifyStatusDidChange(_ newStatus: SpotifyStatus) { }
    func importSendToBackground() { }
}
