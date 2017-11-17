
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
    
    var dataSource = BaseDataSourceForCollectionView()

    weak var view: BaseFilesGreedViewInput!
   
    var interactor: BaseFilesGreedInteractorInput!
    
    var router: BaseFilesGreedRouterInput!
    
    var sortedRule: SortedRules = .timeDown
    
    var filters: [GeneralFilesFiltrationType] = []
    
    let custoPopUp = CustomPopUp()

    var bottomBarConfig: EditingBarConfig?
    
    weak var bottomBarPresenter: BottomSelectionTabBarModuleInput?
    
    weak var sliderModule: LBAlbumLikePreviewSliderModuleInput?
    
    var topBarConfig: GridListTopBarConfig?
    
    var alertSheetModule: AlertFilesActionsSheetModuleInput?
    
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
        
        getContent()
        
    }
    
    func searchByText(searchText: String) {
        uploadData(searchText)
    }
    
    func onReloadData(){
        dataSource.isPaginationDidEnd = false
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
        interactor.nextItems(searchText,
                             sortBy: sortedRule.sortingRules,
                             sortOrder: sortedRule.sortOder, newFieldValue: getFileFilter())
    }
    
    func reloadData() {
        startAsyncOperation()
        interactor.reloadItems(nil,
                               sortBy: sortedRule.sortingRules,
                               sortOrder: sortedRule.sortOder, newFieldValue: getFileFilter())
    }
    
    func uploadData(_ searchText: String? = nil){
        startAsyncOperation()
        compoundAllFiltersAndNextItems(searchText: searchText)
//        filters.convertToSearchRequestFieldValue()
//        interactor.nextItems(searchText,
//                             sortBy: .name,
//                             sortOrder: .asc, newFieldValue: nil)
    }
    
    func onNextButton(){
        
    }
    
    func getContentWithFail(errorString: String?) {
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
        dataSource.fetchService.performFetch(sortingRules: sortedRule,
                                             filtes: filters,
                                             delegate: dataSource)
        dataSource.reloadData()
    }
    
    func getContentWithSuccess(){
        if (view == nil){
            return
        }
        debugPrint("???getContentWithSuccess()")
        asyncOperationSucces()
        view.stopRefresher()
//        dataSource.reloadData()
        // TODO:
//        let sectionsCount = dataSource.numberOfSections(in: dataSource.collectionView!)
//        let  needShow = (sectionsCount == 0) ? interactor.needShowNoFileView() : false
//
//        view.setCollectionViewVisibilityStatus(visibilityStatus: needShow)
        
//        dataSource.fetchService.controller.delegate = dataSource
        dataSource.fetchService.performFetch(sortingRules: sortedRule,
                                             filtes: filters,
                                             delegate: dataSource)
        dataSource.reloadData()
    }
    
    func getContentWithSuccess(array: [[BaseDataSourceItem]]){
        if (view == nil){
            return
        }
        debugPrint("???getContentWithSuccessEnd()")
        //
        asyncOperationSucces()
        view.stopRefresher()
        if let dataSourceForArray = dataSource as? ArrayDataSourceForCollectionView{
            dataSourceForArray.configurateWithArray(array: array)
        }else{
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
        dataSource.setSelectionState(selectionState: true)
    }
    

    private func stopEditing() {
        bottomBarPresenter?.dismiss(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationShowPlusTabBar), object: nil)
        view.setupSelectionStyle(isSelection: false)
        dataSource.setSelectionState(selectionState: false)
    }

    func onChangeSelectedItemsCount(selectedItemsCount: Int) {
        if (selectedItemsCount == 0){
            bottomBarPresenter?.dismiss(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationShowPlusTabBar), object: nil)
        }else{
            bottomBarPresenter?.show(animated: true, onView: nil)
        }
        
        setupNewBottomBarConfig()
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
    
    func sortedPushed(with rule: SortedRules){
        sortedRule = rule
        view.changeSortingRepresentation(sortType: rule)
        dataSource.fetchService.performFetch(sortingRules: sortedRule,
                                             filtes: self.filters,
                                             delegate: dataSource)
        dataSource.reloadData()
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
        
        UploadService.default.uploadOnDemand(success: {
            DispatchQueue.main.async {
                CustomPopUp.sharedInstance.showCustomInfoAlert(withTitle: "", withText: TextConstants.uploadSuccessful, okButtonText: TextConstants.ok)
            }
            print("Upload success")
        }) { (errorResponse) in
            print("Upload fail")
        }
        
        reloadData()
    }
    
    func moreActionsPressed(sender: Any) {
        
        let selectionMode = dataSource.isInSelectionMode()
        var type = (interactor.alerSheetMoreActionsConfig?.selectionModeTypes ?? [])
        if selectionMode {
            let list = Array(dataSource.selectedItemsArray)
            let selectedItems = CoreDataStack.default.mediaItemByUUIDs(uuidList: list)
            let items = selectedItems.filter{ $0.isLocalItem == false}
            if !items.isEmpty {
                type.append(.addToCmeraRoll)
            }
            alertSheetModule?.showAlertSheet(with: type,
                                             items: selectedItems,
                                             presentedBy: sender,
                                             onSourceView: nil)
        } else {
            type  = (interactor.alerSheetMoreActionsConfig?.initialTypes ?? [])
            alertSheetModule?.showAlertSheet(with: type,
                                             presentedBy: sender,
                                             onSourceView: nil)
        }
        
    }
    
    
    //MARK: - View outbut/ TopBar/UnderNavBarBar Delegates
    
    func viewAppearanceChangedTopBar(asGrid: Bool) {
        viewAppearanceChanged(asGrid: asGrid)
    }
    
    func sortedPushedTopBar(with rule:  MoreActionsConfig.SortRullesType) {

        var sortRule: SortedRules
        switch rule {
        case .AlphaBetricAZ:
            sortRule = .lettersAZ
        case .AlphaBetricZA:
            sortRule = .lettersZA
        case .TimeNewOld:
            sortRule = .timeUp
        case .TimeOldNew:
            sortRule = .timeDown
        case .Largest:
            sortRule = .sizeAZ
        case .Smallest:
            sortRule = .sizeZA
        default:
            sortRule = .timeUp
        }
        sortedPushed(with: sortRule)
    }
    
    func filtersTopBar(cahngedTo filters: [MoreActionsConfig.MoreActionsFileType]) {
        self.filters = filters.map{ $0.convertToGeneralFilterFileType() }
//        dataSource.fetchService.controller.delegate = dataSource
//        dataSource.fetchService.performFetch(sortingRules: sortedRule,
//                                             filtes: self.filters)
//        dataSource.reloadData()
        
        stopEditing()
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
        reloadData()
    }
    
    func operationFailed(withType type: ElementTypes) {
        debugPrint("failed")
        dataSource.setSelectionState(selectionState: false)
        view.setupSelectionStyle(isSelection: false)
        reloadData()
    }
    
    func selectModeSelected() {
        view.setupSelectionStyle(isSelection: true)
        dataSource.setSelectionState(selectionState: true)
    }
    
    func selectAllModeSelected() {
        view.setupSelectionStyle(isSelection: true)
        dataSource.selectAll(isTrue: true)
    }
    
    func getFolder() -> Item? {
        return interactor.getFolder()
    }
    
    func getSortTypeString() -> String {
        return self.sortedRule.stringValue
    }
}
