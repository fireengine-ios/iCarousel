//
//  SearchViewPresenter.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class SearchViewPresenter: BasePresenter, SearchViewOutput, SearchViewInteractorOutput, BaseDataSourceForCollectionViewDelegate {
    
    weak var view: SearchViewInput!
    var interactor: SearchViewInteractorInput!
    var router: SearchViewRouterInput!
    
    var moduleOutput: SearchModuleOutput?
    
    var topBarConfig: GridListTopBarConfig?
    
    var dataSource = BaseDataSourceForCollectionView()
    var showedSpinner = false
    
    let player: MediaPlayer = factory.resolve()

    var filters: [MoreActionsConfig.MoreActionsFileType] = []
    var syncType: MoreActionsConfig.CellSyncType = MoreActionsConfig.CellSyncType.all
    
    var sortedRule: SortedRules = .timeDown
    
    let custoPopUp = CustomPopUp()
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
    func viewIsReady(collectionView: UICollectionView) {
        dataSource.setupCollectionView(collectionView: collectionView, filters: nil)
        dataSource.delegate = self
        interactor.viewIsReady()
        player.delegates.add(view as! MediaPlayerDelegate)
        dataSource.displayingType = .list
        dataSource.setPreferedCellReUseID(reUseID: CollectionViewCellsIdsConstant.baseMultiFileCell)
        dataSource.isHeaderless = true
        
        setupTopBar()
//        sortedRule = .albumlettersAZ
//        dataSource.currentSortType = sortedRule
    }
    
    deinit {
        guard let view = view as? MediaPlayerDelegate else {
            return
        }
        player.delegates.remove(view)
    }
    
    //MARK: - UnderNavBarBar/TopBar
    
    private func setupTopBar() {
        guard let unwrapedConfig = topBarConfig else {
            return
        }
        view.setupUnderNavBarBar(withConfig: unwrapedConfig)
        sortedRule = unwrapedConfig.defaultSortType.sortedRulesConveted
    }

    func searchWith(searchText: String, sortBy: SortType, sortOrder: SortOrder) {
        showedSpinner = true
        self.outputView()?.showSpiner()
//        dataSource.configurateWithData(collectionData: [[Item]]())
//        dataSource.updateDisplayngType(type: .list)
        interactor.searchItems(by: searchText, sortBy: sortBy, sortOrder: sortOrder)
    }
    
    func getSuggestion(text: String) {
        interactor.getSuggetion(text: text)
    }
    
    func successWithSuggestList(list: [SuggestionObject]) {
        view.successWithSuggestList(list: list)
    }
    
    func failedSearch() {
        showedSpinner = false
        self.outputView()?.hideSpiner()
    }
    
    func isShowedSpinner() -> Bool {
        return showedSpinner
    }
    
    func getContentWithSuccess(items: [Item]) {
        if (view == nil){
            return
        }
        asyncOperationSucces()
        
        self.showedSpinner = false
        //items.sorted(by: {$0.creationDate! > $1.creationDate!})
        dataSource.dropData()
        dataSource.appendCollectionView(items: items)
//        dataSource.configurateWithSimpleData(collectionData: files, sortingRules: sortedRule, types: filters, syncType: syncType)
        
        if (items.count == 0){
            let flag = interactor.needShowNoFileView()
            view.setCollectionViewVisibilityStatus(visibilityStatus: flag)
        }else{
            view.setCollectionViewVisibilityStatus(visibilityStatus: false)
        }
        
    }
    
    func endSearchRequestWith(text: String) {
        showedSpinner = false
        outputView()?.hideSpiner()
        view.endSearchRequestWith(text: text)
        //DBOUT
//        dataSource.fetchService.performFetch(sortingRules: .timeUp, filtes: [.name(text)])
        dataSource.reloadData()
    }
    
    // MARK: - BaseDataSourceForCollectionViewDelegate
    
    func onItemSelected(item: BaseDataSourceItem) {
        // 
    }
    
    func tapCancel() {
        moduleOutput?.cancelSearch()
    }
    
    func playerDidHide() {
        player.stop()
    }
    
    func willDismissController() {
        moduleOutput?.previewSearchResultsHide()
    }
    
    func onItemSelected(item: BaseDataSourceItem, from data:[[BaseDataSourceItem]]) {
        if item.fileType.isUnSupportedOpenType {
            if item.fileType == .audio {
                guard let array = data as? [[Item]],
                    let wrappered = item as? Item
                    else { return }
                
                let list = array.flatMap{ $0 }
                guard let startIndex = list.index(of: wrappered) else { return }
                player.play(list: list, startAt: startIndex)
                player.play()
            } else {
                router.onItemSelected(item: item, from: data)
                self.view.dismissController()
                moduleOutput?.previewSearchResultsHide()
            }
        } else {
            custoPopUp.showCustomInfoAlert(withTitle: TextConstants.warning, withText: TextConstants.theFileIsNotSupported, okButtonText: TextConstants.ok)
        }
    }
    
    func getCellSizeForList() -> CGSize {
        return CGSize(width: view.getCollectionViewWidth(), height: 65)
    }
    
    
    func getCellSizeForGreed() -> CGSize {
        if (Device.isIpad){
            return CGSize(width: 180, height: 180)
        }else{
            let w: CGFloat = (view.getCollectionViewWidth() - NumericConstants.iPhoneGreedHorizontalSpace * 3)/NumericConstants.numerCellInDocumentLineOnIphone
            return CGSize(width: w, height: w)
        }
    }
    
    
    func onLongPressInCell() {
        startEditing()
    }
    
    private func startEditing() {
        dataSource.setSelectionState(selectionState: true)
    }
    
    
    private func stopEditing() {
        dataSource.setSelectionState(selectionState: false)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.view.scrollViewDidScroll(scrollView: scrollView)
    }
    
    func onChangeSelectedItemsCount(selectedItemsCount: Int) {}
    func onMaxSelectionExeption() {}
    func onMoreActions(ofItem: Item?, sender: Any) {}
    
    func getNextItems() {
        
    }
    
    //MARK: - View output/TopBar/UnderNavBarBar Delegates
    
    func viewAppearanceChangedTopBar(asGrid: Bool) {
        viewAppearanceChanged(asGrid: asGrid)
    }
    
    func sortedPushedTopBar(with rule:  MoreActionsConfig.SortRullesType) {
//        sortedPushed(with: rule.sortedRulesConveted)
    }
    
    func filtersTopBar(cahngedTo filters: [MoreActionsConfig.MoreActionsFileType]) {
        
    }
    
    //MARK: - MoreActionsViewDelegate
    
    func viewAppearanceChanged(asGrid: Bool){
        if (asGrid){
            dataSource.updateDisplayngType(type: .greed)
        }else{
            dataSource.updateDisplayngType(type: .list)
        }
    }
    
}
