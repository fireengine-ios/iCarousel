//
//  PhotoVideoController.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

// TODO: todos in file
// TODO: clear code -

typealias IndexPathCallback = (_ path: IndexPath?) -> Void

final class PhotoVideoController: BaseViewController, NibInit, SegmentedChildController {

    @IBOutlet private weak var collectionView: QuickSelectCollectionView! {
        didSet {
            collectionView.dataSource = dataSource
            collectionView.delegate = self
            collectionView.longPressDelegate = self
        }
    }
    
    var isPhoto = true
    
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.baseFilesGreedCollectionDataSource)
    
    private lazy var progressQueue = DispatchQueue(label: DispatchQueueLabels.photoVideoUploadProgress, attributes: .concurrent)
    private var uploadProgressValues = [String: Float]()
    private var uploadProgress: [String: Float] {
        get {
            var result = [String: Float]()
            progressQueue.sync { result = uploadProgressValues }
            return result
        }
        
        set {
            progressQueue.async(flags: .barrier) { [weak self] in
                self?.uploadProgressValues = newValue
            }
        }
    }
    
    private var uploadedObjectID = [String]()
    
    private lazy var navBarManager = PhotoVideoNavBarManager(delegate: self)
    private lazy var collectionViewManager = PhotoVideoCollectionViewManager(collectionView: self.collectionView, delegate: self)
    private lazy var threeDotMenuManager = PhotoVideoThreeDotMenuManager(delegate: self)
    private lazy var bottomBarManager = PhotoVideoBottomBarManager(delegate: self)
    private lazy var dataSource = PhotoVideoDataSource(collectionView: self.collectionView, delegate: self)
    private lazy var analyticsManager: AnalyticsService = factory.resolve()
    private lazy var scrollDirectionManager = PhotoVideoScrollDirectionManager()
    private lazy var instaPickRoutingService = InstaPickRoutingService()

    private lazy var assetsFileCacheManager = AssetFileCacheManager()
    
    private let scrollBarManager = PhotoVideoScrollBarManager()

    private lazy var quickScrollService = QuickScrollService()
    
    private lazy var filesDataSource = FilesDataSource()
    
    private lazy var router = RouterVC()
    
    private var canShowDetail = true
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bottomBarManager.setup()
        collectionViewManager.setup()
        collectionViewManager.collectionViewLayout.delegate = dataSource
        navBarManager.setDefaultMode()
        homePageNavigationBarStyle()
        
        needToShowTabBar = true
        floatingButtonsArray.append(contentsOf: [.takePhoto, .upload, .createAStory, .createAlbum])
        ItemOperationManager.default.startUpdateView(view: self)
        
        scrollBarManager.addScrollBar(to: collectionView, delegate: self)
        performFetch()
    }
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.trackPhotoVideoScreen(isPhoto: isPhoto)
        
        bottomBarManager.editingTabBar?.view.layoutIfNeeded()
        collectionViewManager.setScrolliblePopUpView(isActive: true)
        scrollBarManager.startTimerToHideScrollBar()
        
        ///trigger Range API for update new items which are uploaded by other clients
        updateDB()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.setupNavigationBar(editingMode: false)

        dataSource.getSelectedObjects(at: collectionViewManager.selectedIndexes) { [weak self] selectedItems in
            guard let self = self else {
                return
            }
            
            if !selectedItems.isEmpty {
                self.setupNavigationBar(editingMode: true)
                self.updateSelectedItemsCount()
                self.updateBarsForSelectedObjects()
            }
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopEditingMode()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        collectionViewManager.setScrolliblePopUpView(isActive: false)
    }

    
    // MARK: - setup
    
    private func performFetch() {
        dataSource.setupOriginalPredicates(isPhotos: isPhoto) { [weak self] in
            DispatchQueue.main.async {
                self?.fetchAndReload()
                self?.collectionViewManager.reloadAlbumsSlider()
            }
        }
    }
    
    private func fetchAndReload() {
        CellImageManager.clear()
        assetsFileCacheManager.resetCachedAssets()
        dataSource.performFetch()
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func scrollToItem(_ item: Item) {
        dataSource.scrollToItem(item)
    }
    
    // MARK: - Editing Mode
    
    private func startEditingMode(at indexPath: IndexPath?) {
        guard !dataSource.isSelectingMode else {
            return
        }
        dataSource.isSelectingMode = true
        deselectAllCells()

        setupNavigationBar(editingMode: true)
        updateSelectedItemsCount()
        updateBarsForSelectedObjects()
    }
    
    private func stopEditingMode() {
        dataSource.isSelectingMode = false
        deselectAllCells()
        bottomBarManager.hide()
        setupNavigationBar(editingMode: false)
    }
    

    private func deselectAllCells() {
        collectionViewManager.deselectAll()
        collectionView.visibleCells.forEach { cell in
            (cell as? PhotoVideoCell)?.updateSelection(isSelectionMode: dataSource.isSelectingMode, animated: false)
        }
    }

    
    private func setupNavigationBar(editingMode: Bool) {
        /// don't let vc to change navBar if vc is not visible at this moment
        guard viewIfLoaded?.window != nil else {
            return
        }
        
        /// be sure to configure navbar items after setup navigation bar
        if editingMode {
            navigationBarWithGradientStyle()
            navBarManager.setSelectionMode()
        } else {
            homePageNavigationBarStyle()
            navBarManager.setDefaultMode()
        }
    }
    
    // MARK: - helpers
    
    private func updateSelectedItemsCount() {
        let selectedIndexesCount = collectionViewManager.selectedIndexes.count
        self.setTitle("\(selectedIndexesCount) \(TextConstants.accessibilitySelected)")
    }
    
    private func updateBarsForSelectedObjects() {
        let selectedIndexes = collectionViewManager.selectedIndexes
        dataSource.getSelectedObjects (at: selectedIndexes) { [weak self] selectedObjects in
            guard let self = self else {
                return
            }
            self.bottomBarManager.update(for: selectedObjects)
            
            if selectedIndexes.count == 0 {
                self.navBarManager.threeDotsButton.isEnabled = false
                self.bottomBarManager.hide()
            } else {
                if self.isPhoto {
                    self.navBarManager.threeDotsButton.isEnabled = true
                } else {
                    let hasRemote = selectedObjects.first { !$0.isLocalItem } != nil
                    self.navBarManager.threeDotsButton.isEnabled = hasRemote
                }
                self.bottomBarManager.show()
            }
        }
    }
    
    private func showDetail(at indexPath: IndexPath) {
        guard canShowDetail else {
            return
        }
        
        canShowDetail = false
        trackClickOnPhotoOrVideo(isPhoto: isPhoto)

        dataSource.getWrapedFetchedObjects { [weak self] items in
            self?.dataSource.getObject(at: indexPath) { [weak self] object in
                guard let self = self else {
                    return
                }
                
                guard let currentMediaItem = object,
                let currentObject = items.first(where: {$0.uuid == currentMediaItem.uuid}) else {
                    self.canShowDetail = true
                    self.hideSpinner()
                    return
                }
                
                DispatchQueue.toMain {
                    self.hideSpinner()
                    let detailModule = self.router.filesDetailModule(fileObject: currentObject,
                                                                items: items,
                                                                status: .active,
                                                                canLoadMoreItems: false,
                                                                moduleOutput: nil)

                    let nController = NavigationController(rootViewController: detailModule.controller)
                    self.router.presentViewController(controller: nController)
                    self.canShowDetail = true
                }
            }
        }
    }
    
    private func updateSelection(cell: PhotoVideoCell) {
        cell.updateSelection(isSelectionMode: self.dataSource.isSelectingMode, animated: false)
        updateSelectedItemsCount()
        
        ///fix bottom bar update scrolling freeze on dragging
        guard !collectionView.isQuickSelecting else {
            return
        }
        
        updateBarsForSelectedObjects()
    }
    
    private func trackClickOnPhotoOrVideo(isPhoto: Bool) {
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .click, eventLabel: isPhoto ? .clickPhoto : .clickVideo)
    }
    
    private func trackPhotoVideoScreen(isPhoto: Bool) {
        AnalyticsService.sendNetmeraEvent(event: isPhoto ? NetmeraEvents.Screens.PhotosScreen() : NetmeraEvents.Screens.VideosScreen())
        analyticsManager.logScreen(screen: isPhoto ? .photos : .videos)
        analyticsManager.trackDimentionsEveryClickGA(screen: isPhoto ? .photos : .videos)
    }
    
    private func showSearchScreen() {
        let controller = router.searchView(navigationController: navigationController)
        router.pushViewController(viewController: controller)
    }
    
    private func updateScrollBarTextIfNeed() {
        guard scrollBarManager.scrollBar.isDragging else {
            return
        }
        updateScrollBarText()
    }
    
    // TODO: add this method when will be need to show scrollBar (end of adding files to DB)
    private func updateScrollBarText() {
        guard let indexPath = collectionView.indexPathsForVisibleItems.min(by: <) else {
            return
        }
        
        dataSource.getObject(at: indexPath) { [weak self] object in
            guard let mediaItem = object, let date = mediaItem.sortingDate as Date? else {
                return
            }
            let title = date.getDateInTextForCollectionViewHeader()
            self?.scrollBarManager.scrollBar.setText(title)
        }
    }
}

extension PhotoVideoController: QuickSelectCollectionViewDelegate {
    func didLongPress(at indexPath: IndexPath?) {
        if !dataSource.isSelectingMode {
            startEditingMode(at: indexPath)
        }
    }
    
    func didEndLongPress(at indexPath: IndexPath?) {
        if dataSource.isSelectingMode {
            self.updateSelectedItemsCount()
            self.updateBarsForSelectedObjects()
        }
    }
}


// MARK: - UIScrollViewDelegate
extension PhotoVideoController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        assetsFileCacheManager.updateCachedAssets(on: collectionView, itemProviderClosure: itemProviderClosure)
        updateScrollBarTextIfNeed()
        scrollBarManager.scrollViewDidScroll()
        scrollBarManager.hideScrollBarIfNeed(for: scrollView.contentOffset.y)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollDirectionManager.handleScrollBegin(with: scrollView.contentOffset)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            handleScrollEnd(with: scrollView.contentOffset)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleScrollEnd(with: scrollView.contentOffset)
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        handleScrollEnd(with: scrollView.contentOffset)
    }
    
    /// if scroll programmatically
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        handleScrollEnd(with: scrollView.contentOffset)
    }
    
    private func handleScrollEnd(with offset: CGPoint) {
        scrollDirectionManager.handleScrollEnd(with: offset)
        scrollBarManager.startTimerToHideScrollBar()
        updateDB()
    }
    
    private func updateDB() {
        print("updateDB with direction: \(scrollDirectionManager.scrollDirection)")
        guard CacheManager.shared.isCacheActualized else {
            return
        }
        
        guard
            let workaroundVisibleIndexes = self.collectionView?.indexPathsForVisibleItems.sorted(by: <)
        else {
            return
        }
        rangeAPIInfo(at: workaroundVisibleIndexes.first) { [weak self] topAPIInfo in
            self?.self.rangeAPIInfo(at: workaroundVisibleIndexes.last) { [weak self] bottomAPIInfo in
                guard let topAPIInfo = topAPIInfo,
                    let bottomAPIInfo = bottomAPIInfo else {
                    return
                }
                self?.dispatchQueue.async { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    
                    var startId: Int64?
                    var endId: Int64?
                    if topAPIInfo.date == bottomAPIInfo.date {
                        startId = topAPIInfo.id
                        endId = bottomAPIInfo.id
                    }
                    
                    let category: QuickScrollCategory = self.isPhoto ? .photos : .videos
                    let fileType: FileType = self.isPhoto ? .image : .video
                    self.quickScrollService.requestListOfDateRange(startDate: topAPIInfo.date, endDate: bottomAPIInfo.date, startID: startId, endID: endId, category: category, pageSize: RequestSizeConstant.quickScrollRangeApiPageSize) { response in
                        switch response {
                        case .success(let quckScrollResponse):
                            self.dispatchQueue.async {
                                MediaItemOperationsService.shared.updateRemoteItems(remoteItems: quckScrollResponse.files, fileType: fileType, topInfo: topAPIInfo, bottomInfo: bottomAPIInfo, completion: {
                                    debugPrint("appended and updated")
                                })
                            }
                        case .failed(_):
                            ///may be canceled request
                            break///TODO: popup here?
                        }
                    }
                }
            }
        }
    }
    
    private func rangeAPIInfo(at index: IndexPath?, rangeApiInfo: @escaping (RangeAPIInfo?) -> Void) {
        guard let objectIndex = index else {
            return
        }
        
        dataSource.getObject(at: objectIndex) { [weak self] object in
            guard let self = self else {
                return
            }
            
            let objectId = object?.idValue
            let isLastIndex = self.isLast(indexPath: objectIndex)
            let isFirstIndex = (objectIndex.section == 0 && objectIndex.row == 0)
            
            guard !isFirstIndex else {
                /// return Date.distantFuture to have the top items, because user may have wrong date on his device.
                rangeApiInfo(RangeAPIInfo(date: Date.distantFuture, id: nil))
                return
            }
            
            guard !isLastIndex else {
                /// return Date.distantPast to have the bottom items
                rangeApiInfo(RangeAPIInfo(date: Date.distantPast, id: nil))
                return
            }
            
            /// check if it's one of missing dates
            guard object?.monthValue != nil, let sortingDate = object?.sortingDate as Date? else {
                rangeApiInfo(RangeAPIInfo(date: Date.distantPast, id: nil))
                return
            }
            
            rangeApiInfo( RangeAPIInfo(date: sortingDate, id: objectId))
        }
        
    }
    
    private func isLast(indexPath: IndexPath) -> Bool {
        let lastSectionNumber = dataSource.numberOfSections(in: collectionView) - 1
        let lastRowNumber = dataSource.collectionView(collectionView, numberOfItemsInSection: lastSectionNumber) - 1
        let lastIndexPath = IndexPath(row: lastRowNumber, section: lastSectionNumber)
        
        return indexPath == lastIndexPath
    }
    
}

// MARK: - UICollectionViewDelegate
extension PhotoVideoController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoVideoCell else {
            return
        }
        cell.filesDataSource = filesDataSource
        
        //Questinable
        dataSource.getObject(at: indexPath) { [weak self] object in
            guard let self = self,
                let object = object else {
                return
            }
            
            cell.setup(with: object)
            
            guard let trimmedLocalFileID = object.trimmedLocalFileID else {
                return
            }
            
            if let progress = self.uploadProgress[trimmedLocalFileID], object.isLocalItemValue {
                cell.setProgressForObject(progress: progress, blurOn: true)
            } else {
                cell.cancelledUploadForObject()
            }
            
            cell.updateSelection(isSelectionMode: self.dataSource.isSelectingMode, animated: true)
            
            if let uuid = object.uuid, self.uploadedObjectID.index(of: uuid) != nil {
                cell.finishedUploadForObject()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let photoCell = cell as? PhotoVideoCell {
            photoCell.didEndDisplay()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoVideoCell else {
            return
        }
        if dataSource.isSelectingMode {
            updateSelection(cell: cell)
        } else {
            showDetail(at: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoVideoCell else {
            return
        }
        
        if dataSource.isSelectingMode {
            updateSelection(cell: cell)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        /// fixing iOS11 UICollectionSectionHeader clipping scroll indicator
        /// https://stackoverflow.com/a/46930410/5893286
        if #available(iOS 11.0, *), elementKind == UICollectionElementKindSectionHeader {
            view.layer.zPosition = 0
        }
        guard let view = view as? CollectionViewSimpleHeaderWithText else {
            return
        }
        
        dataSource.getObject(at: indexPath) { object in
            if let mediaItem = object {
                view.setup(with: mediaItem)
            }
        }
    }
}

// MARK: - BaseItemInputPassingProtocol 
/// using: bottomBarPresenter.basePassingPresenter = self, PhotoVideoThreeDotMenuManager(delegate: self)
extension PhotoVideoController: BaseItemInputPassingProtocol {

    func openInstaPick() {
        showSpinner()
        instaPickRoutingService.getViewController(isCheckAnalyzesCount: true, success: { [weak self] vc in
            guard let self = self else {
                return
            }
            
            self.hideSpinner()
            if vc is InstapickPopUpController || vc is InstaPickSelectionSegmentedController {
                let navController = self.router.createRootNavigationControllerWithModalStyle(controller: vc)
                self.router.presentViewController(controller: navController)
            }
        }) { [weak self] error in
            self?.showAlert(with: error.description)
        }
    }
    
    func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems) {
        DispatchQueue.toMain {
            self.dataSource.getSelectedObjects (at: self.collectionViewManager.selectedIndexes) { items in
                selectedItemsCallback(items)
            }
        }
    }
    
    func stopModeSelected() {
        stopEditingMode()
    }
    
    func selectModeSelected() {
        startEditingMode(at: nil)
    }
    
    func operationFinished(withType type: ElementTypes, response: Any?) {}
    func operationFailed(withType type: ElementTypes) {}
    func selectAllModeSelected() {}
    func deSelectAll() {}
    func printSelected() {
        dataSource.getSelectedObjects (at: collectionViewManager.selectedIndexes) { [weak self] selectedObjects in
            guard let self = self else {
                return
            }
            let syncPhotos = selectedObjects.filter { !$0.isLocalItem && $0.fileType == .image }
            
            if let itemsToPrint = syncPhotos as? [Item], !itemsToPrint.isEmpty {
                let vc = PrintInitializer.viewController(data: itemsToPrint)
                self.router.pushOnPresentedView(viewController: vc)
            }
            self.stopEditingMode()
        }
        
    }
    func changeCover() {}
}

// MARK: - PhotoVideoNavBarManagerDelegate
extension PhotoVideoController: PhotoVideoNavBarManagerDelegate {
    
    func onCancelSelectionButton() {
        stopEditingMode()
    }
    
    func onThreeDotsButton() {
        dataSource.getSelectedObjects (at: collectionViewManager.selectedIndexes) { [weak self] selectedObjects in
            guard let self = self else {
                return
            }
            self.threeDotMenuManager.showActions(for: selectedObjects, isSelectingMode: self.dataSource.isSelectingMode, isPhoto: self.isPhoto, sender: self.navBarManager.threeDotsButton)
        }
        
    }
    
    func onSearchButton() {
        showSearchScreen()
    }
}

// MARK: - PhotoVideoCollectionViewManagerDelegate
/// using: PhotoVideoCollectionViewManager(collectionView: self.collectionView, delegate: self)
extension PhotoVideoController: PhotoVideoCollectionViewManagerDelegate {
    func refreshData(refresher: UIRefreshControl) {
        collectionViewManager.reloadAlbumsSlider()
        refresher.endRefreshing()
    }
    
    func showOnlySyncItemsCheckBoxDidChangeValue(_ value: Bool) {
        dataSource.changeSourceFilter(syncOnly: value, isPhotos: isPhoto, newPredicateSetupedCallback: { [weak self] in
            DispatchQueue.main.async {
                self?.fetchAndReload()
            }
        })
    }
    
    func openAutoSyncSettings() {
        router.pushViewController(viewController: router.autoUpload)
    }
}

//extension PhotoVideoController: SegmentedControllerDelegate {
//}


// MARK: - ItemOperationManagerViewProtocol
/// using: ItemOperationManager.default.startUpdateView(view:
extension PhotoVideoController: ItemOperationManagerViewProtocol {
    
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        if let compairedView = object as? PhotoVideoController {
            return compairedView == self
        }
        return false
    }
    
    func setProgressForUploadingFile(file: WrapData, progress: Float) {
        guard file.isLocalItem else {
            return
        }
        let localId = file.getTrimmedLocalID()
        self.uploadProgress[localId] = progress
        self.getCellInVisibleIndexRange(objectTrimmedLocalID: localId) { cell in
            cell?.setProgressForObject(progress: progress, blurOn: true)
        }
    }
    
    func startUploadFile(file: WrapData) {
        guard file.isLocalItem else {
            return
        }
        let progress: Float = 0
        let id = file.getTrimmedLocalID()
        self.uploadProgress[id] = progress
        self.getVisibleCellForLocalFile(objectTrimmedLocalID: file.getTrimmedLocalID()) { cell in
            cell?.setProgressForObject(progress: progress, blurOn: true)
        }
        
    }
    
    func finishedUploadFile(file: WrapData) {
        let trimmedLocalID = file.getTrimmedLocalID()
        uploadProgress.removeValueSafely(forKey: trimmedLocalID)
        
        let uuid = file.uuid
        if uploadedObjectID.index(of: uuid) == nil {
            uploadedObjectID.append(uuid)
        }
        
        DispatchQueue.toMain {
            self.getCellForTrimmedID(objectTrimmedLocalID: trimmedLocalID) { [weak self] cell in
                self?.postFinishedUploadFileAction(file: file)
            }
            
        }
        
    }
    
    private func postFinishedUploadFileAction(file: WrapData) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: { [weak self] in
            guard let self = self else {
                return
            }
            self.dataSource.getIndexPathForObject(uuid: file.uuid) { [weak self] indexPath in
                guard let self = self else {
                    return
                }
                if let path = indexPath,
                    self.collectionView.indexPathsForVisibleItems.contains(path) {
                    self.dataSource.getObject(at: path, mediaItemCallback: { [weak self] object in
                        guard let self = self, let object = object,
                            let cell = self.collectionView.cellForItem(at: path) as? PhotoVideoCell else {
                                return
                        }
                        if object.isLocalItemValue {
                            cell.showCloudImage()
                        } else {
                            cell.resetCloudImage()
                        }
                    })
                }
            }
            if let index = self.uploadedObjectID.index(of: file.uuid) {
                self.uploadedObjectID.remove(at: index)
            }
        })

    }
    
    func failedUploadFile(file: WrapData, error: Error?) {
        cancellVisibleCellProgress(trimmedID: file.getTrimmedLocalID())
    }
    
    func cancelledUpload(file: WrapData) {
        cancellVisibleCellProgress(trimmedID: file.getTrimmedLocalID())
    }
    
    private func cancellVisibleCellProgress(trimmedID: String) {
        
        uploadProgress.removeValueSafely(forKey: trimmedID)
        
        DispatchQueue.toMain {
            self.getVisibleCellForLocalFile(objectTrimmedLocalID: trimmedID) { cell in
                cell?.cancelledUploadForObject()
            }
        }
    }
    
    func syncFinished() {
        let trimmedIDs = Array(uploadProgress.keys)
        guard !trimmedIDs.isEmpty else {
            return
        }
        
        DispatchQueue.toMain {
            trimmedIDs.forEach({ trimmedID in
                DispatchQueue.toMain {
                    self.getVisibleCellForLocalFile(objectTrimmedLocalID: trimmedID) { cell in
                        cell?.cancelledUploadForObject()
                    }
                }
            })
            self.uploadProgress.removeAll()
        }
    }
    
    func filesAddedToAlbum() {
        stopEditingMode()
    }
    
    private func getCellForFile(objectUUID: String, completion: @escaping (_ cell: PhotoVideoCell?) -> Void)
{
        dataSource.getIndexPathForRemoteObject(itemUUID: objectUUID) { [weak self] indexPath in
            guard let path = indexPath,
            let cell = self?.collectionView?.cellForItem(at: path) as? PhotoVideoCell else {
                completion(nil)
                return
            }
            completion(cell)
        }
    }
    
    private func getCellForLocalFile(objectTrimmedLocalID: String, completion: @escaping  (_ cell: PhotoVideoCell?)->Void) {
        dataSource.getIndexPathForLocalObject(itemTrimmedLocalID: objectTrimmedLocalID) { [weak self] indexPath in
            guard let path = indexPath else {
                completion(nil)
                return
            }
             completion(self?.collectionView?.cellForItem(at: path) as? PhotoVideoCell)
        }
    }
    
    private func getCellForTrimmedID(objectTrimmedLocalID: String, completion: @escaping  (_ cell: PhotoVideoCell?)->Void) {
        dataSource.indexPath(itemTrimmedLocalID: objectTrimmedLocalID) { [weak self] indexPath in
            guard let path = indexPath else {
                completion(nil)
                return
            }
             completion(self?.collectionView?.cellForItem(at: path) as? PhotoVideoCell)
        }
    }

    private func getCellInVisibleIndexRange(objectTrimmedLocalID: String, completion: @escaping  (_ cell: PhotoVideoCell?)->Void) {
        dataSource.findLocalFileIndexForObjectInVisibleRange(itemTrimmedLocalID: objectTrimmedLocalID) { [weak self] index in
            guard
                let index = index,
                let cell = self?.collectionView.cellForItem(at: index) as? PhotoVideoCell
            else {
                completion(nil)
                return
            }
           completion(cell)
        }

    }
    
    private func getVisibleCellForLocalFile(objectTrimmedLocalID: String, completion: @escaping  (_ cell: PhotoVideoCell?)->Void) {
        getCellForLocalFile(objectTrimmedLocalID: objectTrimmedLocalID) { [weak self] cell in
            guard
                let self = self,
                let cell = cell,
                self.collectionView.visibleCells.contains(cell)
            else {
                completion(nil)
                return
            }
            completion(cell)
        }
        
    }
    
    func deleteItems(items: [Item]) {
        stopEditingMode()
    }
    
    func didMoveToTrashItems(_ items: [Item]) {
        stopEditingMode()
    }
    
    func didHideItems(_ items: [WrapData]) {
        stopEditingMode()
    }
    
    func didHideAlbums(_ albums: [AlbumItem]) {
        stopEditingMode()
    }
 
    func didUnhideItems(_ items: [WrapData]) {
        stopEditingMode()
    }
}

extension PhotoVideoController {
    static func initPhotoFromNib() -> PhotoVideoController {
        let photoController = PhotoVideoController.initFromNib()
        photoController.isPhoto = true
        photoController.title = TextConstants.topBarPhotosFilter
        return photoController
    }
    
    static func initVideoFromNib() -> PhotoVideoController {
        let videoController = PhotoVideoController.initFromNib()
        videoController.isPhoto = false
        videoController.title = TextConstants.topBarVideosFilter
        return videoController
    }
}

//MARK: - ScrollBarViewDelegate

extension PhotoVideoController: ScrollBarViewDelegate {
    func scrollBarViewBeganDragging() {
        scrollBarManager.yearsView.showAnimated()
    }
    
    func scrollBarViewDidEndDragging() {
        updateScrollBarTextIfNeed()
        scrollBarManager.yearsView.hideAnimated()
        handleScrollEnd(with: .zero)
    }
}

//MARK: - PhotoVideoDataSource

extension PhotoVideoController: PhotoVideoDataSourceDelegate {
    func selectedModeDidChange(_ selectingMode: Bool) {
        collectionView.isQuickSelectAllowed = selectingMode
    }
    
    func fetchPredicateCreated() { }
    
    func contentDidChange(_ fetchedObjects: [MediaItem]) {
//        DispatchQueue.toMain {
        ///Already called from context
            self.scrollBarManager.updateYearsView(with: fetchedObjects,
                                                  cellHeight: self.collectionViewManager.collectionViewLayout.itemSize.height,
                                                  numberOfColumns: Int(self.collectionViewManager.collectionViewLayout.columns))
//        }
    }
    
    func convertFetchedObjectsInProgress() {
        showSpinner()
    }
}
