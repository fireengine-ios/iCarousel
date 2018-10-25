//
//  PhotoVideosFilesGreedPresenter.swift
//  Depo
//
//  Created by Aleksandr on 10/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class PhotoVideosFilesGreedPresenter: BaseFilesGreedPresenter {
    
    init(sortedRule: SortedRules = .timeDown, fieldType: FieldValue) {
        super.init()
        self.sortedRule = sortedRule
        self.dataSource = PhotoVideoDataSourceForCollectionView(sortingRules: sortedRule, fieldValue: fieldType)
        type = .Grid
        sortedType = .TimeNewOld
        
    }
    
    override func viewIsReady(collectionView: UICollectionView) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateThreeDots(_:)),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationUpdateThreeDots),
                                               object: nil)
        
        
        if let unwrapedFilters = interactor.originalFilesTypeFilter {
            filters = unwrapedFilters
        }
        dataSource.setupCollectionView(collectionView: collectionView,
                                       filters: interactor.originalFilesTypeFilter)
        dataSource.isLocalPaginationOn = true
        
        dataSource.delegate = self
        dataSource.needShowProgressInCell = needShowProgressInCells
        dataSource.needShowCustomScrollIndicator = needShowScrollIndicator
        dataSource.needShowEmptyMetaItems = needShowEmptyMetaItems
        
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
        
        reloadData()
        subscribeDataSource()
    }
    
    override func onReloadData() {
        debugLog("BaseFilesGreedPresenter onReloadData")
        
        if dataSource.isLocalPaginationOn, !dataSource.isPaginationDidEnd {
            return
        }
        //        dataSource.dropData()
        view?.setThreeDotsMenu(active: false)
        reloadData()
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
        
//        interactor.reloadItems(nil,
//                               sortBy: sortedRule.sortingRules,
//                               sortOrder: sortedRule.sortOder, newFieldValue: getFileFilter())
    }
    
    override func getFileFilter() -> FieldValue {
        for type in self.filters {
            switch type {
            case .fileType(let type):
                return type.convertedToSearchFieldValue
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

        asyncOperationFail(errorMessage: errorString)
    }
    override func getContentWithSuccessEnd() {
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
    
    override func filesAppendedAndSorted() {
        DispatchQueue.toMain {
            self.updateNoFilesView()
            self.asyncOperationSucces()
            self.updateThreeDotsButton()
        }
    }
    
    override func getContentWithSuccess(items: [WrapData]) {
        guard view != nil else {
            return
        }
        
        updateThreeDotsButton()
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            self.dataSource.appendCollectionView(items: items, pageNum: self.interactor.requestPageNum)
        }
    }
    
    override func getContentWithSuccess(array: [[BaseDataSourceItem]]) {
        guard view != nil else {
            return
        }
        debugPrint("???getContentWithSuccessEnd()")
        asyncOperationSucces()
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
