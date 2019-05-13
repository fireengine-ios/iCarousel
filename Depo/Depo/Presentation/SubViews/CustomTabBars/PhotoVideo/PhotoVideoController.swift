//
//  PhotoVideoController.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

// TODO: items storage with remotes

// TODO: CheckBoxViewDelegate logic
// TODO: video controller
// TODO: duplicated files correct representation on collection
// TODO: items operations (progress)
// TODO: todos in file
// TODO: clear code -

final class PhotoVideoController: BaseViewController, NibInit, SegmentedChildController {

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = dataSource
            collectionView.delegate = self
        }
    }
    
    var isPhoto = true
    
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.baseFilesGreedCollectionDataSource)
    private var uploadedObjectID = [String]()
    private var uploadProgress = [String: Float]()
    
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
    
    private var canShowDetail = true
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bottomBarManager.setup()
        collectionViewManager.setup()
        collectionViewManager.collectionViewLayout.delegate = dataSource
        navBarManager.setDefaultMode()
        
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

        bottomBarManager.editingTabBar?.view.layoutIfNeeded()
        collectionViewManager.setScrolliblePopUpView(isActive: true)
        scrollBarManager.startTimerToHideScrollBar()
        
        ///trigger Range API for update new items which are uploaded by other clients
        updateDB()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        homePageNavigationBarStyle()
        
        if !selectedItems.isEmpty {
            onChangeSelectedItemsCount(selectedItemsCount: dataSource.selectedIndexPaths.count)
            navBarManager.setSelectionMode()
            navigationBarWithGradientStyle()
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
    
    // MARK: - Editing Mode
    
    private func startEditingMode(at indexPath: IndexPath?) {
        guard !dataSource.isSelectingMode else {
            return
        }
        dataSource.isSelectingMode = true
        deselectVisibleCells()
        
        if let indexPath = indexPath {
            dataSource.selectedIndexPaths.insert(indexPath)
            if let selectedCell = collectionView.cellForItem(at: indexPath) as? PhotoVideoCell {
                selectedCell.set(isSelected: true, isSelectionMode: true, animated: true)
            }
        }
        
        onChangeSelectedItemsCount(selectedItemsCount: dataSource.selectedIndexPaths.count)
        navBarManager.setSelectionMode()
        navigationBarWithGradientStyle()
    }
    
    private func stopEditingMode() {
        dataSource.isSelectingMode = false
        dataSource.selectedIndexPaths.removeAll()
        deselectVisibleCells()
        bottomBarManager.hide()
        navBarManager.setDefaultMode()
        homePageNavigationBarStyle()
    }
    
    private func deselectVisibleCells() {
        collectionView.visibleCells.forEach { cell in
            (cell as? PhotoVideoCell)?.set(isSelected: false, isSelectionMode: dataSource.isSelectingMode, animated: true)
        }
    }
    
    // MARK: - helpers
    
    private func onChangeSelectedItemsCount(selectedItemsCount: Int) {
        bottomBarManager.update(for: dataSource.selectedObjects)
        
        if selectedItemsCount == 0 {
            navBarManager.threeDotsButton.isEnabled = false
            bottomBarManager.hide()
        } else {
            navBarManager.threeDotsButton.isEnabled = true
            bottomBarManager.show()
        }
        
        setTitle("\(selectedItemsCount) \(TextConstants.accessibilitySelected)")
    }
    
    private func showDetail(at indexPath: IndexPath) {
        // TODO: trackClickOnPhotoOrVideo(isPhoto: false)
        guard canShowDetail else {
            return
        }
        
        canShowDetail = false
        trackClickOnPhotoOrVideo(isPhoto: true)

        dataSource.getWrapedFetchedObjects { [weak self] items in
            guard let currentMediaItem = self?.dataSource.object(at: indexPath),
                let currentObject = items.first(where: {$0.uuid == currentMediaItem.uuid}) else {
                self?.canShowDetail = true
                self?.hideSpinner()
                return
            }
            
            DispatchQueue.toMain {
                self?.hideSpinner()
                let router = RouterVC()
                let controller = router.filesDetailViewController(fileObject: currentObject, items: items)
                let nController = NavigationController(rootViewController: controller)
                router.presentViewController(controller: nController)
                self?.canShowDetail = true
            }
        }
    }
    
    private func select(cell: PhotoVideoCell, at indexPath: IndexPath) {
        let isSelectedCell = dataSource.selectedIndexPaths.contains(indexPath)
        
        if isSelectedCell {
            dataSource.selectedIndexPaths.remove(indexPath)
        } else {
            dataSource.selectedIndexPaths.insert(indexPath)
        }
        
        cell.set(isSelected: !isSelectedCell, isSelectionMode: dataSource.isSelectingMode, animated: true)
        onChangeSelectedItemsCount(selectedItemsCount: dataSource.selectedIndexPaths.count)
    }
    
    private func trackClickOnPhotoOrVideo(isPhoto: Bool) {
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .click, eventLabel: isPhoto ? .clickPhoto : .clickVideo)
    }
    
    private func showSearchScreen() {
        let router = RouterVC()
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
        
        guard let mediaItem = dataSource.object(at: indexPath), let date = mediaItem.sortingDate as Date? else {
            return
        }
        let title = date.getDateInTextForCollectionViewHeader()
        scrollBarManager.scrollBar.setText(title)
    }
}

// MARK: - PhotoVideoCellDelegate
extension PhotoVideoController: PhotoVideoCellDelegate {
    func onLongPressBegan(at cell: PhotoVideoCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            startEditingMode(at: indexPath)
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
            let workaroundVisibleIndexes = self.collectionView?.indexPathsForVisibleItems.sorted(by: <),
            let topAPIInfo = self.rangeAPIInfo(at: workaroundVisibleIndexes.first),
            let bottomAPIInfo = self.rangeAPIInfo(at: workaroundVisibleIndexes.last)
        else {
            return
        }

        dispatchQueue.async { [weak self] in
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
                case .failed(let error):
                    ///may be canceled request
                    break///TODO: popup here?
                }
            }
        }
    }
    
    private func rangeAPIInfo(at index: IndexPath?) -> RangeAPIInfo? {
        guard let objectIndex = index else {
            return nil
        }
        
        let object = dataSource.object(at: objectIndex)
        let objectId = object?.idValue
        let isLastIndex = isLast(indexPath: objectIndex)
        let isFirstIndex = (objectIndex.section == 0 && objectIndex.row == 0)

        if isFirstIndex {
            /// return Date.distantFuture to have the top items, because user may have wrong date on his device.
            return RangeAPIInfo(date: Date.distantFuture, id: nil)
        }
        
        if isLastIndex {
            /// return Date.distantPast to have the bottom items
            return RangeAPIInfo(date: Date.distantPast, id: nil)
        }
        
        /// check if it's one of missing dates
        guard object?.monthValue != nil, let sortingDate = object?.sortingDate as Date? else {
            return RangeAPIInfo(date: Date.distantPast, id: nil)
        }
        
        return RangeAPIInfo(date: sortingDate, id: objectId)
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
        cell.delegate = self
        cell.filesDataSource = filesDataSource
        
        guard let object = dataSource.object(at: indexPath) else {
            return
        }
        
        cell.setup(with: object)
        
        if let trimmedLocalFileID = object.trimmedLocalFileID, let progress = uploadProgress[trimmedLocalFileID] {
            cell.setProgressForObject(progress: progress, blurOn: true)
        } else {
            cell.cancelledUploadForObject()
        }
        
        let isSelectedCell = dataSource.selectedIndexPaths.contains(indexPath)
        cell.set(isSelected: isSelectedCell, isSelectionMode: dataSource.isSelectingMode, animated: true)
        
        if let uuid = object.trimmedLocalFileID, uploadedObjectID.index(of: uuid) != nil {
            cell.finishedUploadForObject()
        }
//        else {
//            cell.resetCloudImage()
//        }
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
            select(cell: cell, at: indexPath)
        } else {
            showDetail(at: indexPath)
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
        
        if let mediaItem = dataSource.object(at: indexPath) {
            view.setup(with: mediaItem)
        }
    }
}

// MARK: - BaseItemInputPassingProtocol 
/// using: bottomBarPresenter.basePassingPresenter = self, PhotoVideoThreeDotMenuManager(delegate: self)
extension PhotoVideoController: BaseItemInputPassingProtocol {

    func openInstaPick() {
        showSpinner()
        instaPickRoutingService.getViewController(isCheckAnalyzesCount: true, success: { [weak self] vc in
            self?.hideSpinner()
            if vc is InstapickPopUpController {
                //FIXME: add router
                let router = RouterVC()
                let navController = router.createRootNavigationControllerWithModalStyle(controller: vc)
                router.presentViewController(controller: navController)
            }
        }) { [weak self] error in
            self?.showAlert(with: error.description)
        }
    }
    
    var selectedItems: [BaseDataSourceItem] {
        return dataSource.selectedObjects
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
        let syncPhotos = selectedItems.filter { !$0.isLocalItem && $0.fileType == .image }
        
        if let itemsToPrint = syncPhotos as? [Item], !itemsToPrint.isEmpty {
            let router = RouterVC()
            let vc = PrintInitializer.viewController(data: itemsToPrint)
            router.pushOnPresentedView(viewController: vc)
        }
        stopEditingMode()
    }
    func changeCover() {}
    func deleteFromFaceImageAlbum(items: [BaseDataSourceItem]) {}
}

// MARK: - PhotoVideoNavBarManagerDelegate
extension PhotoVideoController: PhotoVideoNavBarManagerDelegate {
    
    func onCancelSelectionButton() {
        stopEditingMode()
    }
    
    func onThreeDotsButton() {
        threeDotMenuManager.showActions(for: dataSource.selectedObjects, isSelectingMode: dataSource.isSelectingMode, sender: navBarManager.threeDotsButton)
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
        
        let id = file.getTrimmedLocalID()
        uploadProgress[id] = progress
        
        collectionView.visibleCells.forEach { cell in
            if let cell = cell as? PhotoVideoCell, cell.trimmedLocalFileID == id {
                cell.setProgressForObject(progress: progress, blurOn: true)
                return
            }
        }
    }
    
    func startUploadFile(file: WrapData) {
        let progress: Float = 0
        let id = file.getTrimmedLocalID()
        uploadProgress[id] = progress
        DispatchQueue.toMain {
            self.getCellForLocalFile(objectTrimmedLocalID: file.getTrimmedLocalID()) { cell in
                cell?.setProgressForObject(progress: progress, blurOn: true)
            }
        }
        
    }
    
    func finishedUploadFile(file: WrapData) {
        let uuid = file.getTrimmedLocalID()
        if uploadedObjectID.index(of: uuid) == nil {
            uploadedObjectID.append(uuid)
        }
        
        uploadProgress.removeValue(forKey: uuid)
    
        DispatchQueue.toMain {
            if let cell = self.getCellForFile(objectUUID: uuid) {
                cell.finishedUploadForObject()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: { [weak self] in
                guard let self = self else {
                    return
                }
                
                if let path = self.getIndexPathForObject(itemUUID: uuid),
                    self.collectionView.indexPathsForVisibleItems.contains(path),
                    let object = self.dataSource.object(at: path),
                    let cell = self.collectionView.cellForItem(at: path) as? PhotoVideoCell {

                    if object.isLocalItemValue {
                        cell.showCloudImage()                        
                    } else {
                        cell.resetCloudImage()
                    }
                }
                
                if let index = self.uploadedObjectID.index(of: uuid) {
                    self.uploadedObjectID.remove(at: index)
                }
            })
        }
    }
    
    func cancelledUpload(file: WrapData) {
        let uuid = file.getTrimmedLocalID()
        uploadProgress.removeValue(forKey: uuid)
        
        DispatchQueue.toMain {
            if let cell = self.getCellForFile(objectUUID: uuid) {
                cell.cancelledUploadForObject()
            }
        }
    }
    
    func syncFinished() {
        let uuids = Array(uploadProgress.keys)
        guard !uuids.isEmpty else {
            return
        }
        
        DispatchQueue.toMain {
            let visibleCells = self.collectionView.visibleCells
            uuids.forEach({ uuid in
                if let cell = self.getCellForFile(objectUUID: uuid), visibleCells.contains(cell) {
                    cell.cancelledUploadForObject()
                }
            })
            self.uploadProgress.removeAll()
        }
    }
    
    func filesAddedToAlbum() {
        stopEditingMode()
    }
    
    private func getCellForFile(objectUUID: String) -> PhotoVideoCell? {
        guard let path = getIndexPathForObject(itemUUID: objectUUID),
            let cell = collectionView?.cellForItem(at: path) as? PhotoVideoCell
            else { return nil }
        return cell
    }
    
    private func getIndexPathForObject(itemUUID: String) -> IndexPath? {
        if let findedObject = dataSource.lastFetchedObjects?.first(where: { $0.trimmedLocalFileID == itemUUID }) {
            return dataSource.indexPath(forObject: findedObject)
        }

        return nil
    }
    
    private func getCellForLocalFile(objectTrimmedLocalID: String, completion: @escaping  (_ cell: PhotoVideoCell?)->Void) {
        guard let path = self.getIndexPathForLocalObject(objectTrimmedLocalID: objectTrimmedLocalID) else {
            completion(nil)
            return
        }
        completion(self.collectionView?.cellForItem(at: path) as? PhotoVideoCell)
    }
    
    private func getIndexPathForLocalObject(objectTrimmedLocalID: String) -> IndexPath? {
        if let findedObject = dataSource.lastFetchedObjects?.first(where: { $0.trimmedLocalFileID == objectTrimmedLocalID && $0.isLocalItemValue }) {
            return dataSource.indexPath(forObject: findedObject)
        }
        
        return nil
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


extension PhotoVideoController {
    private var itemProviderClosure: ItemProviderClosure {
        return { [weak self] indexPath in
            if let mediaItem = self?.dataSource.object(at: indexPath), let assetId = mediaItem.localFileID {
                return LocalMediaStorage.default.assetsCache.assetBy(identifier: assetId) ??
                    PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject
            }
            return nil
        }
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
    func selectedModeDidChange(_ selectingMode: Bool) { }
    
    func fetchPredicateCreated() { }
    
    func contentDidChange(_ fetchedObjects: [MediaItem]) {
        DispatchQueue.toMain {
            self.scrollBarManager.updateYearsView(with: fetchedObjects,
                                                  cellHeight: self.collectionViewManager.collectionViewLayout.itemSize.height,
                                                  numberOfColumns: Int(self.collectionViewManager.collectionViewLayout.columns))
        }
    }
    
    func convertFetchedObjectsInProgress() {
        showSpinner()
    }
}
