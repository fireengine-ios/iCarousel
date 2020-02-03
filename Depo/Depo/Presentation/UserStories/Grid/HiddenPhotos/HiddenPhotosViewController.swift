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
    private let emptyView = EmptyView.view(with: .hiddenBin)
    
    private lazy var dataSource = HiddenPhotosDataSource(collectionView: collectionView, delegate: self)
    private lazy var sortingManager = HiddenPhotosSortingManager(delegate: self)
    private lazy var dataLoader = HiddenPhotosDataLoader(delegate: self)
    private lazy var bottomBarManager = HiddenPhotosBottomBarManager(delegate: self)
    private lazy var navbarManager = HiddenPhotosNavbarManager(delegate: self)
    private lazy var threeDotsManager = HiddenPhotosThreeDotMenuManager(delegate: self)
    
    private lazy var router = RouterVC()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    //MARK: - View lifecycle
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.HiddenBinScreen())
        
        trackScreen(.hiddenBin)
        
        ItemOperationManager.default.startUpdateView(view: self)
        sortingManager.addBarView(to: sortPanelContainer)
        setupRefreshControl()
        setupEmptyView()
        bottomBarManager.setup()
        navbarManager.setDefaultState(sortType: dataSource.sortedRule)
        
        reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .hiddenBin))
        
        navigationBarWithGradientStyle()
        
        //need to fix crash on show bottom bar
        bottomBarManager.editingTabBar?.view.layoutIfNeeded()
    }
    
    private func trackScreen(_ screen: AnalyticsAppScreens) {
        analyticsService.logScreen(screen: screen)
        analyticsService.trackDimentionsEveryClickGA(screen: screen)
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = ColorConstants.whiteColor
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func setupEmptyView() {
        collectionView.backgroundView = emptyView
        emptyView.topOffset = AlbumsSliderCell.height
        emptyView.isHidden = true
    }
    
    @objc private func onRefresh() {
        if dataSource.isSelectionStateActive {
            collectionView.refreshControl?.endRefreshing()
            return
        }
        
        reloadData()
    }
    
    private func reloadData() {
        showSpinner()
        dataSource.reset()
        dataLoader.reloadData { [weak self] in
            guard let self = self else {
                return
            }
            
            self.collectionView.refreshControl?.endRefreshing()
            self.hideSpinner()
        }
    }
    
    private func reloadPhotos() {
        showSpinner()
        dataSource.photosReset()
        dataLoader.reloadPhotos { [weak self] in
            self?.hideSpinner()
        }
    }
    
    private func reloadAlbums() {
        dataSource.albumSliderReset()
        dataLoader.reloadAlbums()
    }
    
    private func checkEmptyView() {
        emptyView.isHidden = !dataSource.photosIsEmpty
    }
    
    private func unhideSelectedItems() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .unhide))
        let selectedItems = dataSource.allSelectedItems.albums + dataSource.allSelectedItems.photos
        dataLoader.unhide(items: selectedItems)
    }
    
    private func moveToTrashSelectedItems() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .delete))
        let selectedItems = dataSource.allSelectedItems.albums + dataSource.allSelectedItems.photos
        dataLoader.moveToTrash(item: selectedItems)
    }
}

// MARK: - Selection State Methods

extension HiddenPhotosViewController {
    private func startSelectionState() {
        navigationItem.hidesBackButton = true
        navbarManager.setSelectionState()
        sortingManager.isActive = false
    }
    
    private func stopSelectionState() {
        navigationItem.hidesBackButton = false
        dataSource.cancelSelection()
        navbarManager.setDefaultState(sortType: dataSource.sortedRule)
        bottomBarManager.hide()
        collectionView.contentInset.bottom = 0
        setMoreButton()
        sortingManager.isActive = true
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
        reloadPhotos()
        navbarManager.setDefaultState(sortType: rule)
    }
}

//MARK: - HiddenPhotosDataLoaderDelegate

extension HiddenPhotosViewController: HiddenPhotosDataLoaderDelegate {
    func didLoadPhoto(items: [Item]) {
        dataSource.append(items: items) { [weak self] in
            self?.checkEmptyView()
            self?.setMoreButton()
        }
    }
    
    func didLoadAlbum(items: [BaseDataSourceItem]) {
        dataSource.appendAlbum(items: items)
        setMoreButton()
    }
    
    func didFinishLoadAlbums() {
        dataSource.finishLoadAlbums()
    }
    
    func failedLoadPhotoPage(error: Error) {
        UIApplication.showErrorAlert(message: error.description)
    }
    
    func failedLoadAlbumPage(error: Error) {
        UIApplication.showErrorAlert(message: error.description)
    }
}

//MARK: - HiddenPhotosBottomBarManagerDelegate

extension HiddenPhotosViewController: HiddenPhotosBottomBarManagerDelegate {
    func onBottomBarMoveToTrash() {
        moveToTrashSelectedItems()
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
    
    func onThreeDotsManagerMoveToTrash() {
        moveToTrashSelectedItems()
    }
}

//MARK: - Routing

extension HiddenPhotosViewController {
    private func showDetails(item: Item) {
        let items = dataSource.allItems.flatMap { $0 }
        let controller = router.filesDetailViewController(fileObject: item, items: items, status: .hidden)
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
        } else if let firItem = item as? Item, firItem.fileType.isFaceImageType {
            openFIRAlbum(item: firItem)
        }
    }
    
    private func openAlbum(item: AlbumItem) {
        let controller = router.albumDetailController(album: item, type: .List, status: .hidden, moduleOutput: nil)
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
                let vc = self.router.imageFacePhotosController(album: album, item: item, status: .hidden, moduleOutput: nil)
                self.router.pushViewController(viewController: vc)
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
}

//MARK: - ItemOperationManagerViewProtocol

extension HiddenPhotosViewController: ItemOperationManagerViewProtocol {
    
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        return object === self
    }
    
    func didUnhideItems(_ items: [WrapData]) {
        remove(items: items)
    }
    
    func didUnhideAlbums(_ albums: [AlbumItem]) {
        let customAlbums = albums.filter { !$0.fileType.isFaceImageAlbum }
        remove(albums: customAlbums)
    }
    
    func didUnhidePeople(items: [PeopleItem]) {
        remove(albums: items)
    }
    
    func didUnhidePlaces(items: [PlacesItem]) {
        remove(albums: items)
    }
    
    func didUnhideThings(items: [ThingsItem]) {
        remove(albums: items)
    }
    
    func didMoveToTrashItems(_ items: [Item]) {
        remove(items: items)
    }
    
    func didMoveToTrashPeople(items: [PeopleItem]) {
        remove(albums: items)
    }
    
    func didMoveToTrashPlaces(items: [PlacesItem]) {
        remove(albums: items)
    }
    
    func didMoveToTrashThings(items: [ThingsItem]) {
        remove(albums: items)
    }
    
    func didMoveToTrashAlbums(_ albums: [AlbumItem]) {
        let customAlbums = albums.filter { !$0.fileType.isFaceImageAlbum }
        remove(albums: customAlbums)
    }
    
    private func remove(items: [Item]) {
        stopSelectionState()
        reloadAlbums()
        dataSource.remove(items: items) { [weak self] in
            self?.checkEmptyView()
        }
    }
    
    private func remove(albums: [BaseDataSourceItem]) {
        stopSelectionState()
        
        if albums.isEmpty {
            return
        }
        
        dataSource.removeSlider(items: albums) { [weak self] in
            self?.reloadPhotos()
        }
    }
}
