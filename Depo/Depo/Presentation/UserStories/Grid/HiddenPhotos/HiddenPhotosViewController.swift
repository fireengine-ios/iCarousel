//
//  HiddenPhotosViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 12/12/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class HiddenPhotosViewController: BaseViewController, NibInit {

    @IBOutlet private weak var sortPanelContainer: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    private let emptyView = HiddenPhotosEmptyView.initFromNib()
    
    private lazy var dataSource = HiddenPhotosDataSource(collectionView: collectionView, delegate: self)
    private lazy var sortingManager = HiddenPhotosSortingManager(delegate: self)
    private lazy var dataLoader = HiddenPhotosDataLoader(delegate: self)
    private lazy var bottomBarManager = HiddenPhotosBottomBarManager(delegate: self)
    private lazy var navbarManager = HiddenPhotosNavbarManager(delegate: self)
    private lazy var threeDotsManager = HiddenPhotosThreeDotMenuManager(delegate: self)
    
    private lazy var router = RouterVC()
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sortingManager.addBarView(to: sortPanelContainer)
        setupRefreshControl()
        setupEmptyView()
        bottomBarManager.setup()
        navbarManager.setDefaultState(sortType: dataSource.sortedRule)
        
        reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
        
        //need to fix crash on show bottom bar
        bottomBarManager.editingTabBar?.view.layoutIfNeeded()
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func setupEmptyView() {
        collectionView.backgroundView = emptyView
        emptyView.topOffset = AlbumsSliderCell.height
        emptyView.isHidden = true
    }
    
    @objc private func reloadData() {
        showSpinner()
        
        dataSource.reset()
        dataLoader.reloadData { [weak self] in
            guard let self = self else {
                return
            }
            
            self.collectionView.refreshControl?.endRefreshing()
            self.hideSpinner()
            self.emptyView.isHidden = !self.dataSource.isEmpty
        }
    }
}

// MARK: - Selection State Methods

extension HiddenPhotosViewController {
    private func startSelectionState() {
        navigationItem.hidesBackButton = true
        navbarManager.setSelectionState()
    }
    
    private func stopSelectionState() {
        navigationItem.hidesBackButton = false
        dataSource.cancelSelection()
        navbarManager.setDefaultState(sortType: dataSource.sortedRule)
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
        navbarManager.setMoreButton(isEnabled: !dataSource.isEmpty)
    }
}

//MARK: - HiddenPhotosDataSourceDelegate

extension HiddenPhotosViewController: HiddenPhotosDataSourceDelegate {
        
    func needLoadNextPhotoPage() {
        dataLoader.loadNextPhotoPage()
    }
    
    func needLoadNextAlbumPage() {
        dataLoader.loadNextAlbumsPage()
    }
    
    func didSelectPhoto(item: Item) {
        showDetails(item: item)
    }
    
    func didSelectAlbum(item: BaseDataSourceItem) {
        showAlbumDetails(item: item)
    }
    
    func onStartSelection() {
        startSelectionState()
    }
    
    func didChangeSelectedItems(count: Int) {
        updateBarsForSelectedObjects(count: count)
    }
}

//MARK: - HiddenPhotosSortingManagerDelegate

extension HiddenPhotosViewController: HiddenPhotosSortingManagerDelegate {
    func sortingRuleChanged(rule: SortedRules) {
        dataSource.sortedRule = rule
        dataLoader.sortedRule = rule
        reloadData()
    }
}

//MARK: - HiddenPhotosDataLoaderDelegate

extension HiddenPhotosViewController: HiddenPhotosDataLoaderDelegate {
    func didLoadPhoto(items: [Item]) {
        dataSource.append(items: items)
    }
    
    func didLoadAlbum(items: [BaseDataSourceItem]) {
        dataSource.appendAlbum(items: items)
    }
    
    func didFinishLoadAlbums() {
        dataSource.finishLoadAlbums()
    }
}

//MARK: - HiddenPhotosBottomBarManagerDelegate

extension HiddenPhotosViewController: HiddenPhotosBottomBarManagerDelegate {
    func onBottomBarDelete() {
        deleteSelectedItems()
    }
    
    func onBottomBarUnhide() {
        unhideSelectedItems()
    }
}

//MARK: - HiddenPhotosNavbarManagerDelegate

extension HiddenPhotosViewController: HiddenPhotosNavbarManagerDelegate {
    func onCancel() {
       stopSelectionState()
    }
    
    func onMore(_ sender: UIBarButtonItem) {
        threeDotsManager.showActions(isSelectingMode: dataSource.isSelectionStateActive, sender: sender)
    }
    
    func onSearch() {
        openSearch()
    }
}

//MARK: - HiddenPhotosThreeDotMenuManagerDelegate

extension HiddenPhotosViewController: HiddenPhotosThreeDotMenuManagerDelegate {
    
    func onThreeDotsManagerSelect() {
        dataSource.startSelection()
    }
    
    func onThreeDotsManagerUnhide() {
        unhideSelectedItems()
    }
    
    func onThreeDotsManagerDelete() {
        deleteSelectedItems()
    }
}

//MARK: - Routing

extension HiddenPhotosViewController {
    private func showDetails(item: Item) {
        let controller = router.filesDetailViewController(fileObject: item, items: dataSource.allItems.flatMap { $0 })
        let navController = NavigationController(rootViewController: controller)
        router.presentViewController(controller: navController)
    }
    
    private func openSearch() {
        let controller = router.searchView(navigationController: navigationController)
        router.pushViewController(viewController: controller)
    }
    
    private func showAlbumDetails(item: BaseDataSourceItem) {
        if let album = item as? AlbumItem {
            openAlbum(item: album)
        } else if let firItem = item as? Item, firItem.fileType.isContained(in: [.faceImage(.people), .faceImage(.places), .faceImage(.things)]) {
            openFIRAlbum(item: firItem)
        }
    }
    
    private func openAlbum(item: AlbumItem) {
        let controller = router.albumDetailController(album: item, type: .List, moduleOutput: nil)
        router.pushViewController(viewController: controller)
    }
    
    private func openFIRAlbum(item: Item) {
        showSpinner()
        
        dataLoader.getAlbumDetails(item: item) { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.hideSpinner()
            
            switch result {
            case .success(let album):
                let vc = self.router.imageFacePhotosController(album: album, item: item, moduleOutput: nil)
                self.router.pushViewController(viewController: vc)
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
}

//MARK: - Items processing

extension HiddenPhotosViewController {
    
    private func deleteSelectedItems() {
        let selectedItems = dataSource.allSelectedItems
    }
    
    private func unhideSelectedItems() {
        let selectedItems = dataSource.allSelectedItems
    }
}
