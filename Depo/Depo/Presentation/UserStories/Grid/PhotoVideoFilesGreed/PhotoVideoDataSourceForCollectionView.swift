 //
//  PhotoVideoDataSourceForCollectionView.swift
//  Depo
//
//  Created by Aleksandr on 10/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class PhotoVideoDataSourceForCollectionView: BaseDataSourceForCollectionView {
    
    private let itemProvider: ItemsProvider
    private let scrollBarManager = PhotoVideoScrollBarManager()
    private var showOnlySynched = false
    private let compounderMidPage: Int = 2
    
    //MARK:- Initial state/setup
    
    init(sortingRules: SortedRules, fieldValue: FieldValue) {
        self.itemProvider = ItemsProvider(fieldValue: fieldValue)
        super.init(sortingRules: sortingRules)
        
    }

    override func setupCollectionView(collectionView: UICollectionView, filters: [GeneralFilesFiltrationType]? = nil) {
        
        originalFilters = filters
        self.collectionView = collectionView
        
        self.scrollBarManager.addScrollBar(to: self.collectionView, delegate: self)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        registerHeaders()
        registerFooters()
        registerCells()
        
        if !ItemsRepository.sharedSession.allItemsReady {
            let cardType: OperationType = (itemProvider.fieldValue == .image) ? .preparePhotosQuickScroll : .prepareVideosQuickScroll
            CardsManager.default.startOperationWith(type: cardType)
        }
    }
    
    //MARK:- Main Calculations/ Array related activities
    
    func showOnlySync(onlySync: Bool) {
        isDropedData = true
        DispatchQueue.main.async {
            self.allMediaItems.removeAll()
            self.dropData()
            self.showOnlySynched = onlySync
            self.isLocalPaginationOn = !onlySync
            self.itemProvider.reloadItems(callback: { [weak self] remotes in
                self?.appendCollectionView(items: remotes, pageNum: 0)
            })
        }
    }
    
    func hideScrollIndicatorIfNeeded() {
        scrollBarManager.startTimerToHideScrollBar()
    }
    
    override func dropData() {
        emptyMetaItems.removeAll()
        allItems.removeAll()
        pageLeftOvers.removeAll()
        allMediaItems.removeAll()
        pageCompounder.dropData()

        
        isDropedData = true
    }
    
    override func reloadData() {
        switch itemProvider.fieldValue {
        case .image:
            PhotoVideoFilesGreedModuleStatusContainer.shared.isPhotoScreenPaginationDidEnd = false
        case .video:
            PhotoVideoFilesGreedModuleStatusContainer.shared.isVideoScreenPaginationDidEnd = false
        default:
            break
        }
        isPaginationDidEnd = false
        isLocalPaginationOn = true
        isLocalFilesRequested = false
        super.reloadData()
        dispatchQueue.async { [weak self] in
            self?.itemProvider.reloadItems(callback: { [weak self] remotes in
                self?.appendCollectionView(items: remotes, pageNum: 1)
            })
        }
    }
    
    override func appendCollectionView(items: [WrapData], pageNum: Int) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            if self.isPaginationDidEnd, !self.isLocalPaginationOn {
                ///appending missing dates section when all other items are represented
                if !self.emptyMetaItems.isEmpty {
                    self.allItems.append(self.emptyMetaItems)
                    self.batchInsertItems(newIndexes: ResponseResult.success(self.getIndexPathsForItems(self.emptyMetaItems)), complition: nil)
                }
                self.filesAppendedAndSorted()
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
            self.emptyMetaItems.append(contentsOf: tempoEmptyItems)
            self.pageCompounder.appendNotAllowedItems(items: self.emptyMetaItems)
            
            if tempoEmptyItems.count >= self.pageCompounder.pageSize {
                self.breakItemsIntoSections(breakingArray: self.allMediaItems)
                self.batchInsertItems(newIndexes: ResponseResult.success([]), complition: nil)
                return
            }
            
            if filteredItems.isEmpty, tempoEmptyItems.isEmpty {
                self.isPaginationDidEnd = true
            }
            /**
             NOW:
             whole page compunding cycle is one operation
            */
            let batchOperation = BlockOperation{ [weak self] in
                guard let `self` = self else {
                    return
                }
                let semaphore = DispatchSemaphore(value: 0)
                self.compoundItems(pageItems: filteredItems, pageNum: pageNum, originalRemotes: true, complition: { [weak self] response in
                    guard let `self` = self else {
                        semaphore.signal()
                        return
                    }
                    self.batchInsertItems(newIndexes: response) {
                        semaphore.signal()
                    }
                })
                semaphore.wait()
            }
            self.batchOperations.addOperation(batchOperation)
        }
    }
    
    override func compoundItems(pageItems: [WrapData], pageNum: Int, originalRemotes: Bool = false, complition: @escaping ResponseArrayHandler<IndexPath>) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                complition(ResponseResult.success([]))
                return
            }
            
            guard !self.showOnlySynched else {
                self.allMediaItems.append(contentsOf: pageItems)
                self.isLocalPaginationOn = false
                self.isHeaderless ? self.setupOneSectionMediaItemsArray(items: self.allMediaItems) : self.breakItemsIntoSections(breakingArray: self.allMediaItems)
                
                complition(ResponseResult.success(self.getIndexPathsForItems(pageItems)))
                return
//                complition(ResponseResult.success([]))
//
//                return
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
                        self?.dispatchQueue.async { [weak self] in
                            guard let `self` = self else {
                                return
                            }
                            self.pageLeftOvers.removeAll()
                            self.pageLeftOvers.append(contentsOf: lefovers)
                            self.allMediaItems.append(contentsOf: compoundedItems)
                            self.isHeaderless ? self.setupOneSectionMediaItemsArray(items: self.allMediaItems) : self.breakItemsIntoSections(breakingArray: self.allMediaItems)
                            
                            complition(ResponseResult.success(self.getIndexPathsForItems(compoundedItems)))
                        }
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
                        self?.dispatchQueue.async { [weak self] in
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
                        }
                })
            } else if !self.isPaginationDidEnd { ///Middle page
                let isEmptyLeftOvers = self.pageLeftOvers.isEmpty
                let itemsToCompound = isEmptyLeftOvers ? pageTempoItems : self.pageLeftOvers
                if pageTempoItems.isEmpty, itemsToCompound.isEmpty {
                    self.isLocalFilesRequested = false
                    self.itemProvider.getNextItems(callback: { [weak self] remotes in
                        self?.appendCollectionView(items: remotes, pageNum: self?.itemProvider.currentPage ?? 0)
                    })
                    return
                }
                
                self.pageCompounder.compoundMiddlePage(pageItems: itemsToCompound,
                                                       filesType: specificFilters,
                                                       sortType: self.currentSortType,
                                                       compoundedCallback:
                    { [weak self] (compoundedItems, lefovers) in
                        self?.dispatchQueue.async { [weak self] in
                            guard let `self` = self else {
                                return
                            }
                            self.pageLeftOvers.removeAll()
                            self.pageLeftOvers.append(contentsOf: lefovers)
                            
                            self.allMediaItems.append(contentsOf: compoundedItems)
                            
                            self.isHeaderless ? self.setupOneSectionMediaItemsArray(items: self.allMediaItems) : self.breakItemsIntoSections(breakingArray: self.allMediaItems)
                            complition(ResponseResult.success(self.getIndexPathsForItems(compoundedItems)))
                        }
                })
            }
        }
    }
    
    func batchInsertItems(newIndexes: ResponseResult<[IndexPath]>, complition: VoidHandler?) {
        
        guard let collectionView = collectionView else {
            complition?()
            return
        }
        
        switch newIndexes {
        case .success(let array):
            if self.isDropedData || array.isEmpty {
                DispatchQueue.main.async {
                    if self.needReloadData {
                        CellImageManager.clear()
                        self.needReloadData = false
                        self.collectionView?.reloadData()
                        let cellHeight = self.delegate?.getCellSizeForGreed().height ?? 0
                        self.scrollBarManager.updateYearsView(with: self.allItems, emptyMetaItems: self.emptyMetaItems, cellHeight: cellHeight)
                    }
                    self.isLocalFilesRequested = false
                    self.delegate?.filesAppendedAndSorted()
                    self.isDropedData = false
                    if self.pageLeftOvers.isEmpty {
                        self.itemProvider.getNextItems(callback: { [weak self] remotes in
                            self?.appendCollectionView(items: remotes, pageNum: self?.itemProvider.currentPage ?? 0)
                            complition?()
                        })
                    } else {
                        ///We send here 2 because current compound logic is separeted into
                        ///3 ways: first page, mid page, last page.
                        ///2 is for mid page logic.(any number that not 1 and pagination did not end)
                        self.compoundItems(pageItems: [], pageNum: self.compounderMidPage) { [weak self] response in
                            self?.batchInsertItems(newIndexes: response, complition: complition)
                        }
                    }
//                    self.delegate?.getNextItems()
                }
            } else {
                guard let lastIndex = array.last else {
                    complition?()
                    return
                }

                DispatchQueue.main.async {
                    ///--
                    ///Original place of new Indexes calculation
                    ///--
                    collectionView.collectionViewLayout.invalidateLayout()
                    collectionView.performBatchUpdates({
                        guard !self.allItems.isEmpty else {
                            return
                        }
                        ///---
                        ///While Array of arrays is not safe we will add it here, so there should be no crashes on incert
                        let newSectionNum = lastIndex.section + 1
                        let oldSectionNum = collectionView.numberOfSections
                        var newArray = IndexSet()
                        if newSectionNum > oldSectionNum {
                            newArray = IndexSet(integersIn: Range(oldSectionNum..<newSectionNum))
                        }
                        ///---
                        collectionView.insertSections(newArray)
                        collectionView.insertItems(at: array)
                    }, completion: { status in
                        guard !self.isDropedData else {
                            complition?()
                            return
                        }
                        let cellHeight = self.delegate?.getCellSizeForGreed().height ?? 0
                        self.scrollBarManager.updateYearsView(with: self.allItems, emptyMetaItems: self.emptyMetaItems, cellHeight: cellHeight)
                        self.delegate?.filesAppendedAndSorted()
                        self.isLocalFilesRequested = false
                        self.dispatchQueue.async { [weak self] in
                            guard let `self` = self else {
                                complition?()
                                return
                            }
                            if !self.isPaginationDidEnd {
                                if self.pageLeftOvers.isEmpty {
                                    self.itemProvider.getNextItems(callback: { [weak self] remotes in
                                        self?.appendCollectionView(items: remotes, pageNum: self?.itemProvider.currentPage ?? 0)
                                        complition?()
                                    })
                                    //                                    self.delegate?.getNextItems()
                                } else if !self.pageLeftOvers.isEmpty{
                                    self.compoundItems(pageItems: [], pageNum: self.lastPage, complition: { [weak self] response in
                                        self?.batchInsertItems(newIndexes: response, complition: complition)
                                        
                                    })
                                }
                            } else if self.isLocalPaginationOn {
                                ///PageNum: 2 beacause we need to compound page applying middle page rules.
                                self.compoundItems(pageItems: [], pageNum: 2, complition: { [weak self] response in
                                    
                                    self?.batchInsertItems(newIndexes: response, complition: complition)
                                    
                                })
                            } else {
                                complition?()
                            }
                        }
                    })
                }
            }
        case .failed(_):
            delegate?.filesAppendedAndSorted()
            isLocalFilesRequested = false
            complition?()
        }
    }
    
    override func breakItemsIntoSections(breakingArray: [WrapData]) {
        var newAllItems = [[WrapData]]()
        
        for item in breakingArray {
            autoreleasepool {
                if !newAllItems.isEmpty, let lastItem = newAllItems.last?.last {
                    let lastItemCreatedDate = lastItem.metaDate
                    let newItemCreationDate = item.metaDate
                    
                    if lastItemCreatedDate.getYear() == newItemCreationDate.getYear(),
                        lastItemCreatedDate.getMonth() == newItemCreationDate.getMonth()
                    {
                        newAllItems[newAllItems.count - 1].append(item)
                    } else {
                        newAllItems.append([item])
                    }
                } else {
                    newAllItems.append([item])
                }
            }
        }
        
        DispatchQueue.toMain {
            self.allItems = newAllItems
        }
    }
    
    private func hideQSCard(photos: Bool) {
        let cardType: OperationType = photos ? .preparePhotosQuickScroll : .prepareVideosQuickScroll
        CardsManager.default.stopOperationWithType(type: cardType)
    }
    
    private func filesAppendedAndSorted() {
        delegate?.filesAppendedAndSorted()
        
        let statusContainer = PhotoVideoFilesGreedModuleStatusContainer.shared
        
        switch itemProvider.fieldValue {
        case .image:
            statusContainer.isPhotoScreenPaginationDidEnd = true
            hideQSCard(photos: true)
        case .video:
            statusContainer.isVideoScreenPaginationDidEnd = true
            hideQSCard(photos: false)
        default:
            break
        }
        
        DispatchQueue.main.async {
            self.scrollBarManager.addScrollBar(to: self.collectionView, delegate: self)
            let cellHeight = self.delegate?.getCellSizeForGreed().height ?? 0
            self.scrollBarManager.updateYearsView(with: self.allItems, emptyMetaItems: self.emptyMetaItems, cellHeight: cellHeight)
            CellImageManager.clear()
            self.collectionView?.reloadData() ///Check if we can just reload one supplementary view
        }
    }
    
    //MARK:- Collection delegate/ data source
    
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
            filesDataSource.getAssetThumbnail(asset: local.asset, indexPath: indexPath, completion: { (image, path) in
                DispatchQueue.main.async {
                    if cell_.getAssetId() == local.asset.localIdentifier, let image = image {
                        cell_.setImage(image: image, animated:  true)
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
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewSuplementaryConstants.baseDataSourceForCollectionViewReuseID, for: indexPath)
            
            guard let textHeader = headerView as? CollectionViewSimpleHeaderWithText else {
                return headerView
            }
        
            let title = getHeaderText(indexPath: indexPath)
            
            textHeader.setText(text: title)
//            textHeader.setSelectedState(selected: isHeaderSelected(section: indexPath.section), activateSelectionState: isSelectionStateActive && enableSelectionOnHeader)
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
    
    //MARK:- Scroll Related
    
    func updateScrollBarTextIfNeed() {
        let firstVisibleIndexPath = collectionView?.indexPathsForVisibleItems.min(by: { first, second -> Bool in
            return first < second
        })
        
        guard let indexPath = firstVisibleIndexPath else {
            return
        }
        
        let headerText = getHeaderText(indexPath: indexPath, shortForm: true)
        scrollBarManager.scrollBar.setText(headerText)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        updateScrollBarTextIfNeed()
        scrollBarManager.scrollViewDidScroll()
        scrollBarManager.hideScrollBarIfNeed(for: scrollView.contentOffset.y)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        super.scrollViewDidEndDecelerating(scrollView)
        stoppedScrolling()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        if !decelerate {
            stoppedScrolling()
        }
    }
    
    private func stoppedScrolling() {
        scrollBarManager.startTimerToHideScrollBar()
    }
}

extension PhotoVideoDataSourceForCollectionView: ScrollBarViewDelegate {
    func scrollBarViewBeganDraggin() {
        scrollBarManager.yearsView.showAnimated()
    }
    func scrollBarViewDidEndDraggin() {
        updateScrollBarTextIfNeed()
        scrollBarManager.yearsView.hideAnimated()
        stoppedScrolling()
    }
}
