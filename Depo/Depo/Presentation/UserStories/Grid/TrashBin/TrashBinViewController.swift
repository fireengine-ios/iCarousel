//
//  TrashBinViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class TrashBinViewController: BaseViewController, NibInit, SegmentedChildController {

    @IBOutlet private weak var sortPanelContainer: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    private let emptyView = EmptyView.view(with: .trashBin)
    
    private lazy var dataSource = TrashBinDataSource(collectionView: collectionView, delegate: self)
    private lazy var sortingManager = TrashBinSortingManager(delegate: self)
    private lazy var interactor = TrashBinInteractor(delegate: self)
    private lazy var router = TrashBinRouter()
    private lazy var bottomBarManager = TrashBinBottomBarManager(delegate: self)
    private lazy var navbarManager = TrashBinNavbarManager(delegate: self)
    private lazy var threeDotsManager = TrashBinThreeDotMenuManager(delegate: self)
    
    //MARK: - View lifecycle
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        needToShowTabBar = true
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
        
        homePageNavigationBarStyle()
        navbarManager.setupNavBarButtons(animated: false)
        
        //need to fix crash on show bottom bar
        bottomBarManager.editingTabBar?.view.layoutIfNeeded()
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
        reloadData()
    }
    
    private func reloadData() {
        showSpinner()
        dataSource.reset()
        interactor.reloadData { [weak self] in
            guard let self = self else {
                return
            }
            
            self.collectionView.refreshControl?.endRefreshing()
            self.hideSpinner()
        }
    }
    
    private func reloadItems() {
        showSpinner()
        dataSource.itemsReset()
        interactor.reloadItems { [weak self] in
            self?.hideSpinner()
        }
    }
    
    private func reloadAlbums() {
        dataSource.albumSliderReset()
        interactor.reloadAlbums()
    }
    
    private func checkEmptyView() {
        emptyView.isHidden = !dataSource.itemsIsEmpty
    }

}

// MARK: - Selection State Methods

extension TrashBinViewController {
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

//MARK: - TrashBinDataSourceDelegate

extension TrashBinViewController: TrashBinDataSourceDelegate {
    func needLoadNextItemsPage() {
        interactor.loadNextItemsPage()
    }
    
    func needLoadNextAlbumPage() {
        interactor.loadNextAlbumsPage()
    }
    
    func didSelect(item: Item) {
        let sameTypeItems = dataSource.getSameTypeItems(for: item)
        router.openSelected(item: item, sameTypeItems: sameTypeItems)
    }
    
    func didSelect(album: BaseDataSourceItem) {
        showAlbumDetails(item: album)
    }
    
    func onStartSelection() {
        startSelectionState()
    }
    
    func didChangeSelectedItems(count: Int) {
        updateBarsForSelectedObjects(count: count)
    }
}

//MARK: - TrashBinSortingManagerDelegate

extension TrashBinViewController: TrashBinSortingManagerDelegate {
    func sortingRuleChanged(rule: SortedRules) {
        dataSource.sortedRule = rule
        interactor.sortedRule = rule
        reloadItems()
        navbarManager.setDefaultState(sortType: rule)
    }
    
    func viewTypeChanged(viewType: MoreActionsConfig.ViewType) {
        dataSource.viewType = viewType
    }
}

//MARK: - TrashBinDataLoaderDelegate

extension TrashBinViewController: TrashBinInteractorDelegate {    
    func didLoad(items: [Item]) {
        dataSource.append(items: items) { [weak self] in
            self?.checkEmptyView()
            self?.setMoreButton()
        }
    }
    
    func didLoad(albums: [BaseDataSourceItem]) {
        dataSource.append(albums: albums)
        setMoreButton()
    }
    
    func didFinishLoadAlbums() {
        dataSource.finishLoadAlbums()
    }
    
    func failedLoadItemsPage(error: Error) {
        UIApplication.showErrorAlert(message: error.description)
    }
    
    func failedLoadAlbumPage(error: Error) {
        UIApplication.showErrorAlert(message: error.description)
    }
}

//MARK: - TrashBinBottomBarManagerDelegate

extension TrashBinViewController: TrashBinBottomBarManagerDelegate {
    func onBottomBarDelete() {
//        showDeletePopup()
    }
    
    func onBottomBarRestore() {
//        showUnhidePopup()
    }
}

//MARK: - TrashBinNavbarManagerDelegate

extension TrashBinViewController: TrashBinNavbarManagerDelegate {
    func onCancel() {
       stopSelectionState()
    }
    
    func onMore(_ sender: UIBarButtonItem) {
        threeDotsManager.showActions(isSelectingMode: dataSource.isSelectionStateActive, sender: sender)
    }
    
    func onSearch() {
        router.openSearch(controller: self)
    }
}

//MARK: - TrashBinThreeDotMenuManagerDelegate

extension TrashBinViewController: TrashBinThreeDotMenuManagerDelegate {
    
    func onThreeDotsManagerSelect() {
        dataSource.startSelection()
    }
    
    func onThreeDotsManagerRestore() {
//        showUnhidePopup()
    }
    
    func onThreeDotsManagerDelete() {
//        showDeletePopup()
    }
}

//MARK: - Routing

extension TrashBinViewController {
    private func showAlbumDetails(item: BaseDataSourceItem) {
        if let album = item as? AlbumItem {
            router.openAlbum(item: album)
        } else if let firItem = item as? Item, firItem.fileType.isFaceImageType {
            openFIRAlbum(item: firItem)
        }
    }
    
    private func openFIRAlbum(item: Item) {
        showSpinner()
        
        interactor.getAlbumDetails(item: item) { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.hideSpinner()
            
            switch result {
            case .success(let album):
                self.router.openFIRAlbum(album: album, item: item, moduleOutput: self)
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
}

//MARK: - ItemOperationManagerViewProtocol

extension TrashBinViewController: ItemOperationManagerViewProtocol {
    
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        return object === self
    }
    
    func didUnhide(items: [WrapData]) {
        remove(items: items)
    }
    
    func didUnhide(albums: [AlbumItem]) {
        remove(albums: albums)
    }
    
    func moveToTrash(items: [Item]) {
        remove(items: items)
    }
    
    func moveToTrash(albums: [AlbumItem]) {
        dataSource.removeSlider(items: albums)
    }
    
    private func remove(items: [Item]) {
        let firItems = items.filter { $0.fileType.isFaceImageType }
        if firItems.isEmpty {
            reloadAlbums()
            dataSource.remove(items: items) { [weak self] in
                self?.checkEmptyView()
            }
        } else {
            // unhide|delete FIR albums
            remove(albums: firItems)
        }
    }
    
    private func remove(albums: [BaseDataSourceItem]) {
        dataSource.removeSlider(items: albums) { [weak self] in
            self?.reloadItems()
        }
    }
}

//MARK: - FaceImageItemsModuleOutput

extension TrashBinViewController: FaceImageItemsModuleOutput {
    
    func didChangeName(item: WrapData) {}
    func didReloadData() {}
    
    func delete(item: Item) {
        remove(items: [item])
    }
}
