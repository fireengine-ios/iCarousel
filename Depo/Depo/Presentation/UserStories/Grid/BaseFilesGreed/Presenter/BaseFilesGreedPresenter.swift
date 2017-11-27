
//
//  BaseFilesGreedPresenter.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class BaseFilesGreedPresenter: BasePresenter, BaseFilesGreedModuleInput, BaseFilesGreedViewOutput, BaseFilesGreedInteractorOutput, BaseDataSourceForCollectionViewDelegate {
    
    typealias Item = WrapData
    
    let player: MediaPlayer = factory.resolve()
    
    var dataSource: BaseDataSourceForCollectionView
    
    weak var view: BaseFilesGreedViewInput!
    
    var interactor: BaseFilesGreedInteractorInput!
    
    var router: BaseFilesGreedRouterInput!
    
    var sortedRule: SortedRules
    
    var filters: [GeneralFilesFiltrationType] = []
    
    let custoPopUp = CustomPopUp()
    
    var bottomBarConfig: EditingBarConfig?
    
    weak var bottomBarPresenter: BottomSelectionTabBarModuleInput?
    
    weak var sliderModule: LBAlbumLikePreviewSliderModuleInput?
    
    var topBarConfig: GridListTopBarConfig?
    
    var alertSheetModule: AlertFilesActionsSheetModuleInput?
    
    init(sortedRule: SortedRules = .timeDown) {
        self.sortedRule = sortedRule
        self.dataSource = BaseDataSourceForCollectionView(sortingRules: sortedRule)
        super.init()
    }
    
    func viewIsReady(collectionView: UICollectionView) {
        interactor.viewIsReady()
        if let unwrapedFilters = interactor.originalFilesTypeFilter {
            filters = unwrapedFilters
        }
        dataSource.setupCollectionView(collectionView: collectionView,
                                       filters: interactor.originalFilesTypeFilter)
       
        dataSource.delegate = self
        
        view.setupInitialState()
        setupTopBar()
        dataSource.currentSortType = sortedRule
        getContent()
        reloadData()
    }
    
    func searchByText(searchText: String) {
        uploadData(searchText)
    }
    
    func onReloadData(){
        
//        dataSource.dropData()
        reloadData()
    }
    
    func onStartCreatingPhotoAndVideos(){
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
//        startAsyncOperation()
        interactor.nextItems(searchText,
                             sortBy: sortedRule.sortingRules,
                             sortOrder: sortedRule.sortOder, newFieldValue: getFileFilter())
    }

    func reloadData() {
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
        asyncOperationFail(errorMessage: errorString)
    }
    
    func serviceAreNotAvalible() {
        
    }

    func getContentWithSuccessEnd() {
        debugPrint("???getContentWithSuccessEnd()")
        asyncOperationSucces()
        dataSource.isPaginationDidEnd = true
        view?.stopRefresher()
        dataSource.appendCollectionView(items: [])
        dataSource.reloadData()
    }
    
    func getContentWithSuccess(items: [WrapData]){
        if (view == nil){
            return
        }
        debugPrint("???getContentWithSuccess()")
        asyncOperationSucces()
        view.stopRefresher()
        
//        items.count < interactor.requestPageSize ? (dataSource.isPaginationDidEnd = true) : (dataSource.isPaginationDidEnd = false)

        dataSource.appendCollectionView(items: items)

        dataSource.reloadData()
    }
    
    func getContentWithSuccess(array: [[BaseDataSourceItem]]) {
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
        view.showCustomPopUpWithInformationAboutAccessToMediaLibrary()
    }
    
    func needShowNoFileView()-> Bool{
        return interactor.needShowNoFileView()
    }
    
    func textForNoFileLbel() -> String{
        return interactor.textForNoFileLbel()
    }
    
    func textForNoFileButton() -> String{
        return interactor.textForNoFileButton()
    }
    
    func imageForNoFileImageView() -> UIImage{
        return interactor.imageForNoFileImageView()
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
    
    func onItemSelected(item: BaseDataSourceItem, from data:[[BaseDataSourceItem]]) {
        if item.fileType.isUnSupportedOpenType {
            if interactor.remoteItems is MusicService {
                guard let array = data as? [[Item]],
                    let wrappered = item as? Item
                    else { return }
                
                let list = array.flatMap{ $0 }
                guard let startIndex = list.index(of: wrappered) else { return }
                player.play(list: list, startAt: startIndex)
                player.play()
                //                SingleSong.default.playWithItems(list: array.flatMap({$0}), startItem: wrappered)
            } else {
                router.onItemSelected(item: item, from: data)
            }
        } else {
            custoPopUp.showCustomInfoAlert(withTitle: TextConstants.warning, withText: TextConstants.theFileIsNotSupported, okButtonText: TextConstants.ok)
        }
    }
    
    func getCellSizeForList() -> CGSize {
        return CGSize(width: view.getCollectionViewWidth(), height: 65)
    }
    
    func getCellSizeForGreed() -> CGSize {
        if (Device.isIpad) {
            return CGSize(width: 90, height: 90)
        }
        
        let w = view.getCollectionViewWidth()
        let cellW: CGFloat = (w - NumericConstants.iPhoneGreedInset * 2 - NumericConstants.iPhoneGreedHorizontalSpace * NumericConstants.numerCellInLineOnIphone)/NumericConstants.numerCellInLineOnIphone
        return CGSize(width: cellW, height: cellW)
    }
    
    func onLongPressInCell() {
        startEditing()
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
    
    private func startEditing() {
        //call tabbar
        view.setupSelectionStyle(isSelection: true)
        view.setThreeDotsMenu(active: dataSource.selectedItemsArray.count > 0)
        dataSource.setSelectionState(selectionState: true)
    }
    
    
    private func stopEditing() {
        bottomBarPresenter?.dismiss(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationShowPlusTabBar), object: nil)
        view.setupSelectionStyle(isSelection: false)
        dataSource.setSelectionState(selectionState: false)
        view.setThreeDotsMenu(active: true)
    }
    
    func onChangeSelectedItemsCount(selectedItemsCount: Int) {
        if (selectedItemsCount == 0){
            bottomBarPresenter?.dismiss(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationShowPlusTabBar), object: nil)
        }else{
            bottomBarPresenter?.show(animated: true, onView: nil)
        }
        
        setupNewBottomBarConfig()
        view.setThreeDotsMenu(active: dataSource.selectedItemsArray.count > 0)
        self.view.selectedItemsCountChange(with: selectedItemsCount)
    }
    
    private func setupNewBottomBarConfig() {
        
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
        alertSheetModule?.showSpecifiedAlertSheet(with: item,
                                                  presentedBy: sender,
                                                  onSourceView: nil,
                                                  viewController: nil)
    }
    
    func onMaxSelectionExeption(){
        
    }
    
    
    //MARK: - MoreActionsViewDelegate
    
    func viewAppearanceChanged(asGrid: Bool){
        if (asGrid){
            dataSource.updateDisplayngType(type: .greed)
        }else{
            dataSource.updateDisplayngType(type: .list)
        }
    }
    
    func sortedPushed(with rule: SortedRules) {
        sortedRule = rule
        view.changeSortingRepresentation(sortType: rule)
//        dataSource.dropData()
        dataSource.currentSortType = rule
//        dataSource.reloadData()
        reloadData()
    }
    
    func selectPressed(type: MoreActionsConfig.SelectedType) {
        if (type == .Selected) {
            dataSource.selectAll(isTrue: true)
            startEditing()
        } else {
            dataSource.selectAll(isTrue: false)
            stopEditing()
        }
    }
    
    func viewWillDisappear() {
        bottomBarPresenter?.dismiss(animated: true)
        dataSource.setSelectionState(selectionState: false)
        view.setupSelectionStyle(isSelection: false)
    }
    
    func viewWillAppear() {
        if dataSource.selectedItemsArray.count > 0 {
            bottomBarPresenter?.show(animated: true, onView: nil)
        }
//        UploadService.default.uploadOnDemand(success: {
//            DispatchQueue.main.async {
//                CustomPopUp.sharedInstance.showCustomInfoAlert(withTitle: "", withText: TextConstants.uploadSuccessful, okButtonText: TextConstants.ok)
//            }
//            print("Upload success")
//        }) { (errorResponse) in
//            print("Upload fail")
//        }
//        
//        reloadData()

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
            
            let remoteItems = selectedItems.filter { $0.isLocalItem == false}

            if remoteItems.contains(where: { return !($0.favorites) } ) {
                actionTypes.append(.addToFavorites)
            }
            if remoteItems.contains(where: { return $0.favorites } ) {
                actionTypes.append(.removeFromFavorites)
            }
            
            if actionTypes.contains(.createStory) && remoteItems.contains(where: { return $0.fileType != .image } ) {
                let index = actionTypes.index(where: { return $0 == .createStory})!
                actionTypes.remove(at: index)
            }
            
            if selectedItems.count != 1, let renameIndex = actionTypes.index(of: .rename) {
                actionTypes.remove(at: renameIndex)
            }
            
            let noSyncItems = selectedItems.filter{ $0.syncStatus != SyncWrapperedStatus.synced }
            if noSyncItems.isEmpty {
                actionTypes.append(.print)
            }
            alertSheetModule?.showAlertSheet(with: actionTypes,
                                             items: selectedItems,
                                             presentedBy: sender,
                                             onSourceView: nil)
        } else {
            actionTypes  = (interactor.alerSheetMoreActionsConfig?.initialTypes ?? [])
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
        sortedPushed(with: rule.sortedRulesConveted)
    }
    
    func filtersTopBar(cahngedTo filters: [MoreActionsConfig.MoreActionsFileType]) {
        self.filters = filters.map{ $0.convertToGeneralFilterFileType() }
        
        stopEditing()
//        dataSource.dropData()
        dataSource.originalFilters = self.filters
        reloadData()
    }
    
    
    // MARK: subModule presenter
    
    var selectedItems: [BaseDataSourceItem] {
        return dataSource.getSelectedItems()
    }
    
    func operationFinished(withType type: ElementTypes, response: Any?) {
        debugPrint("finished")
        dataSource.setSelectionState(selectionState: false)
        view.setupSelectionStyle(isSelection: false)
        onChangeSelectedItemsCount(selectedItemsCount: 0)
    }
    
    func operationFailed(withType type: ElementTypes) {
        debugPrint("failed")
        dataSource.setSelectionState(selectionState: false)
        view.setupSelectionStyle(isSelection: false)
        onChangeSelectedItemsCount(selectedItemsCount: 0)
    }
    
    func selectModeSelected() {
        startEditing()
    }
    
    func printSelected() {
        router.showPrint(items: selectedItems)
    }
    
    func selectAllModeSelected() {
        view.setupSelectionStyle(isSelection: true)
        dataSource.selectAll(isTrue: true)
    }
    
    func shareModeSelected() {
         stopEditing() 
    }
    
    func getFolder() -> Item? {
        return interactor.getFolder()
    }
    
    func getSortTypeString() -> String {
        return self.sortedRule.descriptionForTitle
    }
}

