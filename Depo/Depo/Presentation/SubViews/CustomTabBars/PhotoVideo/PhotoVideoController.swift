//
//  PhotoVideoController.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import MobileCoreServices

typealias IndexPathCallback = (_ path: IndexPath?) -> Void

final class PhotoVideoController: BaseViewController, NibInit, SegmentedChildController {

    @IBOutlet private weak var collectionView: QuickSelectCollectionView! {
        didSet {
            collectionView.dataSource = dataSource
            collectionView.delegate = self
            collectionView.longPressDelegate = self
        }
    }

    var contentTypes: [PhotoVideoController.ContentType] = [.photos, .videos]

    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.baseFilesGreedCollectionDataSource)
    
    private lazy var progressQueue = DispatchQueue(label: DispatchQueueLabels.photoVideoUploadProgress, attributes: .concurrent)
    private var uploadProgressValues = [String: Float]()
    private var inProgressMediaIDs: [String: Float] {
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
    
    private var resentlyUploadedObjectUUIDs = SynchronizedSet<String>()
    
    private lazy var collectionViewManager = PhotoVideoCollectionViewManager(collectionView: self.collectionView, delegate: self)
    private lazy var pinchManager = PhotoVideoPinchManager(collectionView: self.collectionView)
    private lazy var threeDotMenuManager = PhotoVideoThreeDotMenuManager(delegate: self)
    private lazy var bottomBarManager = PhotoVideoBottomBarManager(delegate: self)
    private lazy var dataSource = PhotoVideoDataSource(collectionView: self.collectionView, delegate: self)
    private lazy var analyticsManager: AnalyticsService = factory.resolve()
    private lazy var scrollDirectionManager = ScrollDirectionManager()
    private lazy var instaPickRoutingService = InstaPickRoutingService()
    private lazy var storageVars: StorageVars = factory.resolve()

    private lazy var assetsFileCacheManager = AssetFileCacheManager()
    
    private let scrollBarManager = PhotoVideoScrollBarManager()

    private lazy var quickScrollService = QuickScrollService()
    
    private lazy var filesDataSource = FilesDataSource()
    
    private lazy var router = RouterVC()
    
    private var canShowDetail = true
    
    private var isSelectionObject = 0
    
    private var category: QuickScrollCategory = .photosAndVideos
    private var fileTypes: [FileType] = [.image, .video]
    
    private var viewType: ElementTypes = .galleryAll
    var refresher: UIRefreshControl?
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bottomBarManager.setup()
        collectionViewManager.setup()
        collectionViewManager.collectionViewLayout.delegate = dataSource
        collectionViewManager.collectionViewLayout.pinsSectionHeadersToLayoutGuide = headerContainingViewController?.originalSafeAreaLayoutGuide
        pinchManager.setup()

        navigationBarHidden = true
        needToShowTabBar = true
        floatingButtonsArray.append(contentsOf: [.takePhoto, .upload, .createAlbum])
        ItemOperationManager.default.startUpdateView(view: self)

        scrollBarManager.addScrollBar(to: collectionView, delegate: self)
        performFetch()
        collectionView.addInteraction(UIDropInteraction(delegate: self))

        setDefaultNavigationHeaderActions()
        headerContainingViewController?.isHeaderBehindContent = false
        headerContainingViewController?.statusBarBackgroundViewStyle = .plain(color: .background)
        
        // Handle parsed deeplink if any
        PushNotificationService.shared.openActionScreen()
        // handle a token pending action if any
        PushNotificationService.shared.assignAndOpenPendingActionIfAny()
        
        
        //handle public shared items save operation after login
        if let publicTokenToSave = storageVars.publicSharedItemsToken {
            savePublicSharedItems(with: publicTokenToSave)
            storageVars.publicSharedItemsToken = nil
        }
        
        setupRefresher()
        
        if !(SingletonStorage.shared.accountInfo?.recoveryEmailVerified ?? true) {
            presentRecoveryEmailVerificationPopUp()
        }
    }

    private func setupRefresher() {
        refresher = UIRefreshControl()
        refresher?.tintColor = AppColor.filesRefresher.color
        refresher?.addTarget(self, action: #selector(fullReload), for: .valueChanged)
        collectionView.refreshControl = refresher
    }

    @objc private func fullReload() {
        fetchAndReload()
        stopRefresher()
    }

    func stopRefresher() {
        collectionView.refreshControl?.endRefreshing()
     }
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: Facelift - Analytics event for new gallery screen
//        self.trackPhotoVideoScreen(isPhoto: isPhoto)
        
        bottomBarManager.editingTabBar?.view.layoutIfNeeded()
        scrollBarManager.startTimerToHideScrollBar()
        
        ///trigger Range API for update new items which are uploaded by other clients
        updateDB()
        fetchNotificationCount()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)


        dataSource.getSelectedObjects(at: collectionViewManager.selectedIndexes) { [weak self] selectedItems in
            guard let self = self else {
                return
            }
            
            if !selectedItems.isEmpty {
                self.updateSelectedItemsCount()
                self.updateBarsForSelectedObjects()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopEditingMode()
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        //FE-1373 reset top content offset when user switch segment if needed
        if collectionView.contentOffset.y < -collectionView.contentInset.top {
            collectionView.contentOffset.y = -collectionView.contentInset.top
        }
    }
    
    // MARK: - setup
    
    private func performFetch() {
        dataSource.setupOriginalPredicates(fileTypes: fileTypes) { [weak self] in
            DispatchQueue.main.async {
                self?.fetchAndReload()

                // The very first viewWillAppear will return zero for collectionView.indexPathsForVisibleItems
                // We need to call updateDB() after the initial db fetch
                self?.collectionView.layoutIfNeeded()
                self?.updateDB()
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

        isSelectionObject = 0
        updateSelectedItemsCount()
        updateBarsForSelectedObjects()
    }
    
    private func stopEditingMode() {
        dataSource.isSelectingMode = false
        deselectAllCells()
        bottomBarManager.hide()
        CardsManager.default.stopOperationWith(type: .itemSelection)
    }
    

    private func deselectAllCells() {
        collectionViewManager.deselectAll()
        collectionView.visibleCells.forEach { cell in
            (cell as? PhotoVideoCell)?.updateSelection(isSelectionMode: dataSource.isSelectingMode, animated: false)
        }
    }

    // MARK: - helpers
    
    private func updateSelectedItemsCount() {
        let selectedIndexesCount = collectionViewManager.selectedIndexes.count
        isSelectionObject += 1
        self.setTitle("\(selectedIndexesCount) \(TextConstants.accessibilitySelected)")
        if selectedIndexesCount == 0 && self.isSelectionObject > 1 {
            stopEditingMode()
            self.isSelectionObject = 0
        }
    }
    
    private func updateBarsForSelectedObjects() {
        let selectedIndexes = collectionViewManager.selectedIndexes
        dataSource.getSelectedObjects (at: selectedIndexes) { [weak self] selectedObjects in
            guard let self = self else {
                return
            }
            self.bottomBarManager.update(for: selectedObjects)
            CardsManager.default.startOperationWith(type: .itemSelection, itemCount: selectedObjects.count)
            
            if selectedIndexes.count == 0 {
//                self.navBarManager.threeDotsButton.isEnabled = false
                CardsManager.default.stopOperationWith(type: .itemSelection)
                self.bottomBarManager.hide()
            } else {

                // TODO: Facelift - selection
//                if self.isPhoto {
//                    self.navBarManager.threeDotsButton.isEnabled = true
//                } else {
//                    let hasRemote = selectedObjects.first { !$0.isLocalItem } != nil
//                    self.navBarManager.threeDotsButton.isEnabled = hasRemote
//                }
                self.bottomBarManager.show()
            }
        }
    }
    
    private func showDetail(at indexPath: IndexPath) {
        guard canShowDetail else {
            return
        }
        
        canShowDetail = false
        // TODO: Facelift. Analytics
//        trackClickOnPhotoOrVideo(isPhoto: isPhoto)

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
    
    private func showUploadScreen() {
        let controller = router.uploadPhotos()
        let navigation = NavigationController(rootViewController: controller)
        navigation.navigationBar.isHidden = false
        router.presentViewController(controller: navigation)
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
    
    private func savePublicSharedItems(with publicTokenToSave: String) {
        PublicSharedItemsService().savePublicSharedItems(publicToken: publicTokenToSave) { value in
            SnackbarManager.shared.show(type: .action, message: localized(.publicShareSaveSuccess))
            self.router.openTabBarItem(index: .documents, segmentIndex: 0)
            ItemOperationManager.default.publicShareItemsAdded()
        } fail: { error in
            if error.errorDescription == PublicShareSaveErrorStatus.notRequiredSpace.rawValue {
                self.router.showFullQuotaPopUp()
                return
            }
            let message = PublicShareSaveErrorStatus.allCases.first(where: {$0.rawValue == error.errorDescription})?.description
            SnackbarManager.shared.show(type: .action, message: message ?? localized(.publicShareSaveError))
            self.router.openTabBarItem(index: .documents, segmentIndex: 0)
        }
    }
}

extension PhotoVideoController: HeaderContainingViewControllerChild {
    var scrollViewForHeaderTracking: UIScrollView? { collectionView }
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
        debugLog("RangeAPI start")
        print("updateDB with direction: \(scrollDirectionManager.scrollDirection)")
        guard CacheManager.shared.isCacheActualized else {
            return
        }
        
        guard
            let workaroundVisibleIndexes = self.collectionView?.indexPathsForVisibleItems.sorted(by: <)
        else {
            debugLog("RangeAPI workaroundVisibleIndexes = self.collectionView?.indexPathsForVisibleItems.sorted(by: <) failed")
            return
        }
        debugLog("RangeAPI first index \(workaroundVisibleIndexes.first) ")
        rangeAPIInfo(at: workaroundVisibleIndexes.first) { [weak self] topAPIInfo in
            debugLog("RangeAPI top info  date \(topAPIInfo?.date) id \(topAPIInfo?.id)")
            self?.self.rangeAPIInfo(at: workaroundVisibleIndexes.last) { [weak self] bottomAPIInfo in
                 debugLog("RangeAPI bottom info  date \(bottomAPIInfo?.date) id \(bottomAPIInfo?.id)")
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
                    
                    debugLog("RangeAPI category \(self.category)")
                    self.quickScrollService.requestListOfDateRange(startDate: topAPIInfo.date, endDate: bottomAPIInfo.date, startID: startId, endID: endId, category: self.category, pageSize: RequestSizeConstant.quickScrollRangeApiPageSize) { response in
                        debugLog("RangeAPI response recieved")
                        switch response {
                        case .success(let quckScrollResponse):
                            debugLog("RangeAPI response success")
                            debugLog("RangeAPI response count \(quckScrollResponse.size) \(quckScrollResponse.files.count)")
                            debugLog("RangeAPI first date \(quckScrollResponse.files.first?.metaDate) last date \(quckScrollResponse.files.last?.metaDate)")
                            self.dispatchQueue.async {
                                MediaItemOperationsService.shared.updateRemoteItems(remoteItems: quckScrollResponse.files, fileTypes: self.fileTypes, topInfo: topAPIInfo, bottomInfo: bottomAPIInfo, completion: {
                                    debugLog("RangeAPI DB UPDATED")
                                    debugPrint("appended and updated")
                                })
                            }
                        case .failed(_):
                            debugLog("RangeAPI response failed")
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
    
    func presentRecoveryEmailVerificationPopUp() {
        let popup = RouterVC().verifyRecoveryEmailPopUp
        popup.alwaysShowsLaterButton = true
        //popup.delegate = self
        present(popup, animated: true)
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
            guard
                let self = self,
                let object = object
            else {
                return
            }
            
            cell.setup(with: object)
            cell.updateSelection(isSelectionMode: self.dataSource.isSelectingMode, animated: true)
            
            if let uuid = object.uuid, self.resentlyUploadedObjectUUIDs.contains(uuid) {
                cell.update(syncStatus: .synced)
            } else if object.isLocalItemValue, let trimmedLocalFileID = object.trimmedLocalFileID, let progress = self.inProgressMediaIDs[trimmedLocalFileID] {
                progress > .zero
                    ? cell.setProgressForObject(progress: progress)
                    : cell.update(syncStatus: .syncInQueue)
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
        if elementKind == UICollectionView.elementKindSectionHeader {
            view.layer.zPosition = 0
        }
        guard let view = view as? CollectionViewSimpleHeaderWithText else {
            return
        }
        
        if indexPath.section == 0 {
            setGraceBanner(view: view)
        }
        
        dataSource.getObject(at: indexPath) { object in
            if let mediaItem = object {
                view.setup(with: mediaItem)
            }
        }
    }
    
    private func setGraceBanner(view: CollectionViewSimpleHeaderWithText) {
        let graceBannerState = SingletonStorage.shared.subscriptionsContainGracePeriod && collectionViewManager.collectionViewLayout.graceBannerState
        
        collectionViewManager.collectionViewLayout.graceBannerState = graceBannerState
        collectionViewManager.collectionViewLayout.graceBannerHeight = view.getHightOfGraceBanner()
        view.graceBanner.isHidden = !graceBannerState
        view.closeAction = { [weak self] in
            self?.collectionViewManager.collectionViewLayout.graceBannerState = false
            self?.collectionView.reloadData()
        }
    }
}

// MARK: - BaseItemInputPassingProtocol 
/// using: bottomBarPresenter.basePassingPresenter = self, PhotoVideoThreeDotMenuManager(delegate: self)
extension PhotoVideoController: BaseItemInputPassingProtocol {

    func openInstaPick() {
        analyticsManager.track(event: .photopickClick)

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
            let itemsToPrint = selectedObjects.filter { !$0.isLocalItem && $0.fileType == .image }
            
            if !itemsToPrint.isEmpty {
                let warningPopup = WarningPopupController.popup(type: .photoPrintRedirection(photos: itemsToPrint)) {
                    self.stopEditingMode()
                }

                UIApplication.topController()?.present(warningPopup, animated: false)
            }
        }
        
    }
    func changeCover() {}
    func changePeopleThumbnail() {}
}

// MARK: - PhotoVideoCollectionViewManagerDelegate
/// using: PhotoVideoCollectionViewManager(collectionView: self.collectionView, delegate: self)
extension PhotoVideoController: PhotoVideoCollectionViewManagerDelegate {
    func openUploadPhotos() {
        showUploadScreen()
    }

    func openAutoSyncSettings() {
        router.pushViewController(viewController: router.autoUpload)
    }

    func openViewTypeMenu(sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = AppColor.blackColor.color
        
        let actions = GalleryViewType.createAlertActions { [weak self] type in
            self?.changeViewType(to: type)
        }
        actions.forEach { actionSheet.addAction($0) }
    
        let cancelAction = UIAlertAction(title: TextConstants.cancel, style: .cancel)
        actionSheet.addAction(cancelAction)
        
        let rect = sender.convert(sender.bounds, to: self.view)
        actionSheet.popoverPresentationController?.sourceRect = rect
        actionSheet.popoverPresentationController?.sourceView = self.view
        actionSheet.popoverPresentationController?.permittedArrowDirections = .up

        present(actionSheet, animated: true)
    }
    
    private func changeViewType(to type: GalleryViewType) {
        guard collectionViewManager.viewType != type else {
            return
        }
        
        collectionViewManager.viewType = type

        dataSource.changeSourceFilter(type: type, fileTypes: contentTypes.mappedToFileTypes()) { [weak self] in
            DispatchQueue.main.async {
                self?.fetchAndReload()
            }
        }
    }
}

// MARK: - ItemOperationManagerViewProtocol
/// using: ItemOperationManager.default.startUpdateView(view:
extension PhotoVideoController: ItemOperationManagerViewProtocol {
    
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        guard let compairedView = object as? PhotoVideoController else {
            return false
        }
        return compairedView == self
    }
    
    func setProgressForUploadingFile(file: WrapData, progress: Float) {
        guard file.isLocalItem else {
            return
        }
        let id = file.getTrimmedLocalID()
        inProgressMediaIDs[id] = progress
        getCellInVisibleIndexRange(objectTrimmedLocalID: id) { $0?.setProgressForObject(progress: progress) }
    }
    
    func startUploadFile(file: WrapData) {
        guard file.isLocalItem else {
            return
        }
        let id = file.getTrimmedLocalID()
        inProgressMediaIDs[id] = .zero
        getVisibleCellForLocalFile(objectTrimmedLocalID: id) { $0?.update(syncStatus: .syncInQueue) }
    }
    
    func finishedUploadFile(file: WrapData) {
        let trimmedLocalID = file.getTrimmedLocalID()
        inProgressMediaIDs.removeValueSafely(forKey: trimmedLocalID)
        
        resentlyUploadedObjectUUIDs.insert(file.uuid)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.getCellForTrimmedID(objectTrimmedLocalID: trimmedLocalID) { [weak self] cell in
                cell?.update(syncStatus: .synced)
                self?.postFinishedUploadFileAction(file: file)
            }
        }
    }
    
    private func postFinishedUploadFileAction(file: WrapData) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: { [weak self] in
            guard let self = self else {
                return
            }
            self.resentlyUploadedObjectUUIDs.remove(file.uuid)

            self.dataSource.getIndexPathForObject(uuid: file.uuid) { [weak self] indexPath in
                guard let self = self else {
                    return
                }
                if let path = indexPath,
                    self.collectionView.indexPathsForVisibleItems.contains(path) {
                    self.dataSource.getObject(at: path, mediaItemCallback: { [weak self] object in
                        guard
                            let cell = self?.collectionView.cellForItem(at: path) as? PhotoVideoCell,
                            let object = object
                        else {
                            return
                        }
                        cell.update(syncStatus: object.isLocalItemValue ? .notSynced : .regular)
                    })
                }
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
        guard let progress = inProgressMediaIDs[trimmedID] else { return }
        inProgressMediaIDs.removeValueSafely(forKey: trimmedID)
        
        DispatchQueue.toMain {
            self.getVisibleCellForLocalFile(objectTrimmedLocalID: trimmedID) {
                $0?.update(syncStatus: progress > .zero ? .syncFailed : .notSynced)
            }
        }
    }
    
    func failedAutoSync() {
        updateUploadProgressForVisibleCells(newStatus: .syncFailed)
    }
    
    func syncFinished() {
        updateUploadProgressForVisibleCells(newStatus: .notSynced)
    }
    
    func filesAddedToAlbum(isAutoSyncOperation: Bool) {
        if !isAutoSyncOperation {
            stopEditingMode()
        }
    }
    
    private func updateUploadProgressForVisibleCells(newStatus: PhotoVideoCell.SyncStatus) {
        let trimmedIDs = Array(inProgressMediaIDs.keys)
        guard !trimmedIDs.isEmpty else {
            return
        }

        DispatchQueue.toMain {
            trimmedIDs.forEach { trimmedID in
                DispatchQueue.toMain {
                    self.getVisibleCellForLocalFile(objectTrimmedLocalID: trimmedID) {
                        guard
                            let progress = self.inProgressMediaIDs.removeValueSafely(forKey: trimmedID),
                            progress > .zero
                        else {
                            $0?.update(syncStatus: .notSynced)
                            return
                        }
                        $0?.update(syncStatus: newStatus)
                    }
                }
            }
        }
    }
    
    private func getCellForFile(objectUUID: String, completion: @escaping (_ cell: PhotoVideoCell?) -> Void) {
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
    
    func dragAndDropItemUploaded() {
        ///delay for getting items from server
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.updateDB()
        }
    }
    
    func elementTypeChanged(type: ElementTypes) {
        self.viewType = type
        
        switch type {
        case .galleryAll:
//            category = .photosAndVideos
//            fileTypes = [.image, .video]
//            collectionViewManager.viewType = .all
//            performFetch()
            changeViewType(to: .all)
        case .galleryPhotos:
            category = .photos
            fileTypes = [.image]
            collectionViewManager.viewType = .all
            performFetch()
        case .galleryVideos:
            category = .videos
            fileTypes = [.video]
            collectionViewManager.viewType = .all
            performFetch()
        case .gallerySync:
            changeViewType(to: .synced)
        case .galleryUnsync:
            changeViewType(to: .unsynced)
        default:
            return
        }
    }
    
    func stopItemSelection() {
        stopEditingMode()
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

    func contentDidChange(sections: [NSFetchedResultsSectionInfo], fetchedObjects: [MediaItem]) {
        updateYearsView(with: sections)
        collectionViewManager.showEmptyDataViewIfNeeded(isShow: fetchedObjects.isEmpty, type: viewType)
    }
    
    func convertFetchedObjectsInProgress() {
        showSpinner()
    }
    
    func getCalculatedHeightNew(for section: Int) -> CGFloat {
        let numberOfItemsInSection = collectionView.numberOfItems(inSection: section)
        
        guard numberOfItemsInSection > 0 else {
            return .zero
        }
        
        let headerFrame = collectionViewManager.collectionViewLayout.layoutAttributesForSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: section)
        )?.frame ?? .zero
        
        let firstItemIndex = 0
        let fisrtItemFrame =  collectionViewManager.collectionViewLayout.layoutAttributesForItem(at: IndexPath(item: firstItemIndex, section: section))?.frame ?? .zero

        let lastItemIndex = numberOfItemsInSection - 1
        let lastItemFrame =  collectionViewManager.collectionViewLayout.layoutAttributesForItem(at: IndexPath(item: lastItemIndex, section: section))?.frame ?? .zero

        let sectionHeightWithoutHeader = lastItemFrame.maxY - fisrtItemFrame.minY
        
        return max(0, sectionHeightWithoutHeader + headerFrame.height)
    }

    private func updateYearsView(with sections: [NSFetchedResultsSectionInfo]) {
        let dates = getDates(of: sections)

        let collectionViewVisibleHeight = collectionView.frame.inset(by: collectionView.adjustedContentInset).height

        var yearHeightMap: YearHeightMap = [:]
        for (index, date) in dates.enumerated() {
            //let height = collectionViewManager.collectionViewLayout.getCalculatedHeight(for: index)
            let height = getCalculatedHeightNew(for: index)
            let year = date?.getYear()
            yearHeightMap[year] = yearHeightMap[year, default: 0] + height

            if index == 0 {
                yearHeightMap[year] = yearHeightMap[year]! + collectionViewVisibleHeight
            }
        }

        let yearsSorted: [YearHeightTuple] = yearHeightMap.keys
            .sorted { year1, year2 in
                let year1 = year1 ?? Int.min
                let year2 = year2 ?? Int.min
                return year1 > year2
            }
            .map { year in
                (year, yearHeightMap[year, default: 0])
            }

        scrollBarManager.updateYearsView(with: yearsSorted)
    }


    private func getDates(of sections: [NSFetchedResultsSectionInfo]) -> [Date?] {
        sections
            .compactMap { section in
                var item: MediaItem?
                SwiftTryCatch.try {
                    item = section.objects?.first as? MediaItem
                } catch: { error in
                    debugLog("CRASH CASE ---->>> section.objects \(String(describing: error?.description))")
                } finally: {
                    
                }
                return item?.sortingDate as? Date
            }
    }

    func threeDotsButtonTapped(_ button: UIButton?) {
        if collectionViewManager.selectedIndexes.isEmpty {
            stopEditingMode()
        }

        dataSource.getSelectedObjects(at: collectionViewManager.selectedIndexes) { [weak self] selectedObjects in
            guard let self = self else {
                return
            }
            self.threeDotMenuManager.showActions(
                for: selectedObjects,
                isSelectingMode: self.dataSource.isSelectingMode,
                sender: button
            )
        }
    }
}

extension PhotoVideoController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: DragAndDropMediaType.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        DragAndDropHelper.shared.performDrop(with: session, itemType: DragAndDropMediaType.self)
    }
}

