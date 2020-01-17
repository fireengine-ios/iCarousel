//
//  SearchViewPresenter.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class SearchViewPresenter: BasePresenter, SearchViewOutput, SearchViewInteractorOutput, BaseDataSourceForCollectionViewDelegate, BaseFilesGreedModuleInput {

    weak var view: SearchViewInput!
    var interactor: SearchViewInteractorInput!
    var router: SearchViewRouterInput!
    
    var moduleOutput: SearchModuleOutput?
    
    var topBarConfig: GridListTopBarConfig?
    
    var dataSource = SearchDataSource()
    var showedSpinner = false
    
    lazy var player: MediaPlayer = factory.resolve()
    var tabBarActionHandler: TabBarActionHandler { return self }

    var filters: [MoreActionsConfig.MoreActionsFileType] = []
    
    var sortedRule: SortedRules = .timeDown
    
    var alertSheetModule: AlertFilesActionsSheetModuleInput?
    var alertSheetExcludeTypes = [ElementTypes]()
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    var bottomBarConfig: EditingBarConfig?    
    weak var bottomBarPresenter: BottomSelectionTabBarModuleInput?
    
    //MARK : BasePresenter
    
    func viewIsReady(collectionView: UICollectionView) {
        dataSource.setupCollectionView(collectionView: collectionView, filters: nil)
        dataSource.delegate = self
        interactor.viewIsReady()
        player.delegates.add(view as! MediaPlayerDelegate)
        dataSource.displayingType = .list
        dataSource.setPreferedCellReUseID(reUseID: CollectionViewCellsIdsConstant.baseMultiFileCell)
        dataSource.isHeaderless = true
        dataSource.canSelectionState = false
        
        setupTopBar()
        subscribeDataSource()

    }
    
    func viewWillDisappear() {
        stopEditing()
    }
       
    deinit {
        guard let view = view as? MediaPlayerDelegate else {
            return
        }
        player.delegates.remove(view)
        ItemOperationManager.default.stopUpdateView(view: dataSource)
    }
    
    func subscribeDataSource() {
        ItemOperationManager.default.startUpdateView(view: dataSource)
    }
    

    func filesAppendedAndSorted() {
        dataSource.reloadData()

    }
    
    func newFolderCreated() {} /// confirms to BaseDataSourceForCollectionViewDelegate protocol
    
    //MARK: - UnderNavBarBar/TopBar
    
    private func setupTopBar() {
        guard let unwrapedConfig = topBarConfig else {
            return
        }
        view.setupUnderNavBarBar(withConfig: unwrapedConfig)
        sortedRule = unwrapedConfig.defaultSortType.sortedRulesConveted
    }

    func searchWith(searchText: String, item: SuggestionObject?, sortBy: SortType, sortOrder: SortOrder) {
        showSpinner()
        interactor.searchItems(by: searchText, item: item, sortBy: sortBy, sortOrder: sortOrder)
    }
    
    func getSuggestion(text: String) {
        interactor.getSuggetion(text: text)
    }
    
    func successWithSuggestList(list: [SuggestionObject]) {
        view.successWithSuggestList(list: list)
    }
    
    func setRecentSearches(_ recentSearches: [SearchCategory: [SuggestionObject]]) {
        view.setRecentSearches(recentSearches)
    }
    
    func failedSearch() {
        hideSpinner()
    }
    
    func getAlbum(albumItem: AlbumItem, forItem item: Item) {
        hideSpinner()
        router.openFaceImageItemPhotos(item: item, album: albumItem)
    }
    
    func failedGetAlbum() {
        hideSpinner()
    }
    
    func isShowedSpinner() -> Bool {
        return showedSpinner
    }
    
    func getContentWithSuccess(items: [Item]) {
        if view == nil {
            return
        }
        asyncOperationSuccess()
        
        showedSpinner = false
        //items.sorted(by: {$0.creationDate! > $1.creationDate!})
        dataSource.dropData()
//        dataSource.configurateWithSimpleData(collectionData: files, sortingRules: sortedRule, types: filters, syncType: syncType)
        
        if items.isEmpty {
            let flag = interactor.needShowNoFileView()
            view.setCollectionViewVisibilityStatus(visibilityStatus: flag)
            view.setVisibleTabBar(!flag)
        } else {
            view.setCollectionViewVisibilityStatus(visibilityStatus: false)

            dataSource.appendCollectionView(items: items, pageNum: 0)//

            view.setVisibleTabBar(true)

        }
        
    }
    
    func endSearchRequestWith(text: String) {
        hideSpinner()
        view.endSearchRequestWith(text: text)
        
        dataSource.isPaginationDidEnd = true
        //DBOUT
//        dataSource.fetchService.performFetch(sortingRules: .timeUp, filtes: [.name(text)])
    }
    
    // MARK: - BaseDataSourceForCollectionViewDelegate
    
    func getParent() -> BaseDataSourceItem? {
        return getFolder()
    }
    
    func getStatus() -> ItemStatus {
        return .active
    }
    
    func onItemSelected(item: BaseDataSourceItem) {
        // 
    }
    
    func tapCancel() {
        if dataSource.isInSelectionMode() {
            stopEditing()
        } else {
            moduleOutput?.cancelSearch()
        }
    }
    
    func onClearRecentSearchesTapped() {
        interactor.clearRecentSearches()
    }
    
    func playerDidHide() {
        player.stop()
    }
    
    func willDismissController() {
        moduleOutput?.previewSearchResultsHide()
    }
    
    func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]]) {
        if item.fileType.isFaceImageType {
            openFaceImage(item: item)
        } else if item.fileType.isFaceImageAlbum || item.fileType == .photoAlbum {
            openAlbum(item: item)
        } else if item.fileType.isSupportedOpenType {
            let sameTypeFiles = getSameTypeItems(item: item, items: data)
            router.onItemSelected(selectedItem: item, sameTypeItems: sameTypeFiles)
            moduleOutput?.previewSearchResultsHide()
        } else {
            let vc = PopUpController.with(title: TextConstants.warning, message: TextConstants.theFileIsNotSupported, image: .error, buttonTitle: TextConstants.ok)
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
            cellWidth = (view.getCollectionViewWidth() - NumericConstants.iPadGreedInset * 2 - NumericConstants.iPadGreedHorizontalSpace * (NumericConstants.numerCellInDocumentLineOnIpad - 1)) / NumericConstants.numerCellInDocumentLineOnIpad
        } else {
            cellWidth = (view.getCollectionViewWidth() - NumericConstants.iPhoneGreedInset * 2 - NumericConstants.iPhoneGreedHorizontalSpace * (NumericConstants.numerCellInDocumentLineOnIphone - 1)) / NumericConstants.numerCellInDocumentLineOnIphone
        }
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func onLongPressInCell() {
        startEditing()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.view.scrollViewDidScroll(scrollView: scrollView)
    }
    
    func onChangeSelectedItemsCount(selectedItemsCount: Int) {
        setupNewBottomBarConfig()
        debugLog("SearchViewPresenter onChangeSelectedItemsCount")
        
        if (selectedItemsCount == 0) {
            debugLog("SearchViewPresenter onChangeSelectedItemsCount selectedItemsCount == 0")
            
            bottomBarPresenter?.dismiss(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationShowPlusTabBar), object: nil)
        } else {
            debugLog("SearchViewPresenter onChangeSelectedItemsCount selectedItemsCount != 0")
            
            bottomBarPresenter?.show(animated: true, onView: nil)
        }
        
        view.setNavBarRigthItem(active: canShow3DotsButton())
        view.selectedItemsCountChange(with: selectedItemsCount)
    }
    
    func setupNewBottomBarConfig() {
        guard let barConfig = interactor.bottomBarConfig,
            let array = dataSource.getSelectedItems() as? [Item] else {
                return
        }
        bottomBarPresenter?.setupTabBarWith(items: array, originalConfig: barConfig)
    }
    
    func onMaxSelectionExeption() {}
    
    func onMoreActions(ofItem: Item?, sender: Any) {
        guard let item = ofItem else {
            return
        }
        debugLog("SearchViewPresenter onMoreActions")
        
        dataSource.moreActionItem = item
        
        alertSheetModule?.showSpecifiedAlertSheet(with: item,
                                                  presentedBy: sender,
                                                  onSourceView: nil,
                                                  viewController: nil)
    }
    
    func getNextItems() { }
    
    func didChangeSelection(state: Bool) {
        view.onSetSelection(state: state)
    }
    
    private func createStory() {
        let items: [BaseDataSourceItem]
        if dataSource.isInSelectionMode() {
            items = dataSource.selectedItemsArray.flatMap { $0 }.filter { $0.fileType == .image }
        } else {
            items = dataSource.allItems.flatMap { $0 }.filter { $0.fileType == .image }
        }
        
        if items.isEmpty {
            router.showNoFilesToCreateStoryAlert()
        } else {
            router.createStoryWithItems(items)
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
            
            if let deleteOriginalIndex = actionTypes.index(of: .deleteDeviceOriginal) {
                let serverObjects = selectedItems.filter({ !$0.isLocalItem })
                if serverObjects.isEmpty {
                    actionTypes.remove(at: deleteOriginalIndex)
                } else if selectedItems is [Item] {
                    
                    MediaItemOperationsService.shared.getLocalDuplicates(remoteItems: selectedItems as! [Item], duplicatesCallBack: { [weak self] items in
                        let localDuplicates = items
                        if localDuplicates.count == 0 {
                            //selectedItems = localDuplicates
                            actionTypes.remove(at: deleteOriginalIndex)
                        }
                        self?.semaphore.signal()
                    })
                    semaphore.wait()
                }
                
            }
            
            alertSheetModule?.showAlertSheet(with: actionTypes,
                                             items: selectedItems,
                                             presentedBy: sender,
                                             onSourceView: nil,
                                             excludeTypes: alertSheetExcludeTypes)
        } else {
            actionTypes = (interactor.alerSheetMoreActionsConfig?.initialTypes ?? [])
            if dataSource.allMediaItems.count == 0, let downloadIdex = actionTypes.index(of: .download) {
                actionTypes.remove(at: downloadIdex)
            }
            alertSheetModule?.showAlertSheet(with: actionTypes,
                                             presentedBy: sender,
                                             onSourceView: nil)
        }
    }
    
    func openFaceImageItems(category: SearchCategory) {
        router.openFaceImageItems(category: category)
    }
    
    func openFaceImage(item: SuggestionObject) {
        showSpinner()
        interactor.openFaceImageForSuggest(item: item)
    }
    
    func openFaceImage(item: BaseDataSourceItem) {
        showSpinner()
        interactor.openFaceImageForSearch(item: item)
    }
    
    func openAlbum(item: BaseDataSourceItem) {
        let album = AlbumItem(uuid: item.uuid,
                              name: item.name,
                              creationDate: item.creationDate,
                              lastModifiDate: item.lastModifiDate,
                              fileType: item.fileType,
                              syncStatus: item.syncStatus,
                              isLocalItem: item.isLocalItem)
        router.openAlbum(item: album)
    }
    
    // MARK: - Spinner
    
    private func showSpinner() {
        showedSpinner = true
        view.showSpiner()
    }
    
    private func hideSpinner() {
        showedSpinner = false
        view.hideSpiner()
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
        view.setNavBarRigthItem(active: false)
        dataSource.setSelectionState(selectionState: true)
    }
    
    
    private func stopEditing() {
        bottomBarPresenter?.dismiss(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationShowPlusTabBar), object: nil)
        dataSource.setSelectionState(selectionState: false)
        view.setNavBarRigthItem(active: true)
    }
    
    
    // MARK: - View output/TopBar/UnderNavBarBar Delegates
    
    func viewAppearanceChangedTopBar(asGrid: Bool) {
        viewAppearanceChanged(asGrid: asGrid)
    }
    
    func sortedPushedTopBar(with rule: MoreActionsConfig.SortRullesType) {
//        sortedPushed(with: rule.sortedRulesConveted)
    }
    
    func filtersTopBar(cahngedTo filters: [MoreActionsConfig.MoreActionsFileType]) {
        
    }
    
    // MARK: - MoreActionsViewDelegate
    
    func viewAppearanceChanged(asGrid: Bool) {
        if (asGrid) {
            dataSource.updateDisplayngType(type: .greed)
        } else {
            dataSource.updateDisplayngType(type: .list)
        }
    }
    
    // MARK: - BaseFilesGreedModuleInput
    
    func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems) {
        selectedItemsCallback(dataSource.getSelectedItems())
    }
    
    func operationFinished(withType type: ElementTypes, response: Any?) {
        debugLog("SearchViewPresenter operationFinished")
        debugPrint("finished")
        dataSource.setSelectionState(selectionState: false)
    }
    
    func operationFailed(withType type: ElementTypes) {
        debugLog("SearchViewPresenter operationFailed")
        debugPrint("failed")
        dataSource.setSelectionState(selectionState: false)
    }
    
    func selectModeSelected() {
        debugLog("SearchViewPresenter selectModeSelected")
        
        startEditing()
    }
    
    func printSelected() { }
    func moveBack() { }
    func selectAllModeSelected() { }
    func deSelectAll() { }
    
    func stopModeSelected() {
        stopEditing()
    }
    
    func changeCover() { }
    
    func deleteFromFaceImageAlbum(items: [BaseDataSourceItem]) { }
    func openInstaPick() { }
    
    func didDelete(items: [BaseDataSourceItem]) {
        if dataSource.allObjectIsEmpty() {
            view.setCollectionViewVisibilityStatus(visibilityStatus: true)
        }
    }
}

extension SearchViewPresenter: TabBarActionHandler {
    
    func canHandleTabBarAction(_ action: TabBarViewController.Action) -> Bool {
        return action == .createStory
    }
    
    func handleAction(_ action: TabBarViewController.Action) {
        switch action {
        case .createStory:
            createStory()
        default:
            break
        }
    }
}
