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
    
    var dataSource = BaseDataSourceForCollectionView()
    var showedSpinner = false
    
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
    
    func getContentWithSuccess(){
//        if (view == nil){
//            return
//        }
//        asyncOperationSucces()
//        
//        self.showedSpinner = false
//        dataSource.configurateWithSimpleData(collectionData: files, sortingRules: sortedRule, types: filters, syncType: syncType)
        
//        if (files.count == 0){
//            let flag = interactor.needShowNoFileView()
//            view.setCollectionViewVisibilityStatus(visibilityStatus: flag)
//        }else{
//            view.setCollectionViewVisibilityStatus(visibilityStatus: false)
//        }
        
    }
    
    func endSearchRequestWith(text: String) {
        showedSpinner = false
        outputView()?.hideSpiner()
        view.endSearchRequestWith(text: text)
        
        dataSource.fetchService.performFetch(sortingRules: .timeUp, filtes: [.name(text)])
        dataSource.reloadData()
    }
    
    // MARK: - BaseDataSourceForCollectionViewDelegate
    
    func onItemSelected(item: BaseDataSourceItem) {
        // 
    }
    
    func tapCancel() {
        moduleOutput?.cancelSearch()
    }
    
    func onItemSelected(item: BaseDataSourceItem, from data:[[BaseDataSourceItem]]) {
        if item.fileType.isUnSupportedOpenType {
            router.onItemSelected(item: item, from: data)
            self.view.dismissController()
            moduleOutput?.previewSearchResultsHide()
        } else {
            custoPopUp.showCustomInfoAlert(withTitle: TextConstants.warning, withText: TextConstants.theFileIsNotSupported, okButtonText: TextConstants.ok)
        }
    }
    
    func getCellSizeForList() -> CGSize {
        return CGSize(width: view.getCollectionViewWidth(), height: 65)
    }
    
    func getCellSizeForGreed() -> CGSize {
        if (Device.isIpad){
            return CGSize(width: 90, height: 90)
        }
        
        let w = view.getCollectionViewWidth()
        let cellW: CGFloat = (w - NumericConstants.iPhoneGreedInset * 2 - NumericConstants.iPhoneGreedHorizontalSpace * NumericConstants.numerCellInLineOnIphone)/NumericConstants.numerCellInLineOnIphone
        return CGSize(width: cellW, height: cellW)
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
}
