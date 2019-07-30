//
//  SpotifyPlaylistsViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SpotifyPlaylistsViewController: BaseViewController, NibInit {

    @IBOutlet private weak var successImportView: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var topBarContainer: UIView!
    @IBOutlet private weak var importButton: BlueButtonWithMediumWhiteText! {
        willSet {
            //TODO: need localize
            newValue.setTitle("Import Selected", for: .normal)
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

    private lazy var dataSource = SpotifyPlaylistsDataSource(collectionView: collectionView, delegate: self)
    private lazy var sortingManager = SpotifyPlaylistsSortingManager(delegate: self)
    private lazy var navbarManager = SpotifyPlaylistsNavbarManager(delegate: self)
    
    private lazy var alert: AlertFilesActionsSheetPresenter = {
        let alert = AlertFilesActionsSheetPresenterModuleInitialiser().createModule()
        alert.basePassingPresenter = self
        return alert
    }()
    
    private lazy var spotifyService: SpotifyService = factory.resolve()
    private var page = 0
    private let pageSize = 20
    private var isLoadingNextPage = false
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset.bottom = importButtonBackView.bounds.height
        navigationBarWithGradientStyle()
        navbarManager.setDefaultState()
        sortingManager.addBarView(to: topBarContainer)
        loadNextPage()
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
    
    private func startSelection(with count: Int) {
        navbarManager.setSelectionState()
        selectedItemsCountChange(with: count)
    }
    
    private func stopSelection() {
        navbarManager.setDefaultState()
        dataSource.cancelSelection()
        importButtonBackView.isHidden = true
    }
    
    private func selectedItemsCountChange(with count: Int) {
        navbarManager.changeSelectionItems(count: count)
        importButtonBackView.isHidden = count == 0
    }
    
    @IBAction private func importSelected(_ sender: UIButton) {
        
    }
}

// MARK: - SpotifyPlaylistsDataSourceDelegate

extension SpotifyPlaylistsViewController: SpotifyPlaylistsDataSourceDelegate {
    
    func needLoadNextPage() {
//        loadNextPage()
    }
    
    func onStartSelection() {
        startSelection(with: 1)
    }
    
    func onSelect(playlist: SpotifyPlaylist) {
        
    }
    
    func didChangeSelectionCount(newCount: Int) {
        selectedItemsCountChange(with: newCount)
    }
}

// MARK: - SortingManagerDelegate

extension SpotifyPlaylistsViewController: SpotifyPlaylistsSortingManagerDelegate {
    
    func sortingRuleChanged(rule: MoreActionsConfig.SortRullesType) {
        
    }
}

// MARK: - SpotifyPlaylistsNavbarManagerDelegate

extension SpotifyPlaylistsViewController: SpotifyPlaylistsNavbarManagerDelegate {
    
    func onCancelSelection() {
        stopSelection()
    }
    
    func onSelectAll() {
        
    }
    
    func onMore() {
        if dataSource.isSelectionStateActive {
            showAlertSheet(with: [.selectAll], sender: self)
        } else {
            showAlertSheet(with: [.select], sender: self)
        }
    }
    
    private func showAlertSheet(with types: [ElementTypes], sender: Any?) {
        alert.show(with: types, for: [], presentedBy: sender, onSourceView: nil, viewController: nil)
    }
}

// MARK: - BaseItemInputPassingProtocol

extension SpotifyPlaylistsViewController: BaseItemInputPassingProtocol {
    
    func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems) {
        selectedItemsCallback([])
    }
    
    func selectModeSelected() {
        dataSource.startSelection()
        startSelection(with: 0)
    }
    
    func stopModeSelected() {
        stopSelection()
    }
    
    func selectAllModeSelected() {
        dataSource.selectAll()
    }
    
    func openInstaPick() {}
    func operationFinished(withType type: ElementTypes, response: Any?) {}
    func operationFailed(withType type: ElementTypes) {}
    func deSelectAll() {}
    func printSelected() {}
    func changeCover() {}
    func deleteFromFaceImageAlbum(items: [BaseDataSourceItem]) {}
}
