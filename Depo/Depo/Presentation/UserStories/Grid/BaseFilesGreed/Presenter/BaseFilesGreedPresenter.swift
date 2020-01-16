//
//  BaseFilesGreedPresenter.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class BaseFilesGreedPresenter: BasePresenter, BaseFilesGreedModuleInput, BaseFilesGreedViewOutput, BaseFilesGreedInteractorOutput, BaseDataSourceForCollectionViewDelegate, BaseFilesGreedModuleOutput {
    
    lazy var player: MediaPlayer = factory.resolve()
    
    private lazy var instaPickRoutingService = InstaPickRoutingService()
    
    var dataSource: BaseDataSourceForCollectionView
    
    weak var view: BaseFilesGreedViewInput!
    
    weak var moduleOutput: BaseFilesGreedModuleOutput?
    
    var interactor: BaseFilesGreedInteractorInput!
    
    var router: BaseFilesGreedRouterInput!
    
    var sortedRule: SortedRules
    
    var filters: [GeneralFilesFiltrationType] = []
    
    private var filtersByDefault: [GeneralFilesFiltrationType] = []
    
    var bottomBarConfig: EditingBarConfig?
    
    weak var bottomBarPresenter: BottomSelectionTabBarModuleInput?
    
    weak var sliderModule: LBAlbumLikePreviewSliderModuleInput?
    
    var topBarConfig: GridListTopBarConfig?
    
    var alertSheetModule: AlertFilesActionsSheetModuleInput?
    
    var type: MoreActionsConfig.ViewType
    var sortedType: MoreActionsConfig.SortRullesType
    
    var alertSheetExcludeTypes = [ElementTypes]()
    
    var needShowProgressInCells = false
    
    var needShowScrollIndicator = false
    
    var needShowEmptyMetaItems = false
    
    var ifNeedReloadData = true
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.baseFilesGreed)
    
    init(sortedRule: SortedRules = .timeDown) {
        self.sortedRule = sortedRule
        self.dataSource = BaseDataSourceForCollectionView(sortingRules: sortedRule)
        type = .Grid
        sortedType = .TimeNewOld
        super.init()
    }
    
    func viewIsReady(collectionView: UICollectionView) {
        debugLog("BaseFilesGreedPresenter viewIsReady")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateThreeDots(_:)),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationUpdateThreeDots),
                                               object: nil)

        interactor.viewIsReady()
        if let unwrapedFilters = interactor.originalFilesTypeFilter {
            filters = unwrapedFilters
        }
        dataSource.setupCollectionView(collectionView: collectionView,
                                       filters: interactor.originalFilesTypeFilter)
       
        dataSource.delegate = self
        dataSource.needShowProgressInCell = needShowProgressInCells
        dataSource.needShowCustomScrollIndicator = needShowScrollIndicator
        dataSource.needShowEmptyMetaItems = needShowEmptyMetaItems
        dataSource.parentUUID = interactor.getFolder()?.uuid
        if let albumInteractor = interactor as? AlbumDetailInteractor {
            dataSource.parentUUID = albumInteractor.album?.uuid
        }
        
        if let displayingType = topBarConfig {
            type = displayingType.defaultGridListViewtype
            if displayingType.defaultGridListViewtype == .Grid {
                dataSource.updateDisplayngType(type: .list)
            } else {
                dataSource.updateDisplayngType(type: .greed)
            }
            dataSource.currentSortType = displayingType.defaultSortType.sortedRulesConveted
        }
        
        view.setupInitialState()
        setupTopBar()
        getContent()
        reloadData()
        subscribeDataSource()
    }
    
    func needToReloadVisibleCells() {
        debugLog("BaseFilesGreedPresenter needToReloadVisibleCells")
        
        DispatchQueue.main.async {
            self.dataSource.updateVisibleCells()
        }
    }
    
    func subscribeDataSource() {
        ItemOperationManager.default.startUpdateView(view: dataSource)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        /// dataSource is last reference which keep presenter? (possible solution use WeakWrapper)
        ItemOperationManager.default.stopUpdateView(view: dataSource)
    }
    
    func searchByText(searchText: String) {
        debugLog("BaseFilesGreedPresenter searchByText")

        uploadData(searchText)
    }
    
    func onReloadData() {
        debugLog("BaseFilesGreedPresenter onReloadData")
        
        
//        dataSource.dropData()
        view?.setThreeDotsMenu(active: false)
        reloadData()
    }
    
    func onStartCreatingPhotoAndVideos() {
        debugLog("BaseFilesGreedPresenter onStartCreatingPhotoAndVideos")

        let service = interactor.getRemoteItemsService()
        
        if service is FavouritesService {
            let router = RouterVC()
            let parentFolder = router.getParentUUID()
            let viewController = router.uploadFromLifeBoxFavorites(folderUUID: parentFolder, soorceUUID: "", sortRule: .timeUp, isPhotoVideoOnly: true)
            let navigation = NavigationController(rootViewController: viewController)
            navigation.navigationBar.isHidden = false
            router.presentViewController(controller: navigation)
            
        } else if service is AllFilesService ||
            service is PhotoAndVideoService ||
            service is ThingsItemsService ||
            service is PlacesItemsService ||
            service is PeopleItemsService {
            router.showUpload()
        }
        
        getContent()
    }
    
    func getContent() {
        //        uploadData()
    }
    
    func getFileFilter() -> FieldValue {
        for type in self.filters {
            switch type {
            case .fileType(let type):
                return type.convertedToSearchFieldValue
            case .favoriteStatus(.favorites):
                return .favorite
            default:
                break
            }
        }
        return .all
    }
    
    private func compoundAllFiltersAndNextItems(searchText: String? = nil) {
        debugLog("BaseFilesGreedPresenter compoundAllFiltersAndNextItems")
//        startAsyncOperation()
        interactor.nextItems(searchText,
                             sortBy: sortedRule.sortingRules,
                             sortOrder: sortedRule.sortOder, newFieldValue: getFileFilter())
    }

    func reloadData() {
        debugLog("BaseFilesGreedPresenter reloadData")
        debugPrint("BaseFilesGreedPresenter reloadData")

        dataSource.dropData()
        dataSource.currentSortType = sortedRule
        dataSource.isHeaderless = (sortedRule == .sizeAZ || sortedRule == .sizeZA)
        dataSource.reloadData()
        startAsyncOperation()
        dataSource.isPaginationDidEnd = false
        interactor.reloadItems(nil,
                               sortBy: sortedRule.sortingRules,
                               sortOrder: sortedRule.sortOder, newFieldValue: getFileFilter())
    }
    
    func uploadData(_ searchText: String? = nil) {
        debugLog("BaseFilesGreedPresenter uploadData")

        startAsyncOperation()
        compoundAllFiltersAndNextItems(searchText: searchText)
    }
    
    func onNextButton() {
        
    }
    
    // MARK: - Request OUTPUT
    func getContentWithFail(errorString: String?) {
        view?.stopRefresher()
        dataSource.isPaginationDidEnd = false
        dataSource.hideLoadingFooter()
        
        debugPrint("???getContentWithFail()")
        debugLog("BaseFilesGreedPresenter getContentWithFail")
        asyncOperationFail(errorMessage: errorString)
    }

    func serviceAreNotAvalible() {
        
    }

    func getContentWithSuccessEnd() {
        debugLog("BaseFilesGreedPresenter getContentWithSuccessEnd")
        debugPrint("???getContentWithSuccessEnd()")
//        asyncOperationSucces()
        dataSource.isPaginationDidEnd = true
        view?.stopRefresher()
        updateThreeDotsButton()
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            self.dataSource.appendCollectionView(items: [], pageNum: self.interactor.requestPageNum)
        }
    }
    
    func getContentWithSuccess(items: [WrapData]) {
        debugLog("BaseFilesGreedPresenter getContentWithSuccess")

        if (view == nil) {
            return
        }
        debugPrint("!!! page \(self.interactor.requestPageNum)")
        updateThreeDotsButton()
//        items.count < interactor.requestPageSize ? (dataSource.isPaginationDidEnd = true) : (dataSource.isPaginationDidEnd = false)
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
           self.dataSource.appendCollectionView(items: items, pageNum: self.interactor.requestPageNum)
        }
    }
    
    func getContentWithSuccess(array: [[BaseDataSourceItem]]) {
        debugLog("BaseFilesGreedPresenter getContentWithSuccess")

        if (view == nil) {
            return
        }
        debugPrint("???getContentWithSuccessEnd()")
        asyncOperationSuccess()
//        view.stopRefresher()
        if let dataSourceForArray = dataSource as? ArrayDataSourceForCollectionView {

            dataSourceForArray.configurateWithArray(array: array)
        } else {
            dataSource.reloadData()
        }
        updateNoFilesView()
        updateThreeDotsButton()
    }
    
    func isArrayDataSource() -> Bool {
        return false
    }
    
    func getNextItems() {
        compoundAllFiltersAndNextItems()
    }
    
    func showCustomPopUpWithInformationAboutAccessToMediaLibrary() {
        debugLog("BaseFilesGreedPresenter showCustomPopUpWithInformationAboutAccessToMediaLibrary")

        view.showCustomPopUpWithInformationAboutAccessToMediaLibrary()
    }
    
    func needShowNoFileView() -> Bool {
        return dataSource.allObjectIsEmpty()
    }
    
    func getCurrentSortRule() -> SortedRules {
        return sortedRule
    }
    
    func getRemoteItemsService() -> RemoteItemsService {
        return interactor.getRemoteItemsService()
    }
    
    func onCancelSelection() {
        stopEditing()
    }
    
    func isSelectionState() -> Bool {
        return dataSource.isSelectionStateActive
    }
    
    func stopSelectionWhenDisappear() {
        dataSource.setSelectionState(selectionState: false)
        view.stopSelection()
    }
    
    @objc func updateThreeDots(_ sender: Any) {
        DispatchQueue.main.async {
            self.updateThreeDotsButton()
        }
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
    
    // MARK: BaseGridDataSourceForCollectionView
    
    func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]]) {
        debugLog("BaseFilesGreedPresenter onItemSelected")

        if item.fileType == .video {
            interactor.trackClickOnPhotoOrVideo(isPhoto: false)
        } else if item.fileType == .image {
            interactor.trackClickOnPhotoOrVideo(isPhoto: true)
        } else {
            interactor.trackItemsSelected(item: item)
        }
        
        if item.fileType.isSupportedOpenType {
            let sameTypeFiles = getSameTypeItems(item: item, items: data)
            router.onItemSelected(selectedItem: item, sameTypeItems: sameTypeFiles,
                                  type: type, sortType: sortedType, moduleOutput: self)
        } else {
            let vc = PopUpController.with(title: TextConstants.warning, message: TextConstants.theFileIsNotSupported,
                                          image: .error, buttonTitle: TextConstants.ok)
            UIApplication.topController()?.present(vc, animated: false, completion: nil)
        }
    }
    
    func onItemSelectedActiveState(item: BaseDataSourceItem) { }
    
    func onSelectedFaceImageDemoCell(with indexPath: IndexPath) { }
    
    private func getSameTypeItems(item: BaseDataSourceItem, items: [[BaseDataSourceItem]]) -> [BaseDataSourceItem] {
        let allItems = items.flatMap { $0 }
        if item.fileType.isDocument {
            return allItems.filter { $0.fileType.isDocument }
        } else if item.fileType == .video || item.fileType == .image {
            return allItems.filter { ($0.fileType == .video) || ($0.fileType == .image) }
        }
        return allItems.filter { $0.fileType == item.fileType }
    }
    
    func getCellSizeForList() -> CGSize {
        return CGSize(width: view.getCollectionViewWidth(), height: 65)
    }
    
    func getCellSizeForGreed() -> CGSize {
        var cellWidth: CGFloat = 180
        
        if (Device.isIpad) {
            cellWidth = (view.getCollectionViewWidth() - NumericConstants.iPadGreedInset * 2 - NumericConstants.iPadGreedHorizontalSpace * (NumericConstants.numerCellInLineOnIpad - 1)) / NumericConstants.numerCellInLineOnIpad
        } else {
            cellWidth = (view.getCollectionViewWidth() - NumericConstants.iPhoneGreedInset * 2 - NumericConstants.iPhoneGreedHorizontalSpace * (NumericConstants.numerCellInLineOnIphone - 1)) / NumericConstants.numerCellInLineOnIphone
        }
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func onLongPressInCell() {
        startEditing()
    }
    
    func needReloadData() {
        if ifNeedReloadData {
            reloadData()
        }
    }
    
    func newFolderCreated() {
        interactor.trackFolderCreated()
    }
    
    func filesAppendedAndSorted() {
        DispatchQueue.toMain {
            self.view.stopRefresher()
            self.updateNoFilesView()
            self.asyncOperationSuccess()
            self.updateThreeDotsButton()
        }
    }

    func didDelete(items: [BaseDataSourceItem]) {
        updateNoFilesView()
        updateThreeDotsButton()
    }
    
    func updateCoverPhotoIfNeeded() { }
    
    func didChangeTopHeader(text: String) {
        if needShowCustomScrollIndicator() {
            view.changeScrollIndicatorTitle(with: text)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if needShowCustomScrollIndicator() {
            view.startScrollCollectionView()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if needShowCustomScrollIndicator() {
            view.startScrollCollectionView()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if needShowCustomScrollIndicator() && !decelerate {
            view.endScrollCollectionView()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if needShowCustomScrollIndicator() {
            view.endScrollCollectionView()
        }
    }
    
    private func needShowCustomScrollIndicator() -> Bool {
         return needShowScrollIndicator && sortedRule != .sizeAZ && sortedRule != .sizeZA
    }
    
    // MARK: - UnderNavBarBar/TopBar
    
    func setupTopBar() {
        guard let unwrapedConfig = topBarConfig else {
            return
        }
        view.setupUnderNavBarBar(withConfig: unwrapedConfig)
        sortedRule = unwrapedConfig.defaultSortType.sortedRulesConveted
    }
 
    // MARK: Bottom Bar
    
    private func canShow3DotsButton() -> Bool {
        let array = dataSource.getSelectedItems().filter {
            if $0.isLocalItem && $0.fileType == .video {
                return false
            }
            return true
        }
        return !array.isEmpty
    }
    
    private func startEditing() {
        let selectedItemsCount = dataSource.selectedItemsArray.count
        view.startSelection(with: selectedItemsCount)
        view.setThreeDotsMenu(active: canShow3DotsButton())
        dataSource.setSelectionState(selectionState: true)
    }
    
    
    private func stopEditing() {
        dismissBottomBar(animated: true)
        view.stopSelection()
        dataSource.setSelectionState(selectionState: false)
        view.setThreeDotsMenu(active: true)
    }
    
    private func dismissBottomBar(animated: Bool) {
        bottomBarPresenter?.dismiss(animated: animated)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationShowPlusTabBar), object: nil)
    }
    
    func updateNoFilesView() {
        if needShowNoFileView() {
            if interactor.canShowNoFilesView() {
                view.showNoFilesWith(text: interactor.textForNoFileLbel(),
                                     image: interactor.imageForNoFileImageView(),
                                     createFilesButtonText: interactor.textForNoFileButton(),
                                     needHideTopBar: interactor.needHideTopBar())
            } else {
                view.showNoFilesTop(text: interactor.textForNoFileTopLabel())
            }
        } else {
            view.hideNoFiles()
        }
    }
    
    func updateThreeDotsButton() {
        if view != nil,
            !dataSource.isSelectionStateActive {//FIXME: we need solve memory leak, something holds presenter in memory
            view.setThreeDotsMenu(active: !needShowNoFileView())
        }
    }
    
    func onChangeSelectedItemsCount(selectedItemsCount: Int) {
        setupNewBottomBarConfig()
        debugLog("BaseFilesGreedPresenter onChangeSelectedItemsCount")

        if (selectedItemsCount == 0) {
            debugLog("BaseFilesGreedPresenter onChangeSelectedItemsCount selectedItemsCount == 0")

            dismissBottomBar(animated: true)
        } else {
            debugLog("BaseFilesGreedPresenter onChangeSelectedItemsCount selectedItemsCount != 0")

            bottomBarPresenter?.show(animated: true, onView: nil)
        }
        
        
        view.setThreeDotsMenu(active: canShow3DotsButton())
        self.view.selectedItemsCountChange(with: selectedItemsCount)
    }
    
    func setupNewBottomBarConfig() {
        guard let barConfig = interactor.bottomBarConfig,
            let array = dataSource.getSelectedItems() as? [Item] else {
                return
        }
        bottomBarPresenter?.setupTabBarWith(items: array, originalConfig: barConfig)
    }
    
    func onMoreActions(ofItem: Item?, sender: Any) {
        guard let item = ofItem else {
            return
        }
        debugLog("BaseFilesGreedPresenter onMoreActions")

        alertSheetModule?.showSpecifiedAlertSheet(with: item,
                                                  presentedBy: sender,
                                                  onSourceView: nil,
                                                  viewController: nil)
    }
    
    func onMaxSelectionExeption() {
        
    }
    
    func showOnlySyncedItems(_ value: Bool) {
        if value {
            filtersByDefault = filters
            filters = filters.filter { type -> Bool in
                switch type {
                case .localStatus(_):
                    return false
                default:
                    return true
                }
            }
            filters.append(.localStatus(.nonLocal))            
        } else {
            filters = filtersByDefault
        }
        dataSource.originalFilters = filters
        reloadData()
    }
    
    // MARK: - MoreActionsViewDelegate
    
    func viewAppearanceChanged(asGrid: Bool) {
        debugLog("BaseFilesGreedPresenter viewAppearanceChanged")

        if (asGrid) {
            debugLog("BaseFilesGreedPresenter viewAppearanceChanged Grid")

            dataSource.updateDisplayngType(type: .greed)
            type = .List
            moduleOutput?.reloadType(type, sortedType: sortedType, fieldType: getFileFilter())
        } else {
            debugLog("BaseFilesGreedPresenter viewAppearanceChanged List")

            dataSource.updateDisplayngType(type: .list)
            type = .Grid
            moduleOutput?.reloadType(type, sortedType: sortedType, fieldType: getFileFilter())
        }
    }
    
    func sortedPushed(with rule: SortedRules) {
        debugLog("BaseFilesGreedPresenter sortedPushed")
        interactor.trackSortingChange(sortRule: rule)
        sortedRule = rule
        view.changeSortingRepresentation(sortType: rule)
        dataSource.currentSortType = rule
        (rule == .sizeAZ || rule == .sizeZA) ? (dataSource.isHeaderless = true) : (dataSource.isHeaderless = false)

        moduleOutput?.reloadType(type, sortedType: sortedType, fieldType: getFileFilter())
        reloadData()
    }
    
    func selectPressed(type: MoreActionsConfig.SelectedType) {
        debugLog("BaseFilesGreedPresenter selectPressed")

        if (type == .Selected) {
            debugLog("BaseFilesGreedPresenter selectPressed type == selected")

            dataSource.selectAll(isTrue: true)
            startEditing()
        } else {
            debugLog("BaseFilesGreedPresenter selectPressed type != selected")

            dataSource.selectAll(isTrue: false)
            stopEditing()
        }
    }
    
    func viewWillDisappear() {
        bottomBarPresenter?.dismiss(animated: true)
        stopSelectionWhenDisappear()
    }
    
    func viewWillAppear() {
        interactor.trackScreen()
        if dataSource.selectedItemsArray.count > 0 {
            bottomBarPresenter?.show(animated: true, onView: nil)
        }
    }
    
    func moreActionsPressed(sender: Any) {
        
        let selectionMode = dataSource.isInSelectionMode()
        var actionTypes = (interactor.alerSheetMoreActionsConfig?.selectionModeTypes ?? [])
        if selectionMode {
            let selectedItemsUUIDs = Array(dataSource.selectedItemsArray)
            var selectedItems = [BaseDataSourceItem]()
            
            for items in dataSource.getAllObjects() {
                selectedItems += items.filter { selectedItemsUUIDs.contains($0) }
            }
            
            //let remoteItems = selectedItems.filter {$0.isLocalItem == false}
            
            if actionTypes.contains(.createStory) && !selectedItems.contains(where: { return $0.fileType == .image }) {
                let index = actionTypes.index(where: { return $0 == .createStory })!
                actionTypes.remove(at: index)
            }
            
            if selectedItems.count != 1, let renameIndex = actionTypes.index(of: .rename) {
                actionTypes.remove(at: renameIndex)
            }

            if let printIndex = actionTypes.index(of: .print), !selectedItems.contains(where: { $0.fileType == .image }) {
                actionTypes.remove(at: printIndex)
            }
            
            if let editIndex = actionTypes.index(of: .edit), !selectedItems.contains(where: { $0.fileType == .image }) {
                actionTypes.remove(at: editIndex)
            }
            
            DispatchQueue.global().async {[weak self] in
                if let deleteOriginalIndex = actionTypes.index(of: .deleteDeviceOriginal) {
                    let serverObjects = selectedItems.filter({ !$0.isLocalItem })
                    if serverObjects.isEmpty {
                        actionTypes.remove(at: deleteOriginalIndex)
                    } else if selectedItems is [Item] {
                        MediaItemOperationsService.shared.getLocalDuplicates(remoteItems: selectedItems as! [Item], duplicatesCallBack: { [weak self] items in
                            if items.isEmpty {
                                //selectedItems = localDuplicates
                                actionTypes.remove(at: deleteOriginalIndex)
                            }
                            self?.semaphore.signal()
                        })
                        self?.semaphore.wait()
                    }
                    
                }
                
                if let `self` = self {
                    self.alertSheetModule?.showAlertSheet(with: actionTypes,
                                                     items: selectedItems,
                                                     presentedBy: sender,
                                                     onSourceView: nil,
                                                     excludeTypes: self.alertSheetExcludeTypes)
                }
            }
            
        } else {
            actionTypes = (interactor.alerSheetMoreActionsConfig?.initialTypes ?? [])
            
            if dataSource.allObjectIsEmpty() {
                if let downloadIdex = actionTypes.index(of: .download) {
                    actionTypes.remove(at: downloadIdex)
                }
                
                if let selectIndex = actionTypes.index(of: .select) {
                    actionTypes.remove(at: selectIndex)
                }
            }
            
            alertSheetModule?.showAlertSheet(with: actionTypes,
                                             presentedBy: sender,
                                             onSourceView: nil)
        }
        
    }
    
    func searchPressed(output: UIViewController?) {
        router.showSearchScreen(output: output)
    }
    
    
    // MARK: - View outbut/ TopBar/UnderNavBarBar Delegates
    
    func viewAppearanceChangedTopBar(asGrid: Bool) {
        viewAppearanceChanged(asGrid: asGrid)
    }
    
    func sortedPushedTopBar(with rule: MoreActionsConfig.SortRullesType) {
        sortedType = rule
        sortedPushed(with: rule.sortedRulesConveted)
    }
    
    func filtersTopBar(cahngedTo filters: [MoreActionsConfig.MoreActionsFileType]) {
        guard let firstFilter = filters.first else {
            return
        }
        var notificationTitle: String
        switch firstFilter {
        case .Photo:
            notificationTitle = TabBarViewController.notificationPhotosScreen
        case .Video:
            notificationTitle = TabBarViewController.notificationVideoScreen
        default:
            notificationTitle = TabBarViewController.notificationPhotosScreen
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationTitle), object: nil, userInfo: nil)
    }
    
    
    // MARK: subModule presenter
    
    func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems) {
        selectedItemsCallback(dataSource.getSelectedItems())
    }
    
    func operationFinished(withType type: ElementTypes, response: Any?) {
        debugLog("BaseFilesGreedPresenter operationFinished")
        debugPrint("finished")
        dataSource.setSelectionState(selectionState: false)
        dismissBottomBar(animated: true)
        view.stopSelection()
    }
    
    func operationFailed(withType type: ElementTypes) {
        debugLog("BaseFilesGreedPresenter operationFailed")
        debugPrint("failed")
        dismissBottomBar(animated: true)
        dataSource.setSelectionState(selectionState: false)
        view.stopSelection()
    }
    
    func selectModeSelected() {
        debugLog("BaseFilesGreedPresenter selectModeSelected")

        startEditing()
    }
    
    func printSelected() {
        debugLog("BaseFilesGreedPresenter printSelected")
        
        getSelectedItems { [weak self] selectedItems in
            let syncPhotos = selectedItems.filter { !$0.isLocalItem && $0.fileType == .image }
            if !syncPhotos.isEmpty {
                self?.router.showPrint(items: syncPhotos)
            }
        }
        
        
    }
    
    func selectAllModeSelected() {
        debugLog("BaseFilesGreedPresenter selectAllModeSelected")

        view.startSelection(with: dataSource.selectedItemsArray.count)
        dataSource.selectAll(isTrue: true)
    }
    
    func deSelectAll() {
        dataSource.selectAll(isTrue: false)
    }
    
    func stopModeSelected() {
         stopEditing() 
    }
    
    func getFolder() -> Item? {
        return interactor.getFolder()
    }
    
    func getStatus() -> ItemStatus {
        return view.status
    }
    
    func getSortTypeString() -> String {
        return self.sortedRule.descriptionForTitle
    }
    
    func moveBack() {
        router.showBack()
    }
    
    func deleteFromFaceImageAlbum(items: [BaseDataSourceItem]) { }
    
    func sortType() -> MoreActionsConfig.ViewType {
        return type
    }
    
    func openInstaPick() {
        startAsyncOperation()
        instaPickRoutingService.getViewController(isCheckAnalyzesCount: true, success: { [weak self] vc in
            self?.asyncOperationSuccess()
            if vc is InstapickPopUpController {
                self?.router.openNeededInstaPick(viewController: vc)
            }
        }) { [weak self] error in
            self?.asyncOperationFail(errorMessage: error.description)
        }
    }
    
    // MARK: - BaseFilesGreedModuleOutput
    
    func reloadType(_ type: MoreActionsConfig.ViewType, sortedType: MoreActionsConfig.SortRullesType, fieldType: FieldValue) {
        debugLog("BaseFilesGreedPresenter reloadType")

        self.type = type
        self.sortedType = sortedType
        sortedRule = sortedType.sortedRulesConveted

        type == .Grid ? dataSource.updateDisplayngType(type: .list) : dataSource.updateDisplayngType(type: .greed)
        dataSource.currentSortType = sortedType.sortedRulesConveted
        reloadData()
        
        let gridListTopBarConfig = GridListTopBarConfig(defaultGridListViewtype: type, defaultSortType: sortedType)
        topBarConfig = gridListTopBarConfig
        
        setupTopBar()
    }
    
    func changeCover() { }
}
