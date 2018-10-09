 //
//  PhotoVideoDataSourceForCollectionView.swift
//  Depo
//
//  Created by Aleksandr on 10/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class PhotoVideoDataSourceForCollectionView: BaseDataSourceForCollectionView {
    
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
            if let url = url {
                cell_.setImage(with: url)
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
    
    override func appendCollectionView(items: [WrapData], pageNum: Int) {
       debugPrint("---APPEND page num is %i", pageNum)
        guard !isPaginationDidEnd else {
            delegate?.filesAppendedAndSorted()
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
            self.batchInsertItems(newIndexes: ResponseResult.success([]), emptyItems: tempoEmptyItems)
            return
        }
        
        if filteredItems.isEmpty, tempoEmptyItems.isEmpty {
            isPaginationDidEnd = true
        }
        
        compoundItems(pageItems: filteredItems, pageNum: pageNum, originalRemotes: true, complition: { [weak self] response in
            debugPrint("---BATH page num is %i", pageNum)
            self?.batchInsertItems(newIndexes: response, emptyItems: tempoEmptyItems)
            
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
            self.isLocalPaginationOn = true//////???????
            
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
    
    func batchInsertItems(newIndexes: ResponseResult<[IndexPath]>, emptyItems: [Item]) {
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
                DispatchQueue.main.async {
//                    let oldSectionNumbers = collectionView.numberOfSections
//                    let newSectionNumbers = self.numberOfSections(in: collectionView)
//
//                    if newSectionNumbers > oldSectionNumbers {
//                        let needMoveSectionWithEmptyMetaItems = self.needShowEmptyMetaItems && self.currentSortType == .metaDataTimeUp && containsEmptyMetaItems
//
//                        if needMoveSectionWithEmptyMetaItems {
//                            debugPrint("!!! needMoveSectionWithEmptyMetaItems 1")
//                            //                            newSections = IndexSet(oldSectionNumbers-1..<newSectionNumbers-1)
//                        } else {
//                            debugPrint("!!! needMoveSectionWithEmptyMetaItems 2")
//                            //                            newSections = IndexSet(oldSectionNumbers..<newSectionNumbers)
//                        }
//                    } else if newSectionNumbers < oldSectionNumbers {
//                        return
//                        /// here add section deletion
//                    }///error ocure when was appending to same action but the data was just dropped - recieved and droped
//
//
//                    collectionView.collectionViewLayout.invalidateLayout()
                    self.delegate?.filesAppendedAndSorted()
                    self.collectionView?.reloadData()
//                    collectionView.performBatchUpdates(nil, completion: { [weak self] _ in
//                        guard let `self` = self else {
//                            return
//                        }
                        self.isLocalFilesRequested = false//////dont need it now?
//                        self.delegate?.filesAppendedAndSorted()
//                        //FIXME: part of appending+ incerting should be rewitten or trigger for new page
//                        self.dispatchQueue.async { [weak self] in
//                            guard let `self` = self else {
//                                return
//                            }
//                            print("BATCH: \(!self.isPaginationDidEnd), \(self.isLocalPaginationOn), \(!self.isLocalFilesRequested)")
//                            if !self.isPaginationDidEnd,
//                                self.isLocalPaginationOn,
//                                !self.isLocalFilesRequested {// array.count < self.pageCompounder.pageSize {
//                                debugPrint("!!! TRY TO GET NEW PAGE")
                   
                    
                    
                    
                    ///----------------------////
                    if !self.isPaginationDidEnd {
                        if self.pageLeftOvers.isEmpty {
                            self.delegate?.getNextItems()
                        } else if !self.pageLeftOvers.isEmpty{
                            self.compoundItems(pageItems: [], pageNum: self.lastPage, complition: { [weak self] response in
                                self?.batchInsertItems(newIndexes: response, emptyItems: [])
                            })
                        }
                    } else if self.isPaginationDidEnd, self.isLocalPaginationOn {
                        self.compoundItems(pageItems: [], pageNum: 2, complition: { [weak self] response in
                            self?.batchInsertItems(newIndexes: response, emptyItems: [])
                        })
                    }
                    
//                    if !self.isPaginationDidEnd {
//                        self.delegate?.getNextItems()
//                    }
                    //////
                    
//                            }
//                        }
//                    })
                }
            }
        case .failed(_):
            delegate?.filesAppendedAndSorted()
            isLocalFilesRequested = false
        }
    }
    
    ///dunno if I need it
//    override func breakItemsIntoSections(breakingArray: [WrapData]) {
//        allItems.removeAll()
//
//        let needShowEmptyMetaDataItems = needShowEmptyMetaItems && (currentSortType == .metaDataTimeUp || currentSortType == .metaDataTimeDown)
//
//        for item in breakingArray {
//            autoreleasepool {
//                if !allItems.isEmpty,
//                    let lastItem = allItems.last?.last {
//                    switch currentSortType {
//                    case .timeUp, .timeDown:
//                        addByDate(lastItem: lastItem, newItem: item, isMetaDate: false)
//                    case .lettersAZ, .lettersZA, .albumlettersAZ, .albumlettersZA:
//                        addByName(lastItem: lastItem, newItem: item)
//                    case .sizeAZ, .sizeZA:
//                        addBySize(lastItem: lastItem, newItem: item)
//                    case .timeUpWithoutSection, .timeDownWithoutSection:
//                        allItems.append(contentsOf: [breakingArray])
//                        return
//                    case .metaDataTimeUp, .metaDataTimeDown:
//                        addByDate(lastItem: lastItem, newItem: item, isMetaDate: true)
//                    }
//                } else {
//                    allItems.append([item])
//                }
//            }
//        }
//        
//        if needShowEmptyMetaDataItems && !emptyMetaItems.isEmpty {
//            if currentSortType == .metaDataTimeUp {
//                allItems.append(emptyMetaItems)
//            } else if currentSortType == .metaDataTimeDown {
//                allItems.insert(emptyMetaItems, at: 0)
//            }
//        }
//    }
}
