//
//  BaseGridDataSourceForCollectionView.swift
//  Depo
//
//  Created by Oleg on 29.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import SDWebImage

enum BaseDataSourceDisplayingType{
    case greed
    case list
}

protocol BaseDataSourceForCollectionViewDelegate: class {
    
    func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]])
    
    func getCellSizeForGreed() -> CGSize
    
    func getCellSizeForList() -> CGSize
    
    func getFolder() -> Item?
    
    func onLongPressInCell()
    
    func onChangeSelectedItemsCount(selectedItemsCount: Int)
    
    func onMaxSelectionExeption()
    
    func onMoreActions(ofItem: Item?, sender: Any)
    
    func getNextItems()
    
    func filesAppendedAndSorted()
    
    func needReloadData()
    
    func didChangeSelection(state: Bool)
    
    func updateCoverPhotoIfNeeded()
    
    func didDelete(items: [BaseDataSourceItem])
    
    func onItemSelectedActiveState(item: BaseDataSourceItem)
    
    func didChangeTopHeader(text: String)
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
}

extension BaseDataSourceForCollectionViewDelegate {
    
    func getFolder() -> Item? { return nil }
    
    func onLongPressInCell() { }
    
    func needReloadData() { }
    
    func didChangeSelection(state: Bool) { }
    
    func updateCoverPhotoIfNeeded() { }
    
    func didDelete(items: [BaseDataSourceItem]) { }
    
    func didChangeTopHeader(text: String) { }
    
    func scrollViewDidScroll(scrollView: UIScrollView) { }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) { }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) { }
}

typealias PageItemsCallBack = ([WrapData])->Void

class BaseDataSourceForCollectionView: NSObject, LBCellsDelegate, BasicCollectionMultiFileCellActionDelegate, UIScrollViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ItemOperationManagerViewProtocol {
    
    var isPaginationDidEnd = false
    
    internal weak var collectionView: UICollectionView?
    
    var displayingType: BaseDataSourceDisplayingType = .greed
    
    weak var delegate: BaseDataSourceForCollectionViewDelegate?
    
    internal var preferedCellReUseID: String?
    
    var canSelectionState = true
    
    var isSelectionStateActive = false
    
    var selectedItemsArray = Set<BaseDataSourceItem>()
    
    private var headers = Set([CollectionViewSimpleHeaderWithText]())
    
    var enableSelectionOnHeader = false
    
    var maxSelectionCount: Int = -1
    
    var canReselect: Bool = false
    
    var currentSortType: SortedRules = .timeUp

    var originalFilters: [GeneralFilesFiltrationType]?
    
    var isHeaderless = false
    
    private var isLocalPaginationOn = false // ---------------------=======
    private var isLocalFilesRequested = false // -----------------------=========
    private var isDropedData = true
    
    var allMediaItems = [WrapData]()
    var allItems = [[WrapData]]()
    private var recentlyDeletedIndexes = [IndexPath]()
    private var pageLeftOvers = [WrapData]()
    private var emptyMetaItems = [WrapData]()
    
    private var allRemoteItems = [WrapData]()
    private var uploadedObjectID = [String]()
    private var uploadToAlbumItems = [String]()
    
    var needShowProgressInCell = false
    var needShowCloudIcon = true
    var needShow3DotsInCell = true
    var canShow3DotsInCell = true
    var needShowCustomScrollIndicator = false
    var needShowEmptyMetaItems = false
    var needReloadData = true
    
    var parentUUID: String?
    
    let filesDataSource = FilesDataSource()
    
    fileprivate var previousPreheatRect = CGRect.zero
    
    private var sortingRules: SortedRules
    
    private let pageCompounder = PageCompounder()
    
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.baseFilesGreedCollectionDataSource)
    
    private var currentTopSection: Int?
    
    private var lastPage: Int = 0
    
    init(sortingRules: SortedRules = .timeUp) {
        self.sortingRules = sortingRules
        super.init()
    }
    
    func appendCollectionView(items: [WrapData], pageNum: Int) {
        let containsEmptyMetaItems = !emptyMetaItems.isEmpty
        var tempoEmptyItems = [WrapData]()
        var filteredItems = [WrapData]()

        if needShowEmptyMetaItems {
            if let unwrapedFilters = self.originalFilters,
                !showOnlyRemotes(filters: unwrapedFilters) {
                
                items.forEach {
                    if !$0.isLocalItem, $0.metaData?.takenDate != nil {
                        filteredItems.append($0)
                    } else {
                        tempoEmptyItems.append($0)
                    }
                }
                emptyMetaItems.append(contentsOf: tempoEmptyItems)
                pageCompounder.appendNotAllowedItems(items: emptyMetaItems)
            } else {
                filteredItems = items
            }
        } else {
            filteredItems = items.filter {
                if $0.fileType == .image, !$0.isLocalItem {
                    return ($0.metaData?.takenDate != nil)
                }
                return $0.metaData != nil
            }
        }
        
        if tempoEmptyItems.count >= pageCompounder.pageSize {
//            delegate?.getNextItems()
//            DISPATCH QUEUE???
            self.breakItemsIntoSections(breakingArray: self.allMediaItems)
            var oldSectionNumbers = 1
            if let collectionView = collectionView {
                oldSectionNumbers = numberOfSections(in: collectionView)
            }
            self.insertItems(with: ResponseResult.success(self.getIndexPathsForItems([])), emptyItems: tempoEmptyItems, oldSectionNumbers: oldSectionNumbers, containsEmptyMetaItems: containsEmptyMetaItems)
            return
        }
        
        if filteredItems.isEmpty, tempoEmptyItems.isEmpty {
            isPaginationDidEnd = true
        }
        lastPage = pageNum
        log.debug("BaseDataSourceForCollectionView appendCollectionView \(filteredItems.count)")
        
        allRemoteItems.append(contentsOf: filteredItems)
  
        var oldSectionNumbers = 1
        if let collectionView = collectionView {
            oldSectionNumbers = numberOfSections(in: collectionView)
        }
        
        compoundItems(pageItems: filteredItems, pageNum: pageNum, originalRemotes: true, complition: { [weak self] response in
            self?.insertItems(with: response, emptyItems: tempoEmptyItems, oldSectionNumbers: oldSectionNumbers, containsEmptyMetaItems: containsEmptyMetaItems)
        })
    }
    
    func reloadLastSection() {
        DispatchQueue.main.async {
            let lastSection = (self.collectionView?.numberOfSections ?? 0) - 1
            self.collectionView?.reloadSections(IndexSet(integersIn: lastSection...lastSection))
        }
    }
    
    private func insertItems(with response: ResponseResult<[IndexPath]>, emptyItems: [Item], oldSectionNumbers: Int, containsEmptyMetaItems: Bool) {
        guard let collectionView = collectionView else {
            return
        }
        
        switch response {
        case .success(let array):
            if self.isDropedData || array.isEmpty {
                DispatchQueue.main.async {
                    if self.needReloadData {
                        self.collectionView?.reloadData()
                    }
                }
                self.isLocalFilesRequested = false
                self.delegate?.filesAppendedAndSorted()
                self.isDropedData = false
            } else {
                let newSectionNumbers = self.numberOfSections(in: collectionView)
                let emptyItemsArray = getIndexPathsForItems(emptyItems)
                var newSections: IndexSet?
                if newSectionNumbers > oldSectionNumbers {
                    let needMoveSectionWithEmptyMetaItems = self.needShowEmptyMetaItems && self.currentSortType == .metaDataTimeUp && containsEmptyMetaItems
                    
                    if needMoveSectionWithEmptyMetaItems {
                        newSections = IndexSet(oldSectionNumbers-1..<newSectionNumbers-1)                           
                    } else {
                        newSections = IndexSet(oldSectionNumbers..<newSectionNumbers)
                    }
                }
                DispatchQueue.main.async {
                    collectionView.collectionViewLayout.invalidateLayout()
                    collectionView.performBatchUpdates({ [weak self] in
                        guard let `self` = self else {
                            return
                        }
                        if let newSections = newSections {
                            self.collectionView?.insertSections(newSections)
                        }
                        if !self.recentlyDeletedIndexes.isEmpty {///Also should add check for deleted sections
                            self.collectionView?.deleteItems(at: self.recentlyDeletedIndexes)
                            self.recentlyDeletedIndexes.removeAll()
                        }
                        self.collectionView?.insertItems(at: array + emptyItemsArray)
                        
                        }, completion: { [weak self] _ in
                            guard let `self` = self else {
                                return
                            }
                            self.isLocalFilesRequested = false
                            self.delegate?.filesAppendedAndSorted()
                            //FIXME: part of appending+ incerting should be rewitten or trigger for new page
                            self.dispatchQueue.async { [weak self] in
                                guard let `self` = self else {
                                    return
                                }
                                if !self.isPaginationDidEnd,
                                    self.isLocalPaginationOn,
                                    !self.isLocalFilesRequested,
                                    array.count < self.pageCompounder.pageSize {
                                    debugPrint("!!! TRY TO GET NEW PAGE")
                                    self.delegate?.getNextItems()
                                }
//                                    insertItems
                            }
                    })
                }
                    
                
            }
        case .failed(_):
            delegate?.filesAppendedAndSorted()
            isLocalFilesRequested = false
        }
    }

    private func canShowFolderFilters(filters: [GeneralFilesFiltrationType]) -> Bool {
        for filter in filters {
            switch filter {
            case   .fileType(.folder):
                return true
            case .rootFolder(_):
                return true
            case .parentless:
                return true
            default:
                break
            }
        }
        return false
    }
    
    func canShowAlbumsFilters(filters: [GeneralFilesFiltrationType]) -> Bool {
        for filter in filters {
            switch filter {
            case   .fileType(.photoAlbum):
                return true
            default:
                break
            }
        }
        return false
    }
    
    func canUploadFromLifeBox(filters: [GeneralFilesFiltrationType]) -> Bool {
        for filter in filters {
            switch filter {
            case .fileType(.photoAlbum):
                return true
            case .fileType(.folder):
                return true
            default:
                break
            }
        }
        return false
    }
    
    private func isFavoritesOnly(filters: [GeneralFilesFiltrationType]) -> Bool{
        for filter in filters {
            switch filter {
            case   .favoriteStatus(.favorites):
                return true
            default:
                break
            }
        }
        return false
    }
    
    private func isAlbumDetail(filters: [GeneralFilesFiltrationType]) -> Bool{
        for filter in filters {
            switch filter {
            case   .rootAlbum(_):
                return true
            default:
                break
            }
        }
        return false
    }
    
    fileprivate func compoundItems(pageItems: [WrapData], pageNum: Int, originalRemotes: Bool = false, complition: @escaping ResponseArrayHandler<IndexPath>) {
        
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                complition(ResponseResult.success([]))
                return
            }
            
            guard let unwrapedFilters = self.originalFilters,
                let specificFilters = self.getFileFilterType(filters: unwrapedFilters),
                !self.showOnlyRemotes(filters: unwrapedFilters) else {
                    self.allMediaItems.append(contentsOf: pageItems)
                    self.isLocalPaginationOn = false
                    self.isHeaderless ? self.setupOneSectionMediaItemsArray(items: self.allMediaItems) : self.breakItemsIntoSections(breakingArray: self.allMediaItems)
                    
                    complition(ResponseResult.success(self.getIndexPathsForItems(pageItems)))
                    return
            }
            
            switch specificFilters {
            case .video, .image:
                guard !self.isLocalFilesRequested else {
                    return
                }
                
                let pageTempoItems = self.pageLeftOvers + pageItems
                
                self.isLocalFilesRequested = true
                self.isLocalPaginationOn = true
                
                if pageNum == 1 {
                    if self.isPaginationDidEnd, !pageTempoItems.isEmpty  {
                        /**in case when there are less then a 100 remotes on BE,
                         and
                         a lot of locals with deferent range of dates*/
                        self.compoundItems(pageItems: pageItems, pageNum: 2, complition: complition)
                        return
                    }
                    self.pageCompounder.compoundFirstPage(pageItems: pageTempoItems,
                                                          filesType: specificFilters,
                                                          sortType: self.currentSortType,
                                                          compoundedCallback:
                        { [weak self] (compoundedItems, lefovers) in
                            guard let `self` = self else {
                                return
                            }
                            self.pageLeftOvers.removeAll()
                            self.pageLeftOvers.append(contentsOf: lefovers)
                            self.allMediaItems.append(contentsOf: compoundedItems)
                            self.isHeaderless ? self.setupOneSectionMediaItemsArray(items: self.allMediaItems) : self.breakItemsIntoSections(breakingArray: self.allMediaItems)
                            
                             complition(ResponseResult.success(self.getIndexPathsForItems(compoundedItems)))
//                            if !self.isPaginationDidEnd,
//                                compoundedItems.count < self.pageCompounder.pageSize {
//                                self.delegate?.getNextItems()
//                            }
                            
                    })
                } else if self.isPaginationDidEnd {
                    let isEmptyLeftOvers = self.pageLeftOvers.filter{!$0.isLocalItem}.isEmpty
                    var itemsToCompound = isEmptyLeftOvers ? pageTempoItems : self.transformedLeftOvers()
                    var needToDropFirstItem = false
                    if pageTempoItems.isEmpty, isEmptyLeftOvers, let lastMediItem = self.allMediaItems.last {
                        itemsToCompound.append(lastMediItem)
                        needToDropFirstItem = true
                        //                        self.delegate?.getNextItems()
                        //                        //DO I need callback here?
                        //                        return
                    }
                    
                    self.pageCompounder.compoundLastPage(pageItems: itemsToCompound,
                                                         filesType: specificFilters,
                                                         sortType: self.currentSortType,
                                                         dropFirst: needToDropFirstItem,
                                                         compoundedCallback:
                        { [weak self] (compoundedItems, lefovers) in
                            guard let `self` = self else {
                                return
                            }
                            
                            self.pageLeftOvers.removeAll()
                            self.pageLeftOvers.append(contentsOf: lefovers)
                            
                            self.allMediaItems.append(contentsOf: compoundedItems)
                            
                            if compoundedItems.isEmpty,
                                self.isPaginationDidEnd {
                                self.isLocalPaginationOn = false
                            }
                            
                            self.isHeaderless ? self.setupOneSectionMediaItemsArray(items: self.allMediaItems) : self.breakItemsIntoSections(breakingArray: self.allMediaItems)
                            complition(ResponseResult.success(self.getIndexPathsForItems(compoundedItems)))
//                            if !self.isPaginationDidEnd,
//                                compoundedItems.count < self.pageCompounder.pageSize {
//                                self.delegate?.getNextItems()
//                            }
                    })
                } else if !self.isPaginationDidEnd { ///Middle page
                    //check lefovers here
                    let isEmptyLeftOvers = self.pageLeftOvers.isEmpty
                    ///.filter{!$0.isLocalItem}.isEmpty in case for only remotes
                    let itemsToCompound = isEmptyLeftOvers ? pageTempoItems : self.pageLeftOvers
                    ///self.transformedLeftOvers() in case for only remotes
                    if pageTempoItems.isEmpty, itemsToCompound.isEmpty//self.transformedLeftOvers().isEmpty
                        /**isEmptyLeftOvers*/ {
                        self.isLocalFilesRequested = false
                        self.delegate?.getNextItems()
                        //DO I need callback here?
                        return
                    }
                    
                    self.pageCompounder.compoundMiddlePage(pageItems: itemsToCompound,
                                                           filesType: specificFilters,
                                                           sortType: self.currentSortType,
                        compoundedCallback:
                        { [weak self] (compoundedItems, lefovers) in
                            guard let `self` = self else {
                                return
                            }
                            self.pageLeftOvers.removeAll()
                            self.pageLeftOvers.append(contentsOf: lefovers)

                            self.allMediaItems.append(contentsOf: compoundedItems)

                            self.isHeaderless ? self.setupOneSectionMediaItemsArray(items: self.allMediaItems) : self.breakItemsIntoSections(breakingArray: self.allMediaItems)
                            complition(ResponseResult.success(self.getIndexPathsForItems(compoundedItems)))
                            ////// maybe change index
//                            if !self.isPaginationDidEnd,
//                                compoundedItems.count < self.pageCompounder.pageSize {
//                                self.delegate?.getNextItems()
//                            }
                    })
                }
                
            default:
                self.allMediaItems.append(contentsOf: pageItems)
                self.isHeaderless ? self.setupOneSectionMediaItemsArray(items: self.allMediaItems) : self.breakItemsIntoSections(breakingArray: self.allMediaItems)
                complition(ResponseResult.success(self.getIndexPathsForItems(pageItems)))
            }
            
        }
    }
    
    private func getIndexPathsForItems(_ items: [Item]) -> [IndexPath] {
        return items.flatMap { self.getIndexPathForObject(itemUUID: $0.uuid) }
    }
    
    private func transformedLeftOvers() -> [WrapData] {
        let pseudoPageArray = pageLeftOvers.filter{!$0.isLocalItem}
        return pseudoPageArray
    }
    
    func setupOneSectionMediaItemsArray(items: [WrapData]) {
        allItems.removeAll()
        allItems.append(items)
    }
    
    private func isLocalOnly() -> Bool {
        guard let unwrapedFilters = originalFilters else {
            return false
        }
        for filter in unwrapedFilters {
            switch filter {
            case .localStatus(.local):
                return true
            default:
                break
            }
        }
        return false
    }
    
    private func breakItemsIntoSections(breakingArray: [WrapData]) {
        allItems.removeAll()
        
        let needShowEmptyMetaDataItems = needShowEmptyMetaItems && (currentSortType == .metaDataTimeUp || currentSortType == .metaDataTimeDown)
        
        for item in breakingArray {
            autoreleasepool {
                if !allItems.isEmpty,
                    let lastItem = allItems.last?.last {
                    switch currentSortType {
                    case .timeUp, .timeDown:
                        addByDate(lastItem: lastItem, newItem: item, isMetaDate: false)
                    case .lettersAZ, .lettersZA, .albumlettersAZ, .albumlettersZA:
                        addByName(lastItem: lastItem, newItem: item)
                    case .sizeAZ, .sizeZA:
                        addBySize(lastItem: lastItem, newItem: item)
                    case .timeUpWithoutSection, .timeDownWithoutSection:
                        allItems.append(contentsOf: [breakingArray])
                        return
                    case .metaDataTimeUp, .metaDataTimeDown:
                        addByDate(lastItem: lastItem, newItem: item, isMetaDate: true)
                    }
                } else {
                    allItems.append([item])
                }
            }
        }
        
        if needShowEmptyMetaDataItems && !emptyMetaItems.isEmpty {
            if currentSortType == .metaDataTimeUp {
                allItems.append(emptyMetaItems)
            } else if currentSortType == .metaDataTimeDown {
                allItems.insert(emptyMetaItems, at: 0)
            }
        }
    }
    
    private func getFileFilterType(filters: [GeneralFilesFiltrationType]) -> FileType? {
        for filter in filters {
            switch filter {
            case  .fileType(.image):
                return .image
            case .fileType(.video):
                return .video
            default:
                break
            }
        }
        return nil
    }
    
    private func showOnlyRemotes(filters: [GeneralFilesFiltrationType]) -> Bool {
        for filter in filters {
            switch filter {
            case .localStatus(.nonLocal):
                return true
            default:
                break
            }
        }
        return false
    }
    
    private func getLastNonMetaEmptyItem(items: [WrapData]) -> WrapData? {
        for item in items.reversed() {
            if item.metaData?.takenDate != nil {
                return item
            }
        }
        return items.last
    }
    
    private func addByDate(lastItem: WrapData, newItem: WrapData, isMetaDate: Bool) {
        let lastItemCreatedDate =  isMetaDate ? lastItem.metaDate : lastItem.creationDate!
        let newItemCreationDate = isMetaDate ? newItem.metaDate : newItem.creationDate!
        
        if lastItemCreatedDate.getYear() == newItemCreationDate.getYear(),
            lastItemCreatedDate.getMonth() == newItemCreationDate.getMonth(),
            !allItems.isEmpty{
            
            allItems[allItems.count - 1].append(newItem)
            
        } else {
            allItems.append([newItem])
        }
    }
    
    private func addByName(lastItem: WrapData, newItem: WrapData) {
        if let lastItemNameChar = lastItem.name?.first,
            let newItemNameChar = newItem.name?.first {
            
            if String(lastItemNameChar).uppercased() == String(newItemNameChar).uppercased() {
                allItems[allItems.count - 1].append(newItem)
            } else {
                allItems.append([newItem])
            }
            
        } else {
            allItems.append([newItem])
        }
    }
    
    private func addBySize(lastItem: WrapData, newItem: WrapData) {
        allItems[allItems.count-1].append(newItem)
    }
    
    private func getHeaderText(indexPath: IndexPath) -> String {
        var headerText = ""
        
        guard let item = allItems[safe: indexPath.section]?.first else {
            return headerText
        }
        
        switch currentSortType {
        case .timeUp, .timeUpWithoutSection, .timeDown, .timeDownWithoutSection:
            if let date = item.creationDate {
                headerText = date.getDateInTextForCollectionViewHeader()
            }
        case .lettersAZ, .albumlettersAZ, .lettersZA, .albumlettersZA:
            if let character = item.name?.first {
                headerText = String(describing: character).uppercased()
            }
        case .sizeAZ, .sizeZA:
            headerText = ""
        case .metaDataTimeUp, .metaDataTimeDown:
            if let date = item.metaData?.takenDate {
                headerText = date.getDateInTextForCollectionViewHeader()
            } else if needShowEmptyMetaItems && !emptyMetaItems.isEmpty && item.isLocalItem == false {
                headerText = TextConstants.photosVideosViewMissingDatesHeaderText
            } else if let date = item.creationDate {
                headerText = date.getDateInTextForCollectionViewHeader()
            }
        }
        return headerText
    }
    
    private func facingPageEnd() {
        
    }
    
    func dropData() {
        log.debug("BaseDataSourceForCollectionViewDelegate dropData()")
        
        emptyMetaItems.removeAll()
        allRemoteItems.removeAll()
        allItems.removeAll()
        pageLeftOvers.removeAll()
        allMediaItems.removeAll()
        pageCompounder.dropData()
        isLocalFilesRequested = false
        isDropedData = true
    }
    
    func setupCollectionView(collectionView: UICollectionView, filters: [GeneralFilesFiltrationType]? = nil){
        
        originalFilters = filters
        
        self.collectionView = collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        
        registerHeaders()
        registerFooters()
        registerCells()
    }
    
    private func registerCells() {
        let registreList = [CollectionViewCellsIdsConstant.cellForImage,
                            CollectionViewCellsIdsConstant.cellForStoryImage,
                            CollectionViewCellsIdsConstant.cellForVideo,
                            CollectionViewCellsIdsConstant.cellForAudio,
                            CollectionViewCellsIdsConstant.audioSelectionCell,
                            CollectionViewCellsIdsConstant.baseMultiFileCell,
                            CollectionViewCellsIdsConstant.photosOrderCell,
                            CollectionViewCellsIdsConstant.folderSelectionCell,
                            CollectionViewCellsIdsConstant.albumCell,
                            CollectionViewCellsIdsConstant.localAlbumCell,
                            CollectionViewCellsIdsConstant.cellForFaceImage,
                            CollectionViewCellsIdsConstant.cellForFaceImageAddName]
        
        registreList.forEach {
            let listNib = UINib(nibName: $0, bundle: nil)
            collectionView?.register(listNib, forCellWithReuseIdentifier: $0)
        }
        
    }
    
    private func registerHeaders() {
        let headerNib = UINib(nibName: CollectionViewSuplementaryConstants.baseDataSourceForCollectionViewReuseID,
                              bundle: nil)
        collectionView?.register(headerNib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: CollectionViewSuplementaryConstants.baseDataSourceForCollectionViewReuseID)
        
    }
    
    private func registerFooters() {
        let headerNib = UINib(nibName: CollectionViewSuplementaryConstants.collectionViewSpinnerFooter,
                              bundle: nil)
        collectionView?.register(headerNib,
                                 forSupplementaryViewOfKind: UICollectionElementKindSectionFooter  ,
                                 withReuseIdentifier: CollectionViewSuplementaryConstants.collectionViewSpinnerFooter)
    }
    
    func setPreferedCellReUseID(reUseID: String?){
        preferedCellReUseID = reUseID
    }
    
    func setSelectionState(selectionState: Bool){        
        if (isSelectionStateActive == selectionState){
            return
        }
        if selectionState {
            needShow3DotsInCell = false
        } else {
            needShow3DotsInCell = canShow3DotsInCell
            selectedItemsArray.removeAll()
        }
        
        isSelectionStateActive = selectionState
        let array = collectionView?.visibleCells ?? [UICollectionViewCell]()
        for cell in array {
            guard let cell_ = cell as? CollectionViewCellDataProtocol else{
                continue
            }
            
            let indexPath = collectionView?.indexPath(for: cell)
            guard let indexPath_ = indexPath else {
                continue
            }
           
            let object = itemForIndexPath(indexPath: indexPath_)
            guard let unwrapedObject = object else {
                return
            }
            cell_.setSelection(isSelectionActive: isSelectionStateActive, isSelected: isObjctSelected(object: unwrapedObject))
            cell_.confireWithWrapperd(wrappedObj: unwrapedObject)
            
            if let cell = cell as? BasicCollectionMultiFileCell {
                cell.moreButton.isHidden = !needShow3DotsInCell
            }
        }
        
        for header in headers{
            header.setSelectedState(selected: isHeaderSelected(section: header.selectionView.tag), activateSelectionState: isSelectionStateActive && enableSelectionOnHeader)
        }
        
        delegate?.didChangeSelection(state: isSelectionStateActive)
    }
    
    func getAllObjects() -> [[BaseDataSourceItem]] {
        return allItems
    }
    
    func allObjectIsEmpty() -> Bool {
        var result = true
        getAllObjects().forEach { items in
            if !items.isEmpty {
                result = false
                return
            }
        }
        return result
    }
    
    func setAllItems(items: [[BaseDataSourceItem]]) {
        allItems = items as! [[WrapData]]
    }
    
    func selectAll(isTrue: Bool){
        if (isTrue) {
            selectedItemsArray.removeAll()
            let parsedItems: [BaseDataSourceItem] = allItems.flatMap{ $0 }
            selectedItemsArray.formUnion(parsedItems) //<BaseDataSourceItem>(parsedItems)
            updateVisibleCells()
            for header in headers{
                header.setSelectedState(selected: isHeaderSelected(section: header.selectionView.tag),
                                        activateSelectionState: isSelectionStateActive && enableSelectionOnHeader)
            }
        }else{
            selectedItemsArray.removeAll()
            updateVisibleCells()
            for header in headers{
                header.setSelectedState(selected: isHeaderSelected(section: header.selectionView.tag),
                                        activateSelectionState: isSelectionStateActive && enableSelectionOnHeader)
            }
        }
        updateSelectionCount()
    }
    
    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            
            guard let `self` = self, let collectionView = self.collectionView else {
                return
            }
            
            log.debug("BaseDataSourceForCollectionViewDelegate reloadData")
            debugPrint("BaseDataSourceForCollectionViewDelegate reloadData")
            
            collectionView.reloadData()
            
            if self.numberOfSections(in: collectionView) == 0 {
                self.updateVisibleCells()
                self.resetCachedAssets()
                return
            }
            
            collectionView.performBatchUpdates(nil, completion: { [weak self] _ in
                self?.updateVisibleCells()
            })
            self.resetCachedAssets()
        }
    }
    
    func updateDisplayngType(type: BaseDataSourceDisplayingType) {
        displayingType = type
        
        debugPrint("Reload updateDisplayngType")
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            let firstVisibleIndexPath = self.self.collectionView?.indexPathsForVisibleItems.min(by: { first, second -> Bool in
                return first < second
            })

            if let firstVisibleIndexPath = firstVisibleIndexPath {
                if firstVisibleIndexPath.row == 0, firstVisibleIndexPath.section == 0 {
                    self.collectionView?.scrollToItem(at: firstVisibleIndexPath, at: .centeredVertically, animated: false)
                } else{
                    self.collectionView?.scrollToItem(at: firstVisibleIndexPath, at: .top, animated: false)
                }
            }
        }
    }
    
    func getSelectedItems() -> [BaseDataSourceItem] {
        return Array(selectedItemsArray)
    }
    
    
    //MARK: LBCellsDelegate
    
    func canLongPress() -> Bool {
        return canSelectionState
    }
    
    func onLongPress(cell: UICollectionViewCell) {
        if maxSelectionCount == selectedItemsArray.count {
            if let cell = cell as? CollectionViewCellForStoryPhoto  {
                cell.setSelection(isSelectionActive: false, isSelected: false)
            }
        }
        
        if  let forwardDelegate = self.delegate,
            let path = collectionView?.indexPath(for: cell),
            let object = itemForIndexPath(indexPath: path) {
            
            if !isObjctSelected(object: object) {
                onSelectObject(object: object)
            }
            
            if !isSelectionStateActive {
                forwardDelegate.onLongPressInCell()
            }
        }
    }
    
    //MARK: selection
    
    func updateSelectionCount() {
        self.delegate?.onChangeSelectedItemsCount(selectedItemsCount: selectedItemsArray.count)
    }
    
    func isObjctSelected(object: BaseDataSourceItem) -> Bool {
        return selectedItemsArray.contains(object)
    }
    
    func onSelectObject(object: BaseDataSourceItem) {
        if (isObjctSelected(object: object)) {
            selectedItemsArray.remove(object)
        } else {
            if (maxSelectionCount >= 0){
                if (selectedItemsArray.count >= maxSelectionCount){
                    if (canReselect){
                        selectedItemsArray.removeFirst()
                        updateVisibleCells()
                    }else{
                        delegate?.onMaxSelectionExeption()
                        return
                    }
                }
            }
            selectedItemsArray.insert(object)
        }
        
        for header in headers{
            header.setSelectedState(selected: isHeaderSelected(section: header.selectionView.tag),
                                    activateSelectionState: isSelectionStateActive && enableSelectionOnHeader)
        }
        
        updateSelectionCount()
    }
    
    func isHeaderSelected(section: Int) -> Bool {
        guard section < allItems.count else {
            return false
        }
        let arrayOfObjectsInSection: [BaseDataSourceItem] = allItems[section]
        let subSet = Set<BaseDataSourceItem>(arrayOfObjectsInSection)
        
        return subSet.isSubset(of: selectedItemsArray)
        
    }
    
    func selectSectionAt(section: Int){
        
        let objectsArray: [BaseDataSourceItem] = allItems[section]
        
        if (isHeaderSelected(section: section)){
            for obj in objectsArray {
                selectedItemsArray.remove(obj)
            }
        }else{
            for obj in objectsArray {
                selectedItemsArray.insert(obj)
            }
        }
        
        let visibleCells = collectionView?.visibleCells ?? [UICollectionViewCell]()
        for cell in visibleCells {
            guard let cell_ = cell as? CollectionViewCellDataProtocol,
                let indexPath = collectionView?.indexPath(for: cell),
                (indexPath.section == section),
                let object = itemForIndexPath(indexPath: indexPath)
                else{
                    continue
            }
            
            cell_.setSelection(isSelectionActive: isSelectionStateActive,
                               isSelected: isObjctSelected(object: object))
            cell_.confireWithWrapperd(wrappedObj: object)
            
        }
        if isSelectionStateActive {
            delegate?.onChangeSelectedItemsCount(selectedItemsCount: self.selectedItemsArray.count)
        }
    }
    
    func updateVisibleCells(){
        let array = collectionView?.visibleCells ?? [UICollectionViewCell]()
        for cell in array {
            guard let cell_ = cell as? CollectionViewCellDataProtocol else{
                continue
            }
            
            let indexPath = collectionView?.indexPath(for: cell)
            guard let indexPath_ = indexPath else {
                continue
            }
          
            let object = itemForIndexPath(indexPath: indexPath_)
            guard let unwrapedObject = object else {
                continue
            }
            cell_.setSelection(isSelectionActive: isSelectionStateActive, isSelected: isObjctSelected(object: unwrapedObject))
            cell_.confireWithWrapperd(wrappedObj: unwrapedObject)
            
            if let cell = cell as? BasicCollectionMultiFileCell {
                cell.moreButton.isHidden = !needShow3DotsInCell
            }
        }
    }
    
    @objc func onHeaderTap(_ sender: UITapGestureRecognizer){
        if !enableSelectionOnHeader || !isSelectionStateActive {
            return
        }
        
        guard
            let section = sender.view?.tag,
            let textHeader = sender.view?.superview as? CollectionViewSimpleHeaderWithText
        else {
            return    
        }
        
        selectSectionAt(section: section)
        textHeader.setSelectedState(selected: isHeaderSelected(section: section), activateSelectionState: isSelectionStateActive)
    }
    
    func morebuttonGotPressed(sender: Any, itemModel: Item?) {
        delegate?.onMoreActions(ofItem: itemModel, sender: sender)
    }
    
    func isInSelectionMode() -> Bool {
        return isSelectionStateActive
    }
    
    //MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView: scrollView)
        
        updateCachedAssets()
        
        if needShowCustomScrollIndicator {
            let firstVisibleIndexPath = collectionView?.indexPathsForVisibleItems.min(by: { first, second -> Bool in
                return first < second
            })
            
            guard let indexPath = firstVisibleIndexPath else {
                return
            }
            
            if let currentTopSection = currentTopSection, currentTopSection == indexPath.section {
                return
            }
            
            let headerText = getHeaderText(indexPath: indexPath)
            delegate?.didChangeTopHeader(text: headerText)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    /// fixing iOS11 UICollectionSectionHeader clipping scroll indicator
    /// https://stackoverflow.com/a/46930410/5893286
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if #available(iOS 11.0, *), elementKind == UICollectionElementKindSectionHeader {
            view.layer.zPosition = 0
        }
    }
    
    //MARK: collectionViewDataSource
    
    func itemForIndexPath(indexPath: IndexPath) -> BaseDataSourceItem? {
        return allItems[safe: indexPath.section]?[safe: indexPath.row]
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return allItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < allItems.count else {
            return 0
        }
        return allItems[section].count
    }
    
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat {
        return isHeaderless ? 0 : 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let file = itemForIndexPath(indexPath: indexPath)
        
        var cellReUseID = preferedCellReUseID
        if (cellReUseID == nil), let unwrapedFile = file {
            cellReUseID = unwrapedFile.getCellReUseID()
        }

        if ((displayingType == .list) &&
            (file is Item)) {
            cellReUseID = CollectionViewCellsIdsConstant.baseMultiFileCell
        }
        
        // ---------------------=======
        if cellReUseID == nil {
            log.debug("BaseDataSourceForCollectionViewDelegate cellForItemAt cellReUseID == nil")
            cellReUseID = CollectionViewCellsIdsConstant.cellForImage// ---------------------=======
        }
        // ---------------------=======
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReUseID!,
                                                      for: indexPath)
        
        if !needShowCloudIcon {
            if let cell = cell as? CollectionViewCellForPhoto {
                cell.cloudStatusImage.isHidden = true
            }
        }

        return  cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let unwrapedObject = itemForIndexPath(indexPath: indexPath),
            let cell_ = cell as? CollectionViewCellDataProtocol else {
                return
        }
        
        cell_.updating()
        cell_.setSelection(isSelectionActive: isSelectionStateActive, isSelected: isObjctSelected(object: unwrapedObject))
        cell_.confireWithWrapperd(wrappedObj: unwrapedObject)
        cell_.setDelegateObject(delegateObject: self)
        
        guard let wraped = unwrapedObject as? Item else {
            return
        }
        
        switch wraped.patchToPreview {
        case .localMediaContent(let local):
            cell_.setAssetId(local.asset.localIdentifier)
            self.filesDataSource.getAssetThumbnail(asset: local.asset, indexPath: indexPath, completion: { (image, path) in
                DispatchQueue.main.async {
                    if cell_.getAssetId() == local.asset.localIdentifier, let image = image {
                        cell_.setImage(image: image, animated:  false)
                    } else {
                        cell_.setPlaceholderImage(fileType: wraped.fileType)
                    }
                }
            })
            
        case let .remoteUrl(url):
            if let url = url {
                cell_.setImage(with: url)
            } else {
                cell_.setPlaceholderImage(fileType: wraped.fileType)
            }
        }
        
        let countRow:Int = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        let isLastSection = Bool((numberOfSections(in: collectionView) - 1) == indexPath.section)
        let isLastCell = Bool((countRow - 1) == indexPath.row)
        
        let oldSectionNumbers = numberOfSections(in: collectionView)
        let containsEmptyMetaItems = !emptyMetaItems.isEmpty
        
        if isLastCell, isLastSection, !isPaginationDidEnd {
            if pageLeftOvers.isEmpty, !isLocalFilesRequested {
                delegate?.getNextItems()
            } else if !pageLeftOvers.isEmpty, !isLocalFilesRequested {
                debugPrint("!!! page compunding for page \(lastPage)")
                
                compoundItems(pageItems: [], pageNum: lastPage, complition: { [weak self] response in
                    self?.insertItems(with: response, emptyItems: [], oldSectionNumbers: oldSectionNumbers, containsEmptyMetaItems: containsEmptyMetaItems)
                    
                })
            }
//            else {
//                delegate?.getNextItems()
//            }
        } else if isLastCell, isLastSection, isPaginationDidEnd, isLocalPaginationOn, !isLocalFilesRequested {
            compoundItems(pageItems: [], pageNum: 2, complition: { [weak self] response in
                self?.insertItems(with: response, emptyItems: [], oldSectionNumbers: oldSectionNumbers, containsEmptyMetaItems: containsEmptyMetaItems)
            })
        }
        
        if let photoCell = cell_ as? CollectionViewCellForPhoto {
            let file = itemForIndexPath(indexPath: indexPath)
            if let `file` = file, uploadedObjectID.index(of: file.uuid) != nil {
                photoCell.finishedUploadForObject()
            }
        }
        
        if let cell = cell as? BasicCollectionMultiFileCell {
            cell.moreButton.isHidden = !needShow3DotsInCell
        }
    }
    
    func hideLoadingFooter() {
        guard let footerView =
            collectionView?.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: IndexPath(item: 0, section: allItems.count - 1)) as? CollectionViewSpinnerFooter else {
            return
        }
        
        footerView.stopSpinner()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell_ = cell as? CollectionViewCellDataProtocol else {
                return
        }
        
        if let photoCell = cell_ as? CollectionViewCellForPhoto {
            photoCell.cleanCell()
        }
        
        cell_.setSelection(isSelectionActive: isSelectionStateActive, isSelected: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let unwrapedObject = itemForIndexPath(indexPath: indexPath) else {
            return
        }
        
        if (isSelectionStateActive) {
            onSelectObject(object: unwrapedObject)
            let cell = collectionView.cellForItem(at: indexPath)
            guard let cell_ = cell as? CollectionViewCellDataProtocol else {
                return
            }
            cell_.setSelection(isSelectionActive: isSelectionStateActive, isSelected: isObjctSelected(object: unwrapedObject))
            if  let forwardDelegate = self.delegate {
                forwardDelegate.onItemSelectedActiveState(item: unwrapedObject)
            }
        } else {
            if  let forwardDelegate = self.delegate {
                let array = getAllObjects()
                forwardDelegate.onItemSelected(item: unwrapedObject, from: array)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let wraperedDelegate = delegate {
            if (displayingType == .list){
                return wraperedDelegate.getCellSizeForList()
            }
            return wraperedDelegate.getCellSizeForGreed()
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if (Device.isIpad){
            return NumericConstants.iPadGreedHorizontalSpace
        } else {
            return NumericConstants.iPhoneGreedHorizontalSpace
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if (Device.isIpad){
            return NumericConstants.iPadGreedHorizontalSpace
        } else {
            return NumericConstants.iPhoneGreedHorizontalSpace
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: NumericConstants.iPhoneGreedInset, bottom: 0, right: NumericConstants.iPhoneGreedInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height: CGFloat = isHeaderless ? 0 : 50
        return CGSize(width: collectionView.contentSize.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let isLastSection = (section == allItems.count - 1)
        
        let height: CGFloat
        if !isLastSection || (isPaginationDidEnd && (!isLocalPaginationOn && !isLocalFilesRequested)) {
            height = 0
        } else {
            height = 50
        }
        return CGSize(width: collectionView.contentSize.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewSuplementaryConstants.baseDataSourceForCollectionViewReuseID, for: indexPath)
            
            guard let textHeader = headerView as? CollectionViewSimpleHeaderWithText else {
                return headerView
            }
            
            let title = getHeaderText(indexPath: indexPath)
            
            textHeader.setText(text: title)
            
            textHeader.setSelectedState(selected: isHeaderSelected(section: indexPath.section), activateSelectionState: isSelectionStateActive && enableSelectionOnHeader)
            
            textHeader.selectionView.tag = indexPath.section
            if (textHeader.selectionView.gestureRecognizers == nil){
                let tapGesture = UITapGestureRecognizer(target: self,
                                                        action: #selector(onHeaderTap))
                textHeader.selectionView.addGestureRecognizer(tapGesture)
            }
            headers.insert(textHeader)
            return headerView
        case UICollectionElementKindSectionFooter:
            if indexPath.section == allItems.count - 1, !isPaginationDidEnd,
                 let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: CollectionViewSuplementaryConstants.collectionViewSpinnerFooter, for: indexPath) as? CollectionViewSpinnerFooter
                {
                footerView.startSpinner()
                return footerView
                
            } else {
                return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: CollectionViewSuplementaryConstants.collectionViewSpinnerFooter, for: indexPath)
            }
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }
    
    //MARK: UploadNotificationManagerProtocol
    
    func getIndexPathForObject(trimmedLocalID: String) -> IndexPath? {
        var indexPath: IndexPath? = nil
        
        for (section, array) in allItems.enumerated() {
            for (row, arraysObject) in array.enumerated() {
                if arraysObject.getTrimmedLocalID() == trimmedLocalID {
                    indexPath = IndexPath(row: row, section: section)
                }
            }
        }
        return indexPath
    }
    
    func getIndexPathForObject(itemUUID: String) -> IndexPath? {
        var indexPath: IndexPath? = nil
        
        for (section, array) in allItems.enumerated() {
            for (row, arraysObject) in array.enumerated() {
                if arraysObject.uuid == itemUUID {
                    indexPath = IndexPath(row: row, section: section)
                }
            }
        }
        return indexPath
    }
    
    func getCellForFile(objectUUID: String) -> CollectionViewCellForPhoto? {
        guard let path = getIndexPathForObject(itemUUID: objectUUID),
            let cell = collectionView?.cellForItem(at: path) as? CollectionViewCellForPhoto else {
                return nil
        }
        return cell
    }
    
    //Actualy those "new methods" wont needed if we just update Item model(UUID espetialy)
    
    func getIndexPathForLocalObject(objectTrimmedLocalID: String) -> IndexPath? {
        var indexPath: IndexPath? = nil
        
        for (section, array) in allItems.enumerated() {
            for (row, arraysObject) in array.enumerated() {
                if arraysObject.getTrimmedLocalID() == objectTrimmedLocalID, arraysObject.isLocalItem {
                    indexPath = IndexPath(row: row, section: section)
                }
            }
        }
        return indexPath
    }
    
    func getCellForLocalFile(objectTrimmedLocalID: String, completion: @escaping  (_ cell: CollectionViewCellForPhoto?)->Void) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            guard let path = self.getIndexPathForLocalObject(objectTrimmedLocalID: objectTrimmedLocalID) else {
                completion(nil)
                return
            }
            
            DispatchQueue.main.async {
                completion(self.collectionView?.cellForItem(at: path) as? CollectionViewCellForPhoto)
            }
        }
    }
    //----
    
    func startUploadFile(file: WrapData) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self, self.needShowProgressInCell, file.isLocalItem else {
                return
            }
            
            self.getCellForLocalFile(objectTrimmedLocalID: file.getTrimmedLocalID()) { (cell) in
                cell?.setProgressForObject(progress: 0, blurOn: true)
            }
        }
        
    }
    
    func setProgressForUploadingFile(file: WrapData, progress: Float) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self, self.needShowProgressInCell, file.isLocalItem else {
                return
            }
            
            self.getCellForLocalFile(objectTrimmedLocalID: file.getTrimmedLocalID()) { (cell) in
                cell?.setProgressForObject(progress: progress, blurOn: true)
            }
        }
    }
 
    func finishedUploadFile(file: WrapData){
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            if let unwrapedFilters = self.originalFilters,
                self.isAlbumDetail(filters: unwrapedFilters) {
                return
            }
            
            let uuid = file.getTrimmedLocalID()
            
            if self.uploadedObjectID.index(of: file.uuid) == nil {
                self.uploadedObjectID.append(uuid)
            }
            
            var localFinishedItemUUID: String?
            
            finished: for (section, array) in self.allItems.enumerated() {
                for (row, object) in array.enumerated() {
                    if object.getTrimmedLocalID() == uuid {
                        if object.isLocalItem {
                            localFinishedItemUUID = object.uuid
                            file.isLocalItem = false
                        }
                        guard self.allItems.count > section,
                            self.allItems[section].count > row else {
                                return /// Collection was reloaded from different thread
                        }
                        self.allItems[section][row] = file
                        break finished
                    }
                }
            }
            
            
            for (index, object) in self.allMediaItems.enumerated(){
                if object.uuid == file.uuid {
                    file.isLocalItem = false
                    self.allMediaItems[index] = file
                }
            }
            
            
            guard self.needShowProgressInCell else {
                return
            }
            
            DispatchQueue.main.async {
                if localFinishedItemUUID != nil, let cell = self.getCellForFile(objectUUID: file.uuid) {
                    cell.finishedUploadForObject()
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: { [weak self] in
                if let `self` = self{
                    let cell = self.getCellForFile(objectUUID: file.uuid)
                    cell?.resetCloudImage()
                    
                    if let index = self.uploadedObjectID.index(of: uuid){
                        self.uploadedObjectID.remove(at: index)
                    }
                }
            })
        }
    }
    
    func setProgressForDownloadingFile(file: WrapData, progress: Float) {
        if !needShowProgressInCell{
            return
        }
        
        if let cell = getCellForFile(objectUUID: file.uuid){
            cell.setProgressForObject(progress: progress)
        }
    }
    
    func finishedDownloadFile(file: WrapData) {
        if let cell = getCellForFile(objectUUID: file.uuid){
            cell.finishedDownloadForObject()
        }
    }
    
    func updateFavoritesCellStatus(items: [Item], isFavorites: Bool) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            var arrayOfPath = [IndexPath]()
            
            for item in items {
                if let path = self.getIndexPathForObject(itemUUID: item.uuid) {
                    arrayOfPath.append(path)
                }
            }
            
            if arrayOfPath.count > 0 {
                let uuids = items.map { $0.uuid }
                for array in self.allItems {
                    for arraysObject in array {
                        if uuids.contains(arraysObject.uuid) {
                            arraysObject.favorites = isFavorites
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.collectionView?.performBatchUpdates({ [weak self] in
                        if let `self` = self{
                            self.collectionView?.reloadItems(at: arrayOfPath)
                        }
                        }, completion: nil)
                }
            }
        }
    }
    
    func addFilesToFavorites(items: [Item]){
        if let unwrapedFilters = originalFilters, isFavoritesOnly(filters: unwrapedFilters) {
            delegate?.needReloadData()
        }else{
            updateFavoritesCellStatus(items: items, isFavorites: true)
        }
        
    }
    
    func removeFileFromFavorites(items: [Item]){
        if let unwrapedFilters = originalFilters, isFavoritesOnly(filters: unwrapedFilters) {
            updateCellsForObjects(objectsForDelete: items, objectsForUpdate: [Item]())
        }else{
            updateFavoritesCellStatus(items: items, isFavorites: false)
        }
    }
    
    func deleteItems(items: [Item]) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            if self.allItems.isEmpty {
                return
            }
            guard !items.isEmpty else {
                return
            }
            
            var idsForRemove = [String]()
            var objectsForReplaceDict = [String : Item]()
            
            if let unwrapedFilters = self.originalFilters,
                !self.showOnlyRemotes(filters: unwrapedFilters) {
                
                var serverObjects = [Item]()
                
                var allItemsIDs = [String]()
                for array in self.allItems {
                    for object in array {
                        allItemsIDs.append(object.getTrimmedLocalID())
                    }
                }
                
                for object in items {
                    if object.isLocalItem {
                        idsForRemove.append(object.getTrimmedLocalID())
                    } else {
                        serverObjects.append(object)
                    }
                }
                
                let localIDs = serverObjects.map {
                    $0.getTrimmedLocalID()
                }
                let localObjectsForReplace = CoreDataStack.default.allLocalItems(trimmedLocalIds: localIDs)
                
                let foundedLocalID = localObjectsForReplace.map {
                    $0.getTrimmedLocalID()
                }
                for object in serverObjects {
                    let trimmedID = object.getTrimmedLocalID()
                    if let index = foundedLocalID.index(of: trimmedID) {
                        let objForReplace = localObjectsForReplace[index]
                        if let index = allItemsIDs.index(of: trimmedID){
                            allItemsIDs.remove(at: index)
                            if allItemsIDs.contains(trimmedID){
                                idsForRemove.append(object.uuid)
                            } else {
                                objectsForReplaceDict[object.uuid] = objForReplace
                            }
                        }
                    } else {
                        idsForRemove.append(object.uuid)
                    }
                }
            } else {
                idsForRemove = items.map{
                    $0.uuid
                }
            }
            
            var newArray = [[WrapData]]()
            
            for array in self.allItems {
                var newSectionArray = [WrapData]()
                for object in array {
                    
                    if let index = idsForRemove.index(of: object.getTrimmedLocalID()) {
                        self.allMediaItems.remove(object)
                        idsForRemove.remove(at: index)
                        self.recentlyDeletedIndexes.append(contentsOf: self.getIndexPathsForItems([object]))///FOR now like that, in future = it should be called after with whole array
                        continue
                    }
                    if let obj = objectsForReplaceDict[object.uuid]{
                        newSectionArray.append(obj)
                        continue
                    }
                    newSectionArray.append(object)
                }
                if !newSectionArray.isEmpty{
                    newArray.append(newSectionArray)
                }
            }
            self.allItems = newArray
            
            //update folder items count
            if let parentUUID = items.first(where: { $0.parent != nil })?.parent {
                self.updateItems(count: items.count, forFolder: parentUUID, increment: false)
            }
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.delegate?.didDelete(items: items)
                
                self.updateCoverPhoto()
            }
        }
    }
    
    private func updateCellsForObjects(objectsForDelete: [Item], objectsForUpdate:[Item]) {
        if objectsForDelete.isEmpty && objectsForUpdate.isEmpty {
            return
        }
        
        var arrayOfPathForDelete = [IndexPath]()
        var arrayOfPathForUpdate = [IndexPath]()
        var arrayOfSection = [Int]()
        
        for item in objectsForDelete {
            if let path = getIndexPathForObject(trimmedLocalID: item.getTrimmedLocalID()) {
                arrayOfPathForDelete.append(path)
            }
        }
        
        if arrayOfPathForDelete.count > 0{
            var newArray = [[Item]]()
            var trimmedLocalIDs = objectsForDelete.map { $0.getTrimmedLocalID() }
            
            var section = 0
            for array in allItems {
                var newSectionArray = [Item]()
                for arraysObject in array {
                    if let index = trimmedLocalIDs.index(of: arraysObject.getTrimmedLocalID()) {
                        trimmedLocalIDs.remove(at: index)
                    } else {
                        newSectionArray.append(arraysObject)
                    }
                }
                
                if newSectionArray.count > 0 {
                    newArray.append(newSectionArray)
                } else {
                    arrayOfSection.append(section)
                }
                
                section += 1
            }
            
            setAllItems(items: newArray)
        }
        
        for item in objectsForUpdate {
            if let path = getIndexPathForObject(trimmedLocalID: item.getTrimmedLocalID()) {
                arrayOfPathForUpdate.append(path)
                //FIXME: arrayOfPathForUpdate is never used
            }
        }
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    func newFolderCreated(){
        if let unwrapedFilters = originalFilters,
            canShowFolderFilters(filters: unwrapedFilters) {
            delegate?.needReloadData()
        }
    }
    
    func newAlbumCreated(){
        if let unwrapedFilters = originalFilters,
            canShowAlbumsFilters(filters: unwrapedFilters) {
            delegate?.needReloadData()
        }
    }
    
    func newStoryCreated() {
        
    }
    
    func updatedAlbumCoverPhoto(item: BaseDataSourceItem) {
        debugPrint("updatedAlbumCoverPhoto")
        ///Need further testing, seems like we dont need this any longer.
//        updateCellsForObjects(objectsForDelete: [], objectsForUpdate: [item as! WrapData])
    }
    
    func albumsDeleted(albums: [AlbumItem]) {
        
    }
    
    func startUploadFilesToAlbum(files: [WrapData]) {
        guard let unwrapedFilters = originalFilters,
            isAlbumDetail(filters: unwrapedFilters) else {
            return
        }
        uploadToAlbumItems.append(contentsOf: files.map {$0.uuid})
    }
    
    func fileAddedToAlbum(item: WrapData, error: Bool) {
        guard let unwrapedFilters = originalFilters,
            isAlbumDetail(filters: unwrapedFilters) else {
                return
        }
        if let index = uploadToAlbumItems.index(of: item.uuid) {
            uploadToAlbumItems.remove(at: index)
        }
        if uploadToAlbumItems.isEmpty {
            delegate?.needReloadData()
            updateCoverPhoto()
        }
    }
    
    func filesAddedToAlbum() {
        if let unwrapedFilters = originalFilters,
            isAlbumDetail(filters: unwrapedFilters) {
            delegate?.needReloadData()
        }
        updateCoverPhoto()
    }
    
    func filesUpload(count: Int, toFolder folderUUID: String) {
        if let unwrapedFilters = originalFilters,
            canUploadFromLifeBox(filters: unwrapedFilters) {
            delegate?.needReloadData()
        }
        
        updateItems(count: count, forFolder: folderUUID, increment: true)        
        updateCoverPhoto()
    }
    
    func addedLocalFiles(items: [Item]) {
//        if let unwrapedFilters = originalFilters,
//            isAlbumDetail(filters: unwrapedFilters) {
//            return
//        }
//        
//        if let unwrapedFilters = originalFilters, isFavoritesOnly(filters: unwrapedFilters) {
//            return
//        }
//        allLocalItems.append(contentsOf: items)
//        delegate?.needReloadData?()
    }
    
    func filesRomovedFromAlbum(items: [Item], albumUUID: String){
        if let uuid = parentUUID, uuid == albumUUID{
            deleteItems(items: items)
        }
        updateCoverPhoto()
    }
    
    func filesMoved(items: [Item], toFolder folderUUID: String) {
        //update new folder items count
        updateItems(count: items.count, forFolder: folderUUID, increment: true)
        
        //insert items to new folder
        if let folder = delegate?.getFolder(), folder.uuid == folderUUID {
            delegate?.needReloadData()
        } else if delegate?.getFolder() == nil {
            //root folder (all files)
            delegate?.needReloadData()
        }
        
        if let uuid = parentUUID, uuid != folderUUID {
            deleteItems(items: items)
        } else if let unwrapedFilters = originalFilters,
            canShowFolderFilters(filters: unwrapedFilters) {
            deleteItems(items: items)
        }
    }
    
    func syncFinished() {
        if isLocalOnly(){
            return
        }
        delegate?.needReloadData()
    }
    
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        if let compairedView = object as? BaseDataSourceForCollectionView {
            return compairedView == self
        }
        return false
    }
    
    func updateCoverPhoto() {
        delegate?.updateCoverPhotoIfNeeded()
    }
    
    func updateItems(count: Int, forFolder folderUUID: String, increment: Bool) {
        if let indexPath = getIndexPathForObject(itemUUID: folderUUID),
            let item = itemForIndexPath(indexPath: indexPath) as? WrapData,
            let childCount = item.childCount {
            if increment {
                item.childCount = childCount + Int64(count)
            } else {
                item.childCount = childCount - Int64(count)
            }
        }
    }
}


extension BaseDataSourceForCollectionView {

    fileprivate func resetCachedAssets() {
        filesDataSource.stopCahcingAllImages()
        previousPreheatRect = .zero
    }
    
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard
            let collectionView = collectionView,
            let view = collectionView.superview,
            view.window != nil,
            !allItems.isEmpty
        else {
            return
        }
        
        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .flatMap { (indexPath) -> PHAsset? in
                var asset: PHAsset?
                if let item = itemForIndexPath(indexPath: indexPath) as? Item {
                    if case let PathForItem.localMediaContent(local) = item.patchToPreview {
                        asset = local.asset
                    }
                }
                return asset
        }
        let removedAssets = removedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .flatMap {  (indexPath) -> PHAsset? in
                var asset: PHAsset?
                if let item = itemForIndexPath(indexPath: indexPath) as? Item {
                    if case let PathForItem.localMediaContent(local) = item.patchToPreview {
                        asset = local.asset
                    }
                }
                return asset
        }
        
        // Update the assets the PHCachingImageManager is caching.
        filesDataSource.startCahcingImages(for: addedAssets)
//        print("Started \(addedAssets.count) request(s) of images")
        filesDataSource.stopCahcingImages(for: removedAssets)
//        print("Removed \(removedAssets.count) request(s) of images")
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }

}
