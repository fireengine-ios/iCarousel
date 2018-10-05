//
//  PhotoVideosFilesGreedPresenter.swift
//  Depo
//
//  Created by Aleksandr on 10/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class PhotoVideosFilesGreedPresenter: BaseFilesGreedPresenter {
    
    override init(sortedRule: SortedRules = .timeDown) {
        super.init()
        self.sortedRule = sortedRule
        self.dataSource = PhotoVideoDataSourceForCollectionView(sortingRules: sortedRule)
        type = .Grid
        sortedType = .TimeNewOld
        
    }
    
    override func viewIsReady(collectionView: UICollectionView) {
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
    
    override func reloadData() {
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
    
    override func getFileFilter() -> FieldValue {
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
    
    override func getContentWithFail(errorString: String?) {
        view?.stopRefresher()
        dataSource.isPaginationDidEnd = false
        dataSource.hideLoadingFooter()
        
        debugPrint("???getContentWithFail()")
        debugLog("BaseFilesGreedPresenter getContentWithFail")
        asyncOperationFail(errorMessage: errorString)
    }
    override func getContentWithSuccessEnd() {
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
    
    override func getContentWithSuccess(items: [WrapData]) {
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
    
    override func getContentWithSuccess(array: [[BaseDataSourceItem]]) {
        debugLog("BaseFilesGreedPresenter getContentWithSuccess")
        
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
    
//    override func getNextItems() {
//        compoundAllFiltersAndNextItems()
//    }
}
