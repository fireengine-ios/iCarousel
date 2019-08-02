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
        }
    }
    @IBOutlet private weak var importButtonBackView: UIView! {
        willSet {
            newValue.isHidden = true
            newValue.backgroundColor = .clear
            let gradientView = TransparentGradientView(style: .vertical, mainColor: .white)
            gradientView.frame = newValue.bounds
            newValue.addSubview(gradientView)
            newValue.sendSubview(toBack: gradientView)
            gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }

    private lazy var dataSource: SpotifyCollectionViewDataSource<SpotifyPlaylist> = {
        let dataSource = SpotifyCollectionViewDataSource<SpotifyPlaylist>(collectionView: collectionView, delegate: self)
        dataSource.canChangeSelectionState = false
        dataSource.isSelectionStateActive = true
        return dataSource
    }()
    private lazy var navbarManager = SpotifyPlaylistsNavbarManager(delegate: self)
    
    private lazy var router = RouterVC()
    
    private lazy var spotifyService: SpotifyService = factory.resolve()
    private var page = 0
    private let pageSize = 20
    private var isLoadingNextPage = false
    
    weak var delegate: SpotifyPlaylistsViewControllerDelegate?
    
    // MARK: - View lifecycle
    
    deinit {
        spotifyService.delegates.remove(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset.bottom = importButtonBackView.bounds.height
        navbarManager.setSelectionState()
        loadNextPage()
        
        spotifyService.delegates.add(self)
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
        importButtonBackView.isHidden = count == 0
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
    func onStartSelection() { }
    
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

// MARK: - SpotifyServiceDelegate

extension SpotifyPlaylistsViewController: SpotifyServiceDelegate {
    
    func importDidComplete() {
        importButton.setTitle(TextConstants.Spotify.Playlist.seeImported, for: .normal)
        importButtonBackView.isHidden = false
        
        navbarManager.setSuccessImportState()
        dataSource.isSelectionStateActive = false
        dataSource.showOnlySelected = true
        
        collectionView.reloadData()
        collectionViewTopOffset.constant = successImportView.bounds.height
        view.layoutIfNeeded()
    }
    
    func sendImportToBackground() {}
    func importDidCanceled() {}
    func importDidFailed(error: Error) {}
    func spotifyStatusDidChange() {}
}
