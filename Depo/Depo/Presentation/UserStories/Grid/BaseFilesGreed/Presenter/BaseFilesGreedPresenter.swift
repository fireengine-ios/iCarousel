
//
//  BaseFilesGreedPresenter.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class BaseFilesGreedPresenter: BasePresenter, BaseFilesGreedModuleInput, BaseFilesGreedViewOutput, BaseFilesGreedInteractorOutput, BaseDataSourceForCollectionViewDelegate, BaseFilesGreedModuleOutput {

    typealias Item = WrapData
    
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
    
    func subscribeDataSource(){
        ItemOperationManager.default.startUpdateView(view: dataSource)
    }
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: dataSource)
    }
    
    func searchByText(searchText: String) {
        log.debug("BaseFilesGreedPresenter searchByText")

        uploadData(searchText)
    }
    
    func onReloadData(){
        log.debug("BaseFilesGreedPresenter onReloadData")
        
//        dataSource.dropData()
        reloadData()
    }
    
    func onStartCreatingPhotoAndVideos(){
        log.debug("BaseFilesGreedPresenter onStartCreatingPhotoAndVideos")

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

        dataSource.dropData()
        dataSource.currentSortType = sortedRule
        dataSource.reloadData()
        startAsyncOperation()
        dataSource.isPaginationDidEnd = false
        interactor.reloadItems(nil,
                               sortBy: sortedRule.sortingRules,
                               sortOrder: sortedRule.sortOder, newFieldValue: getFileFilter())
    }
    
    func uploadData(_ searchText: String? = nil){
        log.debug("BaseFilesGreedPresenter uploadData")

        startAsyncOperation()
        compoundAllFiltersAndNextItems(searchText: searchText)
    }
    
    func onNextButton(){
        
    }
    
    //MARK:- Request OUTPUT
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
        asyncOperationSucces()
        dataSource.isPaginationDidEnd = true
        view?.stopRefresher()
        dataSource.appendCollectionView(items: [])
        dataSource.reloadData()
        updateNoFilesView()
    }
    
    func getContentWithSuccess(items: [WrapData]){
        log.debug("BaseFilesGreedPresenter getContentWithSuccess")

        if (view == nil){
            return
        }
        debugPrint("???getContentWithSuccess()")
        asyncOperationSucces()
        view.stopRefresher()
        
//        items.count < interactor.requestPageSize ? (dataSource.isPaginationDidEnd = true) : (dataSource.isPaginationDidEnd = false)

        dataSource.appendCollectionView(items: items)

        dataSource.reloadData()
        updateNoFilesView()
    }
    
    func getContentWithSuccess(array: [[BaseDataSourceItem]]) {
        log.debug("BaseFilesGreedPresenter getContentWithSuccess")

        if (view == nil) {
            return
        }
        debugPrint("???getContentWithSuccessEnd()")
        asyncOperationSucces()
        view.stopRefresher()
        if let dataSourceForArray = dataSource as? ArrayDataSourceForCollectionView{
            dataSourceForArray.configurateWithArray(array: array)
        } else {
            dataSource.reloadData()
        }
        updateNoFilesView()
    }
    
    func isArrayDataSource() -> Bool{
        return false
    }
    
    func getNextItems() {
        //        interactor.nextItems(nil, sortBy: .name,
        //                             sortOrder: .asc, newFieldValue: <#FieldValue?#>)
        compoundAllFiltersAndNextItems()
    }
    
    func showCustomPopUpWithInformationAboutAccessToMediaLibrary(){
        log.debug("BaseFilesGreedPresenter showCustomPopUpWithInformationAboutAccessToMediaLibrary")

        view.showCustomPopUpWithInformationAboutAccessToMediaLibrary()
    }
    
    func needShowNoFileView() -> Bool {
        return dataSource.getAllObjects().isEmpty
    }
    
    func getRemoteItemsService() -> RemoteItemsService{
        return interactor.getRemoteItemsService()
    }
    
    func onCancelSelection(){
        stopEditing()
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
    
    //MARK: BaseGridDataSourceForCollectionView
    
    func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]]) {
        log.debug("BaseFilesGreedPresenter onItemSelected")

        if item.fileType.isUnSupportedOpenType {
            let sameTypeFiles: [BaseDataSourceItem] = data.flatMap{ return $0 }.filter{ $0.fileType == item.fileType }
            router.onItemSelected(selectedItem: item, sameTypeItems: sameTypeFiles,
                                  type: type, sortType: sortedType, moduleOutput: self)
        } else {
            let vc = PopUpController.with(title: TextConstants.warning, message: TextConstants.theFileIsNotSupported,
                                          image: .error, buttonTitle: TextConstants.ok)
            UIApplication.topController()?.present(vc, animated: false, completion: nil)
        }
    }
    
    func getCellSizeForList() -> CGSize {
        return CGSize(width: view.getCollectionViewWidth(), height: 65)
    }
    
    func getCellSizeForGreed() -> CGSize {
        var cellWidth:CGFloat = 180
        
        if (Device.isIpad) {
            cellWidth = (view.getCollectionViewWidth() - NumericConstants.iPadGreedInset * 2  - NumericConstants.iPadGreedHorizontalSpace * (NumericConstants.numerCellInLineOnIpad - 1))/NumericConstants.numerCellInLineOnIpad
        } else {
            cellWidth = (view.getCollectionViewWidth() - NumericConstants.iPhoneGreedInset * 2  - NumericConstants.iPhoneGreedHorizontalSpace * (NumericConstants.numerCellInLineOnIphone - 1))/NumericConstants.numerCellInLineOnIphone
        }
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func onLongPressInCell() {
        startEditing()
    }
    
    func needReloadData(){
        reloadData()
    }
    
    
    //MARK: - UnderNavBarBar/TopBar
    
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
        bottomBarPresenter?.dismiss(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationShowPlusTabBar), object: nil)
        view.stopSelection()
        dataSource.setSelectionState(selectionState: false)
        view.setThreeDotsMenu(active: true)
    }
    
    private func updateNoFilesView() {
        if needShowNoFileView() {
            if interactor.remoteItems is PhotoAndVideoService ||
                interactor.remoteItems is MusicService ||
                interactor.remoteItems is DocumentService {
                view.showNoFilesWith(text: interactor.textForNoFileLbel(),
                                     image: interactor.imageForNoFileImageView(),
                                     createFilesButtonText: interactor.textForNoFileButton())
            } else {
                view.showNoFilesTop()
            }
        } else {
            view.hideNoFiles()
        }
    }
    
    func onChangeSelectedItemsCount(selectedItemsCount: Int) {
        setupNewBottomBarConfig()
        log.debug("BaseFilesGreedPresenter onChangeSelectedItemsCount")

        if (selectedItemsCount == 0){
            log.debug("BaseFilesGreedPresenter onChangeSelectedItemsCount selectedItemsCount == 0")

            bottomBarPresenter?.dismiss(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationShowPlusTabBar), object: nil)
        }else{
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
    
    func onMaxSelectionExeption(){
        
    }
    
    //MARK: - MoreActionsViewDelegate
    
    func viewAppearanceChanged(asGrid: Bool){
        log.debug("BaseFilesGreedPresenter viewAppearanceChanged")

        if (asGrid){
            log.debug("BaseFilesGreedPresenter viewAppearanceChanged Grid")

            dataSource.updateDisplayngType(type: .greed)
            type = .List
            moduleOutput?.reloadType(type, sortedType: sortedType, fieldType: getFileFilter())
        }else{
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
            var selectedItems = [WrapData]()
            
            for items in dataSource.allItems {
                selectedItems += items.filter { selectedItemsUUIDs.contains($0.uuid) }
            }
            
            //let remoteItems = selectedItems.filter {$0.isLocalItem == false}
            
            if actionTypes.contains(.createStory) && !selectedItems.contains(where: { return $0.fileType == .image } ) {
                let index = actionTypes.index(where: { return $0 == .createStory})!
                actionTypes.remove(at: index)
            }
            
            if selectedItems.count != 1, let renameIndex = actionTypes.index(of: .rename) {
                actionTypes.remove(at: renameIndex)
            }

            if let printIndex = actionTypes.index(of: .print), !selectedItems.contains(where: {$0.fileType == .image}) {
                actionTypes.remove(at: printIndex)
            }
            
            if let editIndex = actionTypes.index(of: .edit), !selectedItems.contains(where: {$0.fileType == .image}) {
                actionTypes.remove(at: editIndex)
            }
            
            if let deleteOriginalIndex = actionTypes.index(of: .deleteDeviceOriginal) {
                let serverObjects = selectedItems.filter({ return !$0.isLocalItem })
                if serverObjects.isEmpty {
                    actionTypes.remove(at: deleteOriginalIndex)
                }else{
                    let localDuplicates = CoreDataStack.default.getLocalDuplicates(remoteItems: selectedItems)
                    if localDuplicates.count == 0 {
                        //selectedItems = localDuplicates
                        actionTypes.remove(at: deleteOriginalIndex)
                    } else {
                        
                    }
                }
                
            }
            
            alertSheetModule?.showAlertSheet(with: actionTypes,
                                             items: selectedItems,
                                             presentedBy: sender,
                                             onSourceView: nil,
                                             excludeTypes: alertSheetExcludeTypes)
        } else {
            actionTypes  = (interactor.alerSheetMoreActionsConfig?.initialTypes ?? [])
            if dataSource.allMediaItems.count == 0, let downloadIdex = actionTypes.index(of: .download) {
                actionTypes.remove(at: downloadIdex)
            }
            alertSheetModule?.showAlertSheet(with: actionTypes,
                                             presentedBy: sender,
                                             onSourceView: nil)
        }
        
    }
    
    
    //MARK: - View outbut/ TopBar/UnderNavBarBar Delegates
    
    func viewAppearanceChangedTopBar(asGrid: Bool) {
        viewAppearanceChanged(asGrid: asGrid)
    }
    
    func sortedPushedTopBar(with rule:  MoreActionsConfig.SortRullesType) {
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
        view.stopSelection()
    }
    
    func operationFailed(withType type: ElementTypes) {
        log.debug("BaseFilesGreedPresenter operationFailed")
        debugPrint("failed")
        dataSource.setSelectionState(selectionState: false)
        view.stopSelection()
    }
    
    func selectModeSelected() {
        log.debug("BaseFilesGreedPresenter selectModeSelected")

        startEditing()
    }
    
    func printSelected() {
        log.debug("BaseFilesGreedPresenter printSelected")

        let syncPhotos = selectedItems.filter{ !$0.isLocalItem && $0.fileType == .image }
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
    
    func sortType() -> MoreActionsConfig.ViewType {
        return type
    }
    
    //MARK: - BaseFilesGreedModuleOutput
    
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
    
}

