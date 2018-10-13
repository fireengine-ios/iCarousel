 //
//  PhotoVideoDataSourceForCollectionView.swift
//  Depo
//
//  Created by Aleksandr on 10/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class PhotoVideoDataSourceForCollectionView: BaseDataSourceForCollectionView {
    
    override var isPaginationDidEnd: Bool {
        willSet {
            if !newValue {
                CardsManager.default.startOperationWith(type: .prepareQuickScroll)
            }  else {
                CardsManager.default.stopOperationWithType(type: .prepareQuickScroll)
            }
        }
    }
    
    private let scrollBar = ScrollBarView()
    private let yearsView = YearsView()
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
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
            if url != nil, let meta = wraped.metaData {
                cell_.setImage(with: meta)
            } else {
                cell_.setPlaceholderImage(fileType: wraped.fileType)
            }
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
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let isLastSection = (section == allItems.count - 1)
        
        let height: CGFloat
        if !isLastSection || (isPaginationDidEnd && !isLocalPaginationOn) {
            height = 0
        } else {
            height = 50
        }
        return CGSize(width: collectionView.contentSize.width, height: height)
    }
    
    override func setupCollectionView(collectionView: UICollectionView, filters: [GeneralFilesFiltrationType]? = nil){
        
        originalFilters = filters
        
        self.collectionView = collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        
        registerHeaders()
        registerFooters()
        registerCells()
    }
    
    override func updateScrollBarTextIfNeed() {
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
            scrollBar.setText(headerText)
        }
    }
    
    private func filesAppendedAndSorted() {
        delegate?.filesAppendedAndSorted()
        CardsManager.default.stopOperationWithType(type: .prepareQuickScroll)
        addScrollBar()
        updateYearsView()
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    private var isScrollBarAdded = false
    
    private func addScrollBar() {
        guard !isScrollBarAdded, let collectionView = collectionView else {
            return
        }
        isScrollBarAdded = true
        yearsView.add(to: collectionView)
        scrollBar.add(to: collectionView)
        scrollBar.delegate = self
    }
    
    private func updateYearsView() {
        if allItems.isEmpty {
            return
        }
        
        let numberOfColumns = Int(Device.isIpad ? NumericConstants.numerCellInLineOnIpad : NumericConstants.numerCellInLineOnIphone)
        // TODO: getCellSizeForList must be called in main queue. for a while it is woking without it
        let cellHeight = delegate?.getCellSizeForList().height ?? 0
        let dates = allItems.flatMap({ $0 }).flatMap({ $0.metaData?.takenDate})
        yearsView.update(cellHeight: cellHeight, headerHeight: 50, numberOfColumns: numberOfColumns)
        
        if !emptyMetaItems.isEmpty {
            yearsView.update(additionalSections: [(TextConstants.photosVideosViewMissingDatesHeaderText, emptyMetaItems.count)])
        }
        
        yearsView.update(by: dates)
    }
    
    override func appendCollectionView(items: [WrapData], pageNum: Int) {
       debugPrint("---APPEND page num is %i", pageNum)
        if isPaginationDidEnd, !isLocalPaginationOn {
            ///appending missing dates section when all other items are represented
            allItems.append(emptyMetaItems)
            self.batchInsertItems(newIndexes: ResponseResult.success(self.getIndexPathsForItems(emptyMetaItems)))
            
            filesAppendedAndSorted()
            return
        }
        var tempoEmptyItems = [WrapData]()
        var filteredItems = [WrapData]()
        
        
        items.forEach {
            if !$0.isLocalItem, $0.metaData?.takenDate != nil {
                filteredItems.append($0)
            } else {
                tempoEmptyItems.append($0)
            }
        }
        emptyMetaItems.append(contentsOf: tempoEmptyItems)
        pageCompounder.appendNotAllowedItems(items: emptyMetaItems)

        if tempoEmptyItems.count >= pageCompounder.pageSize {
            self.breakItemsIntoSections(breakingArray: self.allMediaItems)
            self.batchInsertItems(newIndexes: ResponseResult.success([]))
            return
        }
        
        if filteredItems.isEmpty, tempoEmptyItems.isEmpty {
            isPaginationDidEnd = true
        }
        
        compoundItems(pageItems: filteredItems, pageNum: pageNum, originalRemotes: true, complition: { [weak self] response in
            guard let `self` = self else {
                return
            }
        
            self.batchInsertItems(newIndexes: response)
        })
    }
    
    override func compoundItems(pageItems: [WrapData], pageNum: Int, originalRemotes: Bool = false, complition: @escaping ResponseArrayHandler<IndexPath>) {
        debugPrint("---cumpound page num is %i", pageNum)
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                complition(ResponseResult.success([]))
                return
            }
            
            guard let unwrapedFilters = self.originalFilters,
                let specificFilters = self.getFileFilterType(filters: unwrapedFilters)
                else {
                    self.allMediaItems.append(contentsOf: pageItems)
                    self.isLocalPaginationOn = false
                    self.isHeaderless ? self.setupOneSectionMediaItemsArray(items: self.allMediaItems) : self.breakItemsIntoSections(breakingArray: self.allMediaItems)

                    complition(ResponseResult.success(self.getIndexPathsForItems(pageItems)))
                    return
            }
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
                })
            } else if self.isPaginationDidEnd {
                let isEmptyLeftOvers = self.pageLeftOvers.filter{!$0.isLocalItem}.isEmpty
                var itemsToCompound = isEmptyLeftOvers ? pageTempoItems : self.transformedLeftOvers()
                var needToDropFirstItem = false
                if pageTempoItems.isEmpty, isEmptyLeftOvers, let lastMediItem = self.allMediaItems.last {
                    itemsToCompound.append(lastMediItem)
                    needToDropFirstItem = true
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
                })
            } else if !self.isPaginationDidEnd { ///Middle page
                let isEmptyLeftOvers = self.pageLeftOvers.isEmpty
                let itemsToCompound = isEmptyLeftOvers ? pageTempoItems : self.pageLeftOvers
                if pageTempoItems.isEmpty, itemsToCompound.isEmpty {
                    self.isLocalFilesRequested = false
                    self.delegate?.getNextItems()
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
                })
            }
        }
    }
    
    func batchInsertItems(newIndexes: ResponseResult<[IndexPath]>) {
        //completion: VoidHandler
        guard let collectionView = collectionView else {
            return
        }
        
        switch newIndexes {
        case .success(let array):
            if self.isDropedData || array.isEmpty {
                DispatchQueue.main.async {
                    if self.needReloadData {
                        self.collectionView?.reloadData()
                    }
                    self.isLocalFilesRequested = false
                    self.delegate?.filesAppendedAndSorted()
                    self.isDropedData = false
                    self.delegate?.getNextItems()
                }
                
            } else {
                guard let lastIndex = array.last else {
                    return
                }
                DispatchQueue.main.async {
                    let newSectionNum = lastIndex.section + 1
                    let oldSectionNum = collectionView.numberOfSections
                    
                    var newArray = IndexSet()
                    if newSectionNum > oldSectionNum {
                        newArray = IndexSet(integersIn: Range(oldSectionNum..<newSectionNum))
                    }

                    collectionView.performBatchUpdates({
                        guard !self.allItems.isEmpty else {
                            return
                        }
                        collectionView.insertSections(newArray)
                        collectionView.insertItems(at: array)
                    }, completion: { status in
                        guard !self.isDropedData else {
                            return
                        }
                        self.delegate?.filesAppendedAndSorted()
                        self.isLocalFilesRequested = false
                        self.dispatchQueue.async { [weak self] in
                            guard let `self` = self else {
                                return
                            }
                            if !self.isPaginationDidEnd {
                                if self.pageLeftOvers.isEmpty {
                                    self.delegate?.getNextItems()
                                } else if !self.pageLeftOvers.isEmpty{
                                    self.compoundItems(pageItems: [], pageNum: self.lastPage, complition: { [weak self] response in
                                        self?.batchInsertItems(newIndexes: response)
                                    })
                                }
                            } else if self.isLocalPaginationOn {
                                ///PageNum: 2 beacause we need to compound page applying middle page rules.
                                self.compoundItems(pageItems: [], pageNum: 2, complition: { [weak self] response in
                                    
                                    self?.batchInsertItems(newIndexes: response)
                                })
                            }
                        }
                    })
                }
            }
        case .failed(_):
            delegate?.filesAppendedAndSorted()
            isLocalFilesRequested = false
        }
    }
    
    override func breakItemsIntoSections(breakingArray: [WrapData]) {
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
       //// currently we add missing dates after all collection is presented, (at the very end)
//        if needShowEmptyMetaDataItems && !emptyMetaItems.isEmpty {
//            if currentSortType == .metaDataTimeUp {
//                allItems.append(emptyMetaItems)
//            } else if currentSortType == .metaDataTimeDown {
//                allItems.insert(emptyMetaItems, at: 0)
//            }
//        }
    }
    
}

 extension PhotoVideoDataSourceForCollectionView: ScrollBarViewDelegate {
    func scrollBarViewBeganDraggin() {
        yearsView.showAnimated()
    }
    func scrollBarViewDidEndDraggin() {
        updateScrollBarTextIfNeed()
        yearsView.hideAnimated()
    }
 }
 
