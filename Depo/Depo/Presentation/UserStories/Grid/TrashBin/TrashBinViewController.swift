//
//  TrashBinViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class TrashBinViewController: BaseViewController, NibInit, SegmentedChildController {

    @IBOutlet weak var headerStackView: UIStackView!
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
    
    weak var photoVideoDetailModule: PhotoVideoDetailModuleInput? //no need for stong reference, since we need it till ViewController is alive
    
    private lazy var countView: GridListCountView  = {
        let view = GridListCountView.initFromNib()
        view.delegate = self
        return view
    }()
    
    //MARK: - View lifecycle
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTrashBin()
    }
    
    private func initTrashBin() {
        needToShowTabBar = true
        ItemOperationManager.default.startUpdateView(view: self)
        sortingManager.addBarView(to: sortPanelContainer)
        setupRefreshControl()
        setupEmptyView()
        bottomBarManager.setup()
        navbarManager.setDefaultState(sortType: dataSource.sortedRule)
        floatingButtonsArray.append(contentsOf: [])
    
        interactor.output = self
        
        reloadData(needShowSpinner: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .trashBin))
        
        navbarManager.setupNavBarButtons(animated: false)
        
        //need to fix crash on show bottom bar
        bottomBarManager.editingTabBar?.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSelectionState()
        countView.removeFromSuperview()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        if parent != nil {
            //track on each open tab of trash bin 
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .trashBin)
            
            analyticsService.logScreen(screen: .trashBin)
            analyticsService.trackDimentionsEveryClickGA(screen: .trashBin)
            
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.TrashBinScreen())
        }
    }
    
    func configureCountView(isShown: Bool) {
        countView.removeFromSuperview()
        
        if isShown {
            headerStackView.addArrangedSubview(countView)
        }
    }
    
    func setCountView(selectedItemsCount: Int) {
        countView.setCountLabel(with: selectedItemsCount)
    }
    
    func selectedItemsCountChange(with count: Int) {
        let title = String(count) + " " + TextConstants.accessibilitySelected
        setTitle(withString: title)
        let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
        navigationItem.title = title
         
        setCountView(selectedItemsCount: count)
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

extension TrashBinViewController: GridListCountViewDelegate {
    func cancelSelection() {
        configureCountView(isShown: false)
        bottomBarManager.hide()
        collectionView.contentInset.bottom = 0
        stopSelectionState()
    }
}

// MARK: - Selection State Methods

extension TrashBinViewController {
    private func startSelectionState() {
        navigationItem.hidesBackButton = true
        //sortingManager.isActive = false
        /// Necessary, if you want to hide or show sortPanelContainer
        //navbarManager.setSelectionState()
    }
    
    private func stopSelectionState() {
        navigationItem.hidesBackButton = false
        dataSource.cancelSelection()
        bottomBarManager.hide()
        collectionView.contentInset.bottom = 0
//        navbarManager.setDefaultState(sortType: dataSource.sortedRule)
//        updateMoreButton()
        
        /// Necessary, if you want to hide or show sortPanelContainer
        //sortingManager.isActive = true
    }
    
    private func updateBarsForSelectedObjects(count: Int) {
//        navbarManager.changeSelectionItems(count: count)

        if count == 0 {
            bottomBarManager.hide()
            collectionView.contentInset.bottom = 0
            configureCountView(isShown: false)
            stopSelectionState()
            
        } else {
            startSelectionState()
            bottomBarManager.show()
            collectionView.contentInset.bottom = 40
            selectedItemsCountChange(with: count)
            configureCountView(isShown: true)
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
        let sameTypeItems = dataSource.getSameTypeItems(for: item.fileType, from: dataSource.allItems.flatMap { $0 })
        router.openSelected(item: item, sameTypeItems: sameTypeItems, delegate: self)
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
    
    func didSelectActionInMenu(action: ActionType, item: Item) {
        threeDotsManager.handleAction(type: action, item: item)
    }
}

//MARK: - TrashBinSortingManagerDelegate

extension TrashBinViewController: TrashBinSortingManagerDelegate {
    func onMoreButton(sender: Any) {
        threeDotsManager.showActions(isSelectingMode: dataSource.isSelectionStateActive, sender: self)
    }
    
    func filterChanged(filter: MoreActionsConfig.MoreActionsFileType) {
        
    }
    
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
        if let fileType = photoVideoDetailModule?.itemsType {
            let sameTypeItems = dataSource.getSameTypeItems(for: fileType, from: items)
            photoVideoDetailModule?.appendItems(sameTypeItems, isLastPage: false)
        }

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
        photoVideoDetailModule?.appendItems([], isLastPage: true)
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
        interactor.delete(items: selectedItems) { [weak self] in
            self?.bottomBarManager.hide()
        }
    }
    
    func onBottomBarRestore() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .restore))
        let selectedItems = dataSource.allSelectedItems
        interactor.restore(items: selectedItems) { [weak self] in
            self?.bottomBarManager.hide()
        }
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
        
        interactor.restore(items: selectedItems) {
            debugPrint("Restore is Done")
        }
    }
    
    func onThreeDotsManagerDelete(item: Item?) {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .delete))
        let selectedItems: [BaseDataSourceItem]
        if let item = item {
            selectedItems = [item]
        } else {
            selectedItems = dataSource.allSelectedItems
        }
        
        interactor.delete(items: selectedItems) {
            debugPrint("Delete is Done")
        }
    }
    
    func onThreeDotsManagerInfo(item: Item?) {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .info))
        guard let item = item else {
            return
        }
        router.openInfo(item: item)
    }
    
    func onThreeDotsManagerDeleteAll() {
        interactor.emptyTrashBin()
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
                self.router.openFIRAlbum(album: album, item: item)
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
    
    func didRenameItem(_ item: BaseDataSourceItem) {
        guard let item = item as? Item else {
            return
        }
        dataSource.updateItem(item)
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
        let customAlbums = albums.filter { !$0.fileType.isFaceImageAlbum }
        if !customAlbums.isEmpty {
            reloadData(needShowSpinner: false)
        }
    }
    
    //MARK: Restore events
    
    func putBackFromTrashItems(_ items: [Item]) {
        remove(items: items)
    }
    
    func putBackFromTrashAlbums(_ albums: [AlbumItem]) {
        let customAlbums = albums.filter { !$0.fileType.isFaceImageAlbum }
        remove(albums: customAlbums)
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
    
    func didEmptyTrashBin() {
        reloadData(needShowSpinner: true)
    }
    
    private func remove(items: [Item]) {
        reloadAlbums()
        dataSource.remove(items: items) { [weak self] in
            self?.checkEmptyView()
        }
    }
    
    private func remove(albums: [BaseDataSourceItem]) {
        if albums.isEmpty {
            return
        }
        
        dataSource.removeSlider(items: albums) { [weak self] in
            self?.reloadItems(needShowSpinner: false)
        }
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
        if type.isContained(in: [.restore, .delete, .emptyTrashBin]) {
            showMessage(errorMessage: message)
        }
    }
    
    func operationStarted(type: ElementTypes) {
        stopSelectionState()
        startAsyncOperation()
    }
    
    func operationCancelled(type: ElementTypes) {
        asyncOperationSuccess()
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

//MARK: - PhotoVideoDetailModuleOutput

extension TrashBinViewController: PhotoVideoDetailModuleOutput {
    func needLoadNextPage() {
        debugPrint("needLoadNextPage")
        interactor.loadNextItemsPage()
    }
}
