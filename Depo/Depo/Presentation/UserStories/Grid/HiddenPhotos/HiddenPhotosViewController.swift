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
    
    //MARK: - View lifecycle
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        navigationBarWithGradientStyle()
        
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
        showDeletePopup()
    }
    
    func onBottomBarUnhide() {
        showUnhidePopup()
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
        showUnhidePopup()
    }
    
    func onThreeDotsManagerMoveToTrash() {
        showDeletePopup()
    }
}

//MARK: - Routing

extension HiddenPhotosViewController {
    private func showDetails(item: Item) {
        guard let hiddenViewController = router.filesDetailHiddenViewController(fileObject: item, items: dataSource.allItems.flatMap { $0 }) else { return }
        let navController = NavigationController(rootViewController: hiddenViewController)
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
        let controller = router.hiddenAlbumDetailController(album: item, type: .List, moduleOutput: nil)
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
                let vc = self.router.imageFacePhotosController(album: album, item: item, status: .hidden, moduleOutput: self)
                self.router.pushViewController(viewController: vc)
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
}

//MARK: - Items processing

extension HiddenPhotosViewController {
    
    private func showDeletePopup() {
        let popup = PopUpController.with(title: TextConstants.actionSheetDelete,
                                         message: TextConstants.deletePopupText,
                                         image: .delete,
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.ok,
                                         secondAction: { vc in
                                            vc.close { [weak self] in
                                                self?.deleteSelectedItems()
                                            }
                                        })
        
        router.presentViewController(controller: popup,
                                     animated: false,
                                     completion: nil)
    }
    
    private func showUnhidePopup() {
        let popup = PopUpController.with(title: TextConstants.actionSheetUnhide,
                                         message: TextConstants.unhidePopupText,
                                         image: .unhide,
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.ok,
                                         secondAction: { vc in
                                            vc.close { [weak self] in
                                                self?.unhideSelectedItems()
                                            }
                                         })
        
        router.presentViewController(controller: popup,
                                     animated: false,
                                     completion: nil)
    }
    
    private func showDeleteSuccessPopup() {
        let popup = PopUpController.with(title: TextConstants.deletePopupSuccessTitle,
                                         message: TextConstants.deletePopupSuccessText,
                                         image: .success,
                                         buttonTitle: TextConstants.ok)
        
        router.presentViewController(controller: popup,
                                     animated: false,
                                     completion: nil)
    }
    
    private func showUnhideSuccessPopup() {
        let popup = PopUpController.with(title: TextConstants.unhidePopupSuccessTitle,
                                         message: TextConstants.unhidePopupSuccessText,
                                         image: .success,
                                         buttonTitle: TextConstants.ok)
        
        router.presentViewController(controller: popup,
                                     animated: false,
                                     completion: nil)
    }
    
    private func deleteSelectedItems() {
        showSpinner()
        
        let selectedItems = dataSource.allSelectedItems
        stopSelectionState()
        
        dataLoader.moveToTrash(selectedItems: selectedItems) { [weak self] result in
            self?.hideSpinner()
            
            switch result {
            case .success(_):
                self?.showDeleteSuccessPopup()
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
    
    private func unhideSelectedItems() {
        showSpinner()
        
        let selectedItems = dataSource.allSelectedItems
        stopSelectionState()
        
        dataLoader.unhide(selectedItems: selectedItems) { [weak self] result in
            self?.hideSpinner()
            
            switch result {
            case .success(_):
                self?.showUnhideSuccessPopup()
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
            self?.reloadPhotos()
        }
    }
}

//MARK: - FaceImageItemsModuleOutput

extension HiddenPhotosViewController: FaceImageItemsModuleOutput {
    
    func didChangeName(item: WrapData) {}
    func didReloadData() {}
    
    func delete(item: Item) {
        remove(items: [item])
    }
}
