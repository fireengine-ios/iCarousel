//
//  BaseFilesGreedPresenter.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class BaseFilesGreedPresenter: BasePresenter, BaseFilesGreedModuleInput, BaseFilesGreedViewOutput, BaseFilesGreedInteractorOutput, BaseDataSourceForCollectionViewDelegate, BaseFilesGreedModuleOutput {
    
    lazy var player: MediaPlayer = factory.resolve()
    
    var dataSource: BaseDataSourceForCollectionView
    
    weak var view: BaseFilesGreedViewInput!
    
    weak var moduleOutput: BaseFilesGreedModuleOutput?
    
    var interactor: BaseFilesGreedInteractorInput!
    
    var router: BaseFilesGreedRouterInput!
    
    var sortedRule: SortedRules
    
    var filters: [GeneralFilesFiltrationType] = []
    
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
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.baseFilesGreed)
    
    init(sortedRule: SortedRules = .timeDown) {
        self.sortedRule = sortedRule
        self.dataSource = BaseDataSourceForCollectionView(sortingRules: sortedRule)
        type = .Grid
        sortedType = .TimeNewOld
        super.init()
    }
    
    func viewIsReady(collectionView: UICollectionView) {
        log.debug("BaseFilesGreedPresenter viewIsReady")

        interactor.viewIsReady()
        if let unwrapedFilters = interactor.originalFilesTypeFilter {
            filters = unwrapedFilters
        }
        dataSource.setupCollectionView(collectionView: collectionView,
                                       filters: interactor.originalFilesTypeFilter)
       
        dataSource.delegate = self
        dataSource.needShowProgressInCell = needShowProgressInCells
        dataSource.needShowCustomScrollIndicator = needShowScrollIndicator
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
    
    func subscribeDataSource() {
        ItemOperationManager.default.startUpdateView(view: dataSource)
    }
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: dataSource)
    }
    
    func searchByText(searchText: String) {
        log.debug("BaseFilesGreedPresenter searchByText")

        uploadData(searchText)
    }
    
    func onReloadData() {
        log.debug("BaseFilesGreedPresenter onReloadData")
        
//        dataSource.dropData()
        reloadData()
    }
    
    func onStartCreatingPhotoAndVideos() {
        log.debug("BaseFilesGreedPresenter onStartCreatingPhotoAndVideos")

        let service = interactor.getRemoteItemsService()
        if service is AllFilesService ||
            service is FavouritesService ||
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
    
    private func getFileFilter() -> FieldValue {
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
        log.debug("BaseFilesGreedPresenter compoundAllFiltersAndNextItems")
//        startAsyncOperation()
        interactor.nextItems(searchText,
                             sortBy: sortedRule.sortingRules,
                             sortOrder: sortedRule.sortOder, newFieldValue: getFileFilter())
    }

    func reloadData() {
        log.debug("BaseFilesGreedPresenter reloadData")
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
        log.debug("BaseFilesGreedPresenter uploadData")

        startAsyncOperation()
        compoundAllFiltersAndNextItems(searchText: searchText)
    }
    
    func onNextButton() {
        
    }
    
    // MARK: - Request OUTPUT
    func getContentWithFail(errorString: String?) {
        view?.stopRefresher()
        dataSource.isPaginationDidEnd = false
        debugPrint("???getContentWithFail()")
        log.debug("BaseFilesGreedPresenter getContentWithFail")
        asyncOperationFail(errorMessage: errorString)
    }
    
    func serviceAreNotAvalible() {
        
    }

    func getContentWithSuccessEnd() {
        log.debug("BaseFilesGreedPresenter getContentWithSuccessEnd")
        debugPrint("???getContentWithSuccessEnd()")
//        asyncOperationSucces()
        dataSource.isPaginationDidEnd = true
        view?.stopRefresher()
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            self.dataSource.appendCollectionView(items: [], pageNum: self.interactor.requestPageNum)
        }
//        dataSource.reloadData()
//        updateNoFilesView()
//=======
//        dataSource.appendCollectionView(items: [])
//        dataSource.reloadData()
//        updateNoFilesView()
//        updateThreeDotsButton()
//>>>>>>> develop
    }
    
    func getContentWithSuccess(items: [WrapData]) {
        log.debug("BaseFilesGreedPresenter getContentWithSuccess")

        if (view == nil) {
            return
        }
//        items.count < interactor.requestPageSize ? (dataSource.isPaginationDidEnd = true) : (dataSource.isPaginationDidEnd = false)
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
           self.dataSource.appendCollectionView(items: items, pageNum: self.interactor.requestPageNum)
        }
        


//        dataSource.reloadData()
//        updateNoFilesView()
//=======
//        dataSource.appendCollectionView(items: items)
//
//        dataSource.reloadData()
//        updateNoFilesView()
//        updateThreeDotsButton()
//>>>>>>> develop
    }
    
    func getContentWithSuccess(array: [[BaseDataSourceItem]]) {
        log.debug("BaseFilesGreedPresenter getContentWithSuccess")

        if (view == nil) {
            return
        }
        debugPrint("???getContentWithSuccessEnd()")
        asyncOperationSucces()
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
        //        interactor.nextItems(nil, sortBy: .name,
        //                             sortOrder: .asc, newFieldValue: <#FieldValue?#>)
        compoundAllFiltersAndNextItems()
    }
    
    func showCustomPopUpWithInformationAboutAccessToMediaLibrary() {
        log.debug("BaseFilesGreedPresenter showCustomPopUpWithInformationAboutAccessToMediaLibrary")

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
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
    
    // MARK: BaseGridDataSourceForCollectionView
    
    func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]]) {
        log.debug("BaseFilesGreedPresenter onItemSelected")

        if item.fileType.isUnSupportedOpenType {
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
        reloadData()
    }
    
    func filesAppendedAndSorted() {
        DispatchQueue.main.async {
            self.view.stopRefresher()
            self.updateNoFilesView()
            self.asyncOperationSucces()
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
    
    private func setupTopBar() {
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
    
    private func updateNoFilesView() {
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
        if !(getRemoteItemsService() is AlbumDetailService), !(getRemoteItemsService() is PeopleItemsService) {
            view.setThreeDotsMenu(active: !needShowNoFileView())
        }
    }
    
    func onChangeSelectedItemsCount(selectedItemsCount: Int) {
        setupNewBottomBarConfig()
        log.debug("BaseFilesGreedPresenter onChangeSelectedItemsCount")

        if (selectedItemsCount == 0) {
            log.debug("BaseFilesGreedPresenter onChangeSelectedItemsCount selectedItemsCount == 0")

            dismissBottomBar(animated: true)
        } else {
            log.debug("BaseFilesGreedPresenter onChangeSelectedItemsCount selectedItemsCount != 0")

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
        log.debug("BaseFilesGreedPresenter onMoreActions")

        alertSheetModule?.showSpecifiedAlertSheet(with: item,
                                                  presentedBy: sender,
                                                  onSourceView: nil,
                                                  viewController: nil)
    }
    
    func onMaxSelectionExeption() {
        
    }
    
    // MARK: - MoreActionsViewDelegate
    
    func viewAppearanceChanged(asGrid: Bool) {
        log.debug("BaseFilesGreedPresenter viewAppearanceChanged")

        if (asGrid) {
            log.debug("BaseFilesGreedPresenter viewAppearanceChanged Grid")

            dataSource.updateDisplayngType(type: .greed)
            type = .List
            moduleOutput?.reloadType(type, sortedType: sortedType, fieldType: getFileFilter())
        } else {
            log.debug("BaseFilesGreedPresenter viewAppearanceChanged List")

            dataSource.updateDisplayngType(type: .list)
            type = .Grid
            moduleOutput?.reloadType(type, sortedType: sortedType, fieldType: getFileFilter())
        }
    }
    
    func sortedPushed(with rule: SortedRules) {
        log.debug("BaseFilesGreedPresenter sortedPushed")

        sortedRule = rule
        view.changeSortingRepresentation(sortType: rule)
        dataSource.currentSortType = rule
        (rule == .sizeAZ || rule == .sizeZA) ? (dataSource.isHeaderless = true) : (dataSource.isHeaderless = false)

        moduleOutput?.reloadType(type, sortedType: sortedType, fieldType: getFileFilter())
        reloadData()
    }
    
    func selectPressed(type: MoreActionsConfig.SelectedType) {
        log.debug("BaseFilesGreedPresenter selectPressed")

        if (type == .Selected) {
            log.debug("BaseFilesGreedPresenter selectPressed type == selected")

            dataSource.selectAll(isTrue: true)
            startEditing()
        } else {
            log.debug("BaseFilesGreedPresenter selectPressed type != selected")

            dataSource.selectAll(isTrue: false)
            stopEditing()
        }
    }
    
    func viewWillDisappear() {
        bottomBarPresenter?.dismiss(animated: true)
        dataSource.setSelectionState(selectionState: false)
        view.stopSelection()
    }
    
    func viewWillAppear() {
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
                        CoreDataStack.default.getLocalDuplicates(remoteItems: selectedItems as! [Item], duplicatesCallBack: { [weak self] items in
                            if items.count == 0 {
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
    
    var selectedItems: [BaseDataSourceItem] {
        return dataSource.getSelectedItems()
    }
    
    func operationFinished(withType type: ElementTypes, response: Any?) {
        log.debug("BaseFilesGreedPresenter operationFinished")
        debugPrint("finished")
        dataSource.setSelectionState(selectionState: false)
        dismissBottomBar(animated: true)
        view.stopSelection()
        if type == .removeAlbum || type == .completelyDeleteAlbums {
            dismissBottomBar(animated: true)
        }
    }
    
    func operationFailed(withType type: ElementTypes) {
        log.debug("BaseFilesGreedPresenter operationFailed")
        debugPrint("failed")
        dismissBottomBar(animated: true)
        dataSource.setSelectionState(selectionState: false)
        view.stopSelection()
    }
    
    func selectModeSelected() {
        log.debug("BaseFilesGreedPresenter selectModeSelected")

        startEditing()
    }
    
    func printSelected() {
        log.debug("BaseFilesGreedPresenter printSelected")

        let syncPhotos = selectedItems.filter { !$0.isLocalItem && $0.fileType == .image }
        if !syncPhotos.isEmpty {
            router.showPrint(items: syncPhotos)
        }
    }
    
    func selectAllModeSelected() {
        log.debug("BaseFilesGreedPresenter selectAllModeSelected")

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
    
    // MARK: - BaseFilesGreedModuleOutput
    
    func reloadType(_ type: MoreActionsConfig.ViewType, sortedType: MoreActionsConfig.SortRullesType, fieldType: FieldValue) {
        log.debug("BaseFilesGreedPresenter reloadType")

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
