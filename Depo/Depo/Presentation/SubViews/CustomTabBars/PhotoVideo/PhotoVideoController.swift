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
// TODO: navigation bar with logo
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
    private lazy var dataSource = PhotoVideoDataSource(collectionView: self.collectionView)
    private lazy var analyticsManager: AnalyticsService = factory.resolve()
    private lazy var scrollDirectionManager = PhotoVideoScrollDirectionManager()
    private lazy var assetsFileCacheManager = AssetFileCacheManager()
    private let scrollBar = ScrollBarView()
    
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bottomBarManager.setup()
        collectionViewManager.setup()
        navBarManager.setDefaultMode()
        
        needShowTabBar = true
        floatingButtonsArray.append(contentsOf: [.floatingButtonTakeAPhoto,
                                                 .floatingButtonUpload,
                                                 .floatingButtonCreateAStory,
                                                 .floatingButtonCreateAlbum])
        
        ItemOperationManager.default.startUpdateView(view: self)
        
        performFetch()
        scrollBar.add(to: collectionView)
    }
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateCellSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCellSize()
        // TODO: need layoutIfNeeded?
        bottomBarManager.editingTabBar?.view.layoutIfNeeded()
        collectionViewManager.scrolliblePopUpView.isActive = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        collectionViewManager.scrolliblePopUpView.isActive = false
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
        assetsFileCacheManager.resetCachedAssets()
        dataSource.performFetch()
        collectionView.reloadData()
    }
    
    private func updateCellSize() {
        let columnsNumber = 4
        _ = collectionView.saveAndGetItemSize(for: columnsNumber)
    }
    
    // MARK: - Editing Mode
    
    private func startEditingMode(at indexPath: IndexPath?) {
        guard !dataSource.isSelectingMode else {
            return
        }
        dataSource.isSelectingMode = true
        if let indexPath = indexPath {
            dataSource.selectedIndexPaths.insert(indexPath)
        }
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        onChangeSelectedItemsCount(selectedItemsCount: dataSource.selectedIndexPaths.count)
        navBarManager.setSelectionMode()
    }
    
    private func stopEditingMode() {
        dataSource.isSelectingMode = false
        dataSource.selectedIndexPaths.removeAll()
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        bottomBarManager.hide()
        navBarManager.setDefaultMode()
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
        trackClickOnPhotoOrVideo(isPhoto: true)
        
        let currentMediaItem = dataSource.object(at: indexPath)
        let currentObject = WrapData(mediaItem: currentMediaItem)
        
        let router = RouterVC()
        let controller = router.filesDetailViewController(fileObject: currentObject, items: dataSource.fetchedObjects)
        let nController = NavigationController(rootViewController: controller)
        router.presentViewController(controller: nController)
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
    
    private func showSearchScreen(output: UIViewController?) {
        let router = RouterVC()
        let controller = router.searchView(output: output as? SearchModuleOutput)
        output?.navigationController?.delegate = controller as? BaseViewController
        controller.transitioningDelegate = output as? UIViewControllerTransitioningDelegate
        router.pushViewController(viewController: controller)
    }
}

// MARK: - PhotoVideoCellDelegate
extension PhotoVideoController: PhotoVideoCellDelegate {
    func photoVideoCellOnLongPressBegan(at indexPath: IndexPath) {
        startEditingMode(at: indexPath)
    }
}


// MARK: - UIScrollViewDelegate
extension PhotoVideoController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        assetsFileCacheManager.updateCachedAssets(on: collectionView, items: dataSource.lastFetchedObjects)
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
        updateDB()
    }
    
    private func updateDB() {
        print("updateDB with direction: \(scrollDirectionManager.scrollDirection)")
    }
    
}

// MARK: - UICollectionViewDelegate
extension PhotoVideoController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoVideoCell else {
            return
        }
        cell.delegate = self
        cell.indexPath = indexPath
        
        let object = dataSource.object(at: indexPath)
        let wraped = WrapData(mediaItem: object)
        cell.setup(with: wraped)
        
        if let progress = uploadProgress[wraped.getTrimmedLocalID()] {
            cell.setProgressForObject(progress: progress, blurOn: true)
        } else {
            cell.cancelledUploadForObject()
        }
        
        let isSelectedCell = dataSource.selectedIndexPaths.contains(indexPath)
        cell.set(isSelected: isSelectedCell, isSelectionMode: dataSource.isSelectingMode, animated: true)
        
        if uploadedObjectID.index(of: wraped.uuid) != nil {
            cell.finishedUploadForObject()
        }
//        else {
//            cell.resetCloudImage()
//        }
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
        let mediaItem = dataSource.object(at: indexPath)
        view.setup(with: mediaItem)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoVideoController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        ///return CGSize(width: collectionView.contentSize.width, height: 50)
        return CGSize(width: 0, height: 50)
    }
}

// MARK: - BaseItemInputPassingProtocol 
/// using: bottomBarPresenter.basePassingPresenter = self, PhotoVideoThreeDotMenuManager(delegate: self)
extension PhotoVideoController: BaseItemInputPassingProtocol {
    
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
    func printSelected() {}
    func changeCover() {}
    func deleteFromFaceImageAlbum(items: [BaseDataSourceItem]) {}
}

// MARK: - PhotoVideoNavBarManagerDelegate
extension PhotoVideoController: PhotoVideoNavBarManagerDelegate {
    
    func onCancelSelectionButton() {
        stopEditingMode()
    }
    
    func onThreeDotsButton() {
        threeDotMenuManager.showActions(for: dataSource.selectedObjects, isSelectingMode: dataSource.isSelectingMode)
    }
    
    func onSearchButton() {
        showSearchScreen(output: self)
    }
}

// MARK: - PhotoVideoCollectionViewManagerDelegate
/// using: PhotoVideoCollectionViewManager(collectionView: self.collectionView, delegate: self)
extension PhotoVideoController: PhotoVideoCollectionViewManagerDelegate {
    func refreshData(refresher: UIRefreshControl) {
        performFetch()
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
        self.getCellForLocalFile(objectTrimmedLocalID: id) { cell in
            cell?.setProgressForObject(progress: progress, blurOn: true)
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
    
    func finishedUploadFile(file: WrapData){
//        dispatchQueue.async { [weak self] in
//            guard let `self` = self else {
//                return
//            }
        
//            if let unwrapedFilters = self.originalFilters,
//                self.isAlbumDetail(filters: unwrapedFilters) {
//                return
//            }
//            
            
            let uuid = file.getTrimmedLocalID()
            if self.uploadedObjectID.index(of: file.uuid) == nil {
                self.uploadedObjectID.append(uuid)
            }
//            
//            finished: for (section, array) in self.allItems.enumerated() {
//                for (row, object) in array.enumerated() {
//                    if object.getTrimmedLocalID() == uuid, object.isLocalItem {
//                        file.isLocalItem = false
//                        
//                        guard section < self.allItems.count, row < self.allItems[section].count else {
//                            /// Collection was reloaded from different thread
//                            return
//                        }
//                        
//                        self.allItems[section][row] = file
//                        
//                        break finished
//                    }
//                }
//            }
//            
//            for (index, object) in self.allMediaItems.enumerated(){
//                if object.uuid == file.uuid {
//                    file.isLocalItem = false
//                    self.allMediaItems[index] = file
//                }
//            }
        
            uploadProgress.removeValue(forKey: uuid)
        
            DispatchQueue.toMain {
                if let cell = self.getCellForFile(objectUUID: uuid) {
                    cell.finishedUploadForObject()
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: { [weak self] in
                if let `self` = self, let cell = self.getCellForFile(objectUUID: uuid) {
                    cell.resetCloudImage()
                    
                    if let index = self.uploadedObjectID.index(of: uuid){
                        self.uploadedObjectID.remove(at: index)
                    }
                }
            })
//        }
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
    
    private func getCellForFile(objectUUID: String) -> PhotoVideoCell? {
        guard let path = getIndexPathForObject(itemUUID: objectUUID),
            let cell = collectionView?.cellForItem(at: path) as? PhotoVideoCell
            else { return nil }
        return cell
    }
    
    private func getIndexPathForObject(itemUUID: String) -> IndexPath? {
        let findedObject = dataSource.fetchedObjects.first { object in
            return object.getTrimmedLocalID() == itemUUID
        }
        guard let mediaItem = findedObject?.coreDataObject else {
            return nil
        }
        return dataSource.indexPath(forObject: mediaItem)
    }
    
    private func getCellForLocalFile(objectTrimmedLocalID: String, completion: @escaping  (_ cell: PhotoVideoCell?)->Void) {
        guard let path = self.getIndexPathForLocalObject(objectTrimmedLocalID: objectTrimmedLocalID) else {
            completion(nil)
            return
        }
        completion(self.collectionView?.cellForItem(at: path) as? PhotoVideoCell)
    }
    
    private func getIndexPathForLocalObject(objectTrimmedLocalID: String) -> IndexPath? {
        let findedObject = dataSource.fetchedObjects.first { object in
            return object.getTrimmedLocalID() == objectTrimmedLocalID && object.isLocalItem
        }
        guard let mediaItem = findedObject?.coreDataObject else {
            return nil
        }
        return dataSource.indexPath(forObject: mediaItem)
    }
}

extension PhotoVideoController {
    static func initPhotoFromNib() -> PhotoVideoController {
        let photoController = PhotoVideoController.initFromNib()
        photoController.isPhoto = true
        return photoController
    }
    
    static func initVideoFromNib() -> PhotoVideoController {
        let videoController = PhotoVideoController.initFromNib()
        videoController.isPhoto = false
        return videoController
    }
}

