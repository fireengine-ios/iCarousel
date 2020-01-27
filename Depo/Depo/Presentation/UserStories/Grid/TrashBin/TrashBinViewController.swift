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
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    //MARK: - View lifecycle
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.TrashBinScreen())

        analyticsService.logScreen(screen: .trashBin)
        analyticsService.trackDimentionsEveryClickGA(screen: .trashBin)
        
        needToShowTabBar = true
        ItemOperationManager.default.startUpdateView(view: self)
        sortingManager.addBarView(to: sortPanelContainer)
        setupRefreshControl()
        setupEmptyView()
        bottomBarManager.setup()
        navbarManager.setDefaultState(sortType: dataSource.sortedRule)
        floatingButtonsArray.append(contentsOf: [.upload])
    
        interactor.output = self
        
        reloadData(needShowSpinner: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .trashBin))
        
        if dataSource.isSelectionStateActive {
            navigationBarWithGradientStyle()
        } else {
            homePageNavigationBarStyle()
        }
        navbarManager.setupNavBarButtons(animated: false)
        
        //need to fix crash on show bottom bar
        bottomBarManager.editingTabBar?.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSelectionState()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        
        if parent != nil {
            //track on each open tab of trash bin 
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .trashBin)
        }
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
        reloadData(needShowSpinner: true)
    }
    
    private func reloadData(needShowSpinner: Bool) {
        if needShowSpinner {
            showSpinner()
        }
        
        dataSource.reset()
        interactor.reloadData { [weak self] in
            guard let self = self else {
                return
            }
            
            self.collectionView.refreshControl?.endRefreshing()
            self.hideSpinner()
        }
    }
    
    private func reloadItems(needShowSpinner: Bool) {
        if needShowSpinner {
            showSpinner()
        }
        
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
        navigationBarWithGradientStyle()
        sortingManager.isActive = false
    }
    
    private func stopSelectionState() {
        navigationItem.hidesBackButton = false
        dataSource.cancelSelection()
        navbarManager.setDefaultState(sortType: dataSource.sortedRule)
        homePageNavigationBarStyle()
        bottomBarManager.hide()
        collectionView.contentInset.bottom = 0
        updateMoreButton()
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
    
    private func updateMoreButton() {
        navbarManager.updateMoreButton(hasItems: !dataSource.isEmpty)
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
    
    func onMoreButtonTapped(sender: Any, item: Item) {
        threeDotsManager.showActions(item: item, sender: sender)
    }
}

//MARK: - TrashBinSortingManagerDelegate

extension TrashBinViewController: TrashBinSortingManagerDelegate {
    func sortingRuleChanged(rule: SortedRules) {
        dataSource.sortedRule = rule
        interactor.sortedRule = rule
        reloadItems(needShowSpinner: true)
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
            self?.updateMoreButton()
        }
    }
    
    func didLoad(albums: [BaseDataSourceItem]) {
        dataSource.append(albums: albums)
        updateMoreButton()
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
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .delete))
        let selectedItems = dataSource.allSelectedItems
        interactor.delete(items: selectedItems)
    }
    
    func onBottomBarRestore() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .restore))
        let selectedItems = dataSource.allSelectedItems
        interactor.restore(items: selectedItems)
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
    
    func onThreeDotsManagerRestore(item: Item?) {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .restore))
        let selectedItems: [BaseDataSourceItem]
        if let item = item {
            selectedItems = [item]
        } else {
            selectedItems = dataSource.allSelectedItems
        }
        
        interactor.restore(items: selectedItems)
    }
    
    func onThreeDotsManagerDelete(item: Item?) {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .delete))
        let selectedItems: [BaseDataSourceItem]
        if let item = item {
            selectedItems = [item]
        } else {
            selectedItems = dataSource.allSelectedItems
        }
        
        interactor.delete(items: selectedItems)
    }
    
    func onThreeDotsManagerInfo(item: Item?) {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .info))
        guard let item = item else {
            return
        }
        router.openInfo(item: item, delegate: self)
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
    
    //MARK: Move to trash events
    
    func didMoveToTrashItems(_ items: [Item]) {
        reloadData(needShowSpinner: false)
    }
    
    func didMoveToTrashPeople(items: [PeopleItem]) {
        reloadData(needShowSpinner: false)
    }
    
    func didMoveToTrashPlaces(items: [PlacesItem]) {
        reloadData(needShowSpinner: false)
    }
    
    func didMoveToTrashThings(items: [ThingsItem]) {
        reloadData(needShowSpinner: false)
    }
    
    func didMoveToTrashAlbums(_ albums: [AlbumItem]) {
        reloadData(needShowSpinner: false)
    }
    
    //MARK: Restore events
    
    func putBackFromTrashItems(_ items: [Item]) {
        remove(items: items)
    }
    
    func putBackFromTrashAlbums(_ albums: [AlbumItem]) {
        remove(albums: albums)
    }
    
    func putBackFromTrashPeople(items: [PeopleItem]) {
        remove(albums: items)
    }
    
    func putBackFromTrashPlaces(items: [PlacesItem]) {
        remove(albums: items)
    }
    
    func putBackFromTrashThings(items: [ThingsItem]) {
        remove(albums: items)
    }
    
    //MARK: Delete events
    
    func deleteItems(items: [Item]) {
        remove(items: items)
    }
    
    func deleteStories(items: [Item]) {
        remove(items: items)
    }
    
    func albumsDeleted(albums: [AlbumItem]) {
        remove(albums: albums)
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
        dataSource.removeSlider(items: albums) { [weak self] in
            self?.reloadItems(needShowSpinner: false)
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

//MARK: - MoreFilesActionsInteractorOutput

extension TrashBinViewController: MoreFilesActionsInteractorOutput {
    
    func outputView() -> Waiting? {
        return self
    }
    
    func asyncOperationSuccess() {
        outputView()?.hideSpinner()
    }
    
    func startAsyncOperation() {
        outputView()?.showSpinner()
    }
    
    func asyncOperationFail(errorMessage: String?) {
        asyncOperationSuccess()
        showMessage(errorMessage: errorMessage)
    }
    
    func operationFinished(type: ElementTypes) {
        asyncOperationSuccess()
    }
    
    func operationFailed(type: ElementTypes, message: String) {
        asyncOperationSuccess()
        if type.isContained(in: ElementTypes.trashState) {
            showMessage(errorMessage: message)
        }
    }
    
    func operationStarted(type: ElementTypes) {
        startAsyncOperation()
    }
    
    func showWrongFolderPopup() { }
    func dismiss(animated: Bool) { }
    func startAsyncOperationDisableScreen() { }
    func completeAsyncOperationEnableScreen() { }
    func startCancelableAsync(cancel: @escaping VoidHandler) { }
    func completeAsyncOperationEnableScreen(errorMessage: String?) { }
    func startCancelableAsync(with text: String, cancel: @escaping VoidHandler) { }
    
    private func showMessage(errorMessage: String?) {
        if let message = errorMessage {
            UIApplication.showErrorAlert(message: message)
        }
    }
}

extension TrashBinViewController: FileInfoModuleOutput {
    func didRenameItem(_ item: BaseDataSourceItem) {
        guard let item = item as? Item else {
            return
        }
        dataSource.updateItem(item)
    }
}
