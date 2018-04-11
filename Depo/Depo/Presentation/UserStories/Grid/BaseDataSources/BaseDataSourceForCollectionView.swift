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

@objc protocol BaseDataSourceForCollectionViewDelegate: class {
    
    func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]])
    
    func getCellSizeForGreed() -> CGSize
    
    func getCellSizeForList() -> CGSize
    
    func onLongPressInCell()
    
    func onChangeSelectedItemsCount(selectedItemsCount: Int)
    
    func onMaxSelectionExeption()
    
    func onMoreActions(ofItem: Item?, sender: Any)
    
    func getNextItems()
    
    func filesAppendedAndSorted()
    
    @objc optional func needReloadData()
    
    @objc optional func scrollViewDidScroll(scrollView: UIScrollView)
    
    @objc optional func didChangeSelection(state: Bool)
    
    @objc optional func updateCoverPhotoIfNeeded()
    
    @objc optional func didDelete(items: [BaseDataSourceItem])
    
    @objc optional func onItemSelectedActiveState(item: BaseDataSourceItem)

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
    
    var enableSelectionOnHeader = true
    
    var maxSelectionCount: Int = -1
    
    var canReselect: Bool = false
    
    var currentSortType: SortedRules = .timeUp

    var originalFilters: [GeneralFilesFiltrationType]?
    
    var isHeaderless = false
    
    private var isLocalPaginationOn = false // ---------------------=======
    private var isLocalFilesRequested = false // -----------------------=========
    
    var allMediaItems = [WrapData]()
    var allItems = [[WrapData]]()
    private var pageLeftOvers = [WrapData]()

    
    private var allRemoteItems = [WrapData]()
    private var uploadedObjectID = [String]()
    private var uploadToAlbumItems = [String]()
    
    var needShowProgressInCell: Bool = false
    var needShowCloudIcon: Bool = true
    var needShow3DotsInCell: Bool = true
    
    var parentUUID: String?
    
    let filesDataSource = FilesDataSource()
    
    fileprivate var previousPreheatRect = CGRect.zero
    
    private var sortingRules: SortedRules
    
    private let pageCompounder = PageCompounder()
    
    private let dispatchQueue = DispatchQueue(label: "com.lifebox.BaseDataSourceForCollectionView")
    
    init(sortingRules: SortedRules = .timeUp) {
        self.sortingRules = sortingRules
        super.init()
    }
    
    func appendCollectionView(items: [WrapData], pageNum: Int) {
        let nonEmptyMetaItems = items.filter {
            if $0.fileType == .image, !$0.isLocalItem {
                return ($0.metaData?.takenDate != nil)
            }
            return $0.metaData != nil
        }
        
        if nonEmptyMetaItems.isEmpty {
            isPaginationDidEnd = true
        }
        
        log.debug("BaseDataSourceForCollectionView appendCollectionView \(nonEmptyMetaItems.count)")
        
        let pageItems = transformedLeftOvers() + nonEmptyMetaItems
        
        allRemoteItems.append(contentsOf: nonEmptyMetaItems)
        
        self.pageLeftOvers.removeAll()
        
        compoundItems(pageItems: pageItems, pageNum: pageNum, originalRemotes: true, complition: { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
                self?.delegate?.filesAppendedAndSorted()
                self?.isLocalFilesRequested = false
            }
        })
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
    
    fileprivate func compoundItems(pageItems: [WrapData], pageNum: Int, originalRemotes: Bool = false, complition: @escaping VoidHandler) {
        
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                complition()
                return
            }
            
            guard let unwrapedFilters = self.originalFilters,
                let specificFilters = self.getFileFilterType(filters: unwrapedFilters),
                !self.showOnlyRemotes(filters: unwrapedFilters) else {
                    self.allMediaItems.append(contentsOf: pageItems)
                    self.breakItemsIntoSections(breakingArray: self.allMediaItems)
                    complition()
                    return
            }
            
            switch specificFilters {
            case .video, .image:
                guard !self.isLocalFilesRequested else {
                    return
                }
                
                self.isLocalFilesRequested = true
                self.isLocalPaginationOn = true
                
                if pageNum == 1, self.allMediaItems.isEmpty, self.pageLeftOvers.isEmpty {
                    self.pageCompounder.compoundFirstPage(pageItems: pageItems,
                                                          filesType: specificFilters,
                                                          sortType: self.currentSortType,
                                                          compoundedCallback:
                        { [weak self] (compoundedItems, lefovers) in
                            guard let `self` = self else {
                                return
                            }
                            
                            self.pageLeftOvers.removeAll()
                            self.pageLeftOvers.append(contentsOf: lefovers)
                            
                            //                            let sortedItems = self.sortByCurrentType(items: compoundedItems)
                            self.allMediaItems.append(contentsOf: compoundedItems)
                            
                            //                            if compoundedItems.count < self.pageCompounder.pageSize, !self.isPaginationDidEnd {
                            //                                self.delegate?.getNextItems()
                            //                                return
                            //                            }
                            self.isHeaderless ? self.setupOneSectionMediaItemsArray(items: self.allMediaItems) : self.breakItemsIntoSections(breakingArray: self.allMediaItems)
                            complition()
                            
                    })
                } else if self.isPaginationDidEnd {
                    //check lefovers here
                    let isEmptyLeftOvers = self.pageLeftOvers.filter{!$0.isLocalItem}.isEmpty
                    var itemsToCompound = isEmptyLeftOvers ? pageItems : self.transformedLeftOvers()
                    var needToDropFirstItem = false
                    if pageItems.isEmpty, isEmptyLeftOvers, let lastMediItem = self.allMediaItems.last {
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
                            
                            if compoundedItems.count < self.pageCompounder.pageSize, self.isPaginationDidEnd {
                                self.isLocalPaginationOn = false
                            }
                            
                            self.isHeaderless ? self.setupOneSectionMediaItemsArray(items: self.allMediaItems) : self.breakItemsIntoSections(breakingArray: self.allMediaItems)
                            complition()
                    })
                } else if !self.isPaginationDidEnd { ///Middle page
                    //check lefovers here
                    let isEmptyLeftOvers = self.pageLeftOvers.filter{!$0.isLocalItem}.isEmpty
                    let itemsToCompound = isEmptyLeftOvers ? pageItems : self.transformedLeftOvers()
                    if pageItems.isEmpty, isEmptyLeftOvers {
                        self.delegate?.getNextItems()
                        //DO I need callback here?
                        return
                    }
                    
                    self.pageCompounder.compoundMiddlePage(pageItems: itemsToCompound,
                                                           filesType: specificFilters,
                                                           sortType: self.currentSortType,
                                                           //                                                           notAllowedMD5: md5s,
                        //                                                           notAllowedLocalIDs: localIDs,
                        compoundedCallback:
                        { [weak self] (compoundedItems, lefovers) in
                            guard let `self` = self else {
                                return
                            }
                            self.pageLeftOvers.removeAll()
                            self.pageLeftOvers.append(contentsOf: lefovers)
                            
                            //                            let sortedItems = self.sortByCurrentType(items: compoundedItems)
                            self.allMediaItems.append(contentsOf: compoundedItems)
                            
                            //                            if compoundedItems.count < self.pageCompounder.pageSize, !self.isPaginationDidEnd {
                            //                                self.pageLeftOvers.append(contentsOf: compoundedItems)
                            //                                self.isLocalFilesRequested = false
                            //                                self.delegate?.getNextItems()
                            //                                return
                            //                            }
                            
                            self.isHeaderless ? self.setupOneSectionMediaItemsArray(items: self.allMediaItems) : self.breakItemsIntoSections(breakingArray: self.allMediaItems)
                            complition()
                    })
                }
                
            default:
                self.allMediaItems.append(contentsOf: pageItems)
                self.isHeaderless ? self.setupOneSectionMediaItemsArray(items: self.allMediaItems) : self.breakItemsIntoSections(breakingArray: self.allMediaItems)
                complition()
            }
            
        }
    }
    
    private func transformedLeftOvers() -> [WrapData] {
        /*guard let lastAppendedItem = allMediaItems.last else {
         return []
         }*/
        let pseudoPageArray = /*[lastAppendedItem] + */pageLeftOvers.filter{!$0.isLocalItem}
        return pseudoPageArray
    }
    
    private func setupOneSectionMediaItemsArray(items: [WrapData]) {
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
        for item in breakingArray {
            autoreleasepool {
                if allItems.count > 0,
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
        
        guard allItems.count > indexPath.section,
            allItems[indexPath.section].count > indexPath.row else {
                return headerText
        }
        
        switch currentSortType {
        case .timeUp, .timeUpWithoutSection, .timeDown, .timeDownWithoutSection:
            if let date = allItems[indexPath.section].first?.creationDate {
                headerText = date.getDateInTextForCollectionViewHeader()
            }
        case .lettersAZ, .albumlettersAZ, .lettersZA, .albumlettersZA:
            if let character = allItems[indexPath.section].first?.name?.first {
                headerText = String(describing: character).uppercased()
            }
        case .sizeAZ, .sizeZA:
            headerText = ""
        case .metaDataTimeUp, .metaDataTimeDown:
            if let date = allItems[indexPath.section].first?.metaData?.takenDate {
                headerText = date.getDateInTextForCollectionViewHeader()
            } else if let date = allItems[indexPath.section].first?.creationDate {
                headerText = date.getDateInTextForCollectionViewHeader()
            }
        }
        return headerText
    }
    
    private func facingPageEnd() {
        
    }
    
    func dropData() {
        log.debug("BaseDataSourceForCollectionViewDelegate dropData()")
        
        allRemoteItems.removeAll()
        allItems.removeAll()
        allMediaItems.removeAll()
        pageCompounder.dropData()
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
        if (!selectionState){
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
        
        delegate?.didChangeSelection?(state: isSelectionStateActive)
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
            for array in allItems{
                for object in array{
                    onSelectObject(object: object)
                }
            }
            updateVisibleCells()
            
        }else{
            selectedItemsArray.removeAll()
            updateVisibleCells()
            for header in headers{
                header.setSelectedState(selected: isHeaderSelected(section: header.selectionView.tag),
                                        activateSelectionState: isSelectionStateActive && enableSelectionOnHeader)
            }
            
            updateSelectionCount()
        }
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            log.debug("BaseDataSourceForCollectionViewDelegate reloadData")
            debugPrint("BaseDataSourceForCollectionViewDelegate reloadData")
            self.collectionView?.reloadData()
            self.resetCachedAssets()
        }
    }
    
    func updateDisplayngType(type: BaseDataSourceDisplayingType) {
        displayingType = type
        let firstVisibleIndexPath = collectionView?.indexPathsForVisibleItems.min(by: { first, second -> Bool in
            return first < second
        })
        debugPrint("Reload updateDisplayngType")
        collectionView?.reloadData()
        if let firstVisibleIndexPath = firstVisibleIndexPath{
            if firstVisibleIndexPath.row == 0, firstVisibleIndexPath.section == 0 {
                collectionView?.scrollToItem(at: firstVisibleIndexPath, at: .centeredVertically, animated: false)
            }else{
                collectionView?.scrollToItem(at: firstVisibleIndexPath, at: .top, animated: false)
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
                return
            }
            cell_.setSelection(isSelectionActive: isSelectionStateActive, isSelected: isObjctSelected(object: unwrapedObject))
            cell_.confireWithWrapperd(wrappedObj: unwrapedObject)
        }
    }
    
    @objc func onHeaderTap(_ sender: UITapGestureRecognizer){
        if (!enableSelectionOnHeader ||
            !isSelectionStateActive ) {
            return
        }
        
        let section = sender.view?.tag
        selectSectionAt(section: section!)
        let textHeader = sender.view?.superview as! CollectionViewSimpleHeaderWithText
        textHeader.setSelectedState(selected: isHeaderSelected(section: section!), activateSelectionState: isSelectionStateActive)
    }
    
    func morebuttonGotPressed(sender: Any, itemModel: Item?) {
        delegate?.onMoreActions(ofItem: itemModel, sender: sender)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll?(scrollView: scrollView)
        
        updateCachedAssets()
    }
    
    func isInSelectionMode() -> Bool {
        return isSelectionStateActive
    }
    
    //MARK: collectionViewDataSource
    
    func itemForIndexPath(indexPath: IndexPath) -> BaseDataSourceItem? {
        guard allItems.count > indexPath.section,
        allItems[indexPath.section].count > indexPath.row else {
            return nil
        }
        return allItems[indexPath.section][indexPath.row]
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
        
        if isLastCell, isLastSection, !isPaginationDidEnd {
            
            if pageLeftOvers.isEmpty, !isLocalFilesRequested {
                delegate?.getNextItems()
            } else if !pageLeftOvers.isEmpty, !isLocalFilesRequested {
                compoundItems(pageItems: [], pageNum: 2, complition: { [weak self] in
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                        self?.delegate?.filesAppendedAndSorted()
                        self?.isLocalFilesRequested = false
                    }
                    
                })
            }
            debugPrint("BaseDataSourceForCollectionViewDelegate isLastCell, isLastSection, !isPaginationDidEnd ")
        } else if isLastCell, isLastSection, isPaginationDidEnd, isLocalPaginationOn, !isLocalFilesRequested {
            compoundItems(pageItems: [], pageNum: 2, complition: { [weak self] in
                debugPrint("isLocalPaginationOn \(self?.isLocalPaginationOn)")
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                    self?.delegate?.filesAppendedAndSorted()
                    self?.isLocalFilesRequested = false
                }
            })
        }
        
        if let photoCell = cell_ as? CollectionViewCellForPhoto{
            let file = itemForIndexPath(indexPath: indexPath)
            if let `file` = file, uploadedObjectID.index(of: file.uuid) != nil{
                photoCell.finishedUploadForObject()
            }
        }
        
        if let cell = cell as? BasicCollectionMultiFileCell {
            cell.moreButton.isHidden = !needShow3DotsInCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell_ = cell as? CollectionViewCellDataProtocol else {
                return
        }
        
        if let photoCell = cell_ as? CollectionViewCellForPhoto {
            photoCell.finishedUploadForObject()
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
                forwardDelegate.onItemSelectedActiveState?(item: unwrapedObject)
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
    
    //-----
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if (Device.isIpad){
            return NumericConstants.iPadGreedHorizontalSpace
        } else {
            return NumericConstants.iPhoneGreedHorizontalSpace
        }
    }
    
    //|||||
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
        let h: CGFloat = isHeaderless ? 0 : 50
        return CGSize(width: collectionView.contentSize.width, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let isLastSection = (section == allItems.count - 1)
        
        let h: CGFloat// = (isPaginationDidEnd && !isLastSection) ? 0 : 50
        if !isLastSection || (isPaginationDidEnd && (!isLocalPaginationOn && !isLocalFilesRequested)) {
            h = 0
        } else
//            if isPaginationDidEnd || !isLocalPaginationOn {
//            h = 0
//        } else
            {
            h = 50
        }
        return CGSize(width: collectionView.contentSize.width, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewSuplementaryConstants.baseDataSourceForCollectionViewReuseID, for: indexPath)
            
            let textHeader = headerView as! CollectionViewSimpleHeaderWithText
            
            let title = getHeaderText(indexPath: indexPath)//fetchService.headerText(indexPath: indexPath)
            
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
    
    func getIndexPathForObject(objectUUID: String) -> IndexPath? {
        var indexPath: IndexPath? = nil
        let items = getAllObjects()
        
        for (section, array) in items.enumerated() {
            for (row, arraysObject) in array.enumerated() {
                if arraysObject.uuid == objectUUID {
                    indexPath = IndexPath(row: row, section: section)
                }
            }
        }
        return indexPath
    }
    
    func getCellForFile(objectUUID: String) -> CollectionViewCellForPhoto? {
        guard let path = getIndexPathForObject(objectUUID: objectUUID),
            let cell = collectionView?.cellForItem(at: path) as? CollectionViewCellForPhoto else {
                return nil
        }
        return cell
    }
    
    //Actualy those "new methods" wont needed if we just update Item model(UUID espetialy)
    
    func getIndexPathForLocalObject(objectUUID: String) -> IndexPath? {
        var indexPath: IndexPath? = nil
        let items = getAllObjects()
        
        for (section, array) in items.enumerated() {
            for (row, arraysObject) in array.enumerated() {
                if arraysObject.uuid == objectUUID, arraysObject.isLocalItem {
                    indexPath = IndexPath(row: row, section: section)
                }
            }
        }
        return indexPath
    }
    
    func getCellForLocalFile(objectUUID: String) -> CollectionViewCellForPhoto? {
        guard let path = getIndexPathForLocalObject(objectUUID: objectUUID),
            let cell = collectionView?.cellForItem(at: path) as? CollectionViewCellForPhoto else {
                return nil
        }
        return cell
    }
    //----
    
    func startUploadFile(file: WrapData) {
        guard needShowProgressInCell, file.isLocalItem else {
            return
        }
        
        if let cell = getCellForLocalFile(objectUUID: file.uuid) {
            cell.setProgressForObject(progress: 0, blurOn: true)
        }
    }
    
    func setProgressForUploadingFile(file: WrapData, progress: Float) {
        guard needShowProgressInCell, file.isLocalItem else {
            return
        }
        
        if let cell = getCellForLocalFile(objectUUID: file.uuid) {
            cell.setProgressForObject(progress: progress, blurOn: true)
        }
    }
    
    func finishedUploadFile(file: WrapData){
        if let unwrapedFilters = originalFilters,
            isAlbumDetail(filters: unwrapedFilters) {
            return
        }
        
        let uuid = file.uuid
//        file.isLocalItem = false
        if uploadedObjectID.index(of: file.uuid) == nil {
            uploadedObjectID.append(uuid)
        }
        
        var localFinishedItemUUID: String?
        
        finished: for (section, array) in allItems.enumerated() {
            for (row, object) in array.enumerated() {
                if object.uuid == uuid {
                    if object.isLocalItem {
                        localFinishedItemUUID = object.uuid
                        file.isLocalItem = false
                    }
                    allItems[section][row] = file
                    break finished
                }
            }
        }
        
        
        for (index, object) in allMediaItems.enumerated(){
            if object.uuid == file.uuid {
                file.isLocalItem = false
                allMediaItems[index] = file
            }
        }
        
        if !needShowProgressInCell{
            //delegate?.needReloadData?()
            return
        }
        
        if localFinishedItemUUID != nil, let cell = getCellForFile(objectUUID: file.uuid) {
            cell.finishedUploadForObject()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: { [weak self] in
            if let `self` = self{
                let cell = self.getCellForFile(objectUUID: uuid)
                cell?.resetCloudImage()
                
                if let index = self.uploadedObjectID.index(of: uuid){
                    self.uploadedObjectID.remove(at: index)
                }
            }
        })
        
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
        var arrayOfPath = [IndexPath]()
        
        for item in items {
            if let path = getIndexPathForObject(objectUUID: item.uuid) {
                arrayOfPath.append(path)
            }
        }
        
        if arrayOfPath.count > 0 {
            var uuids = items.map { $0.uuid }
            guard let items = getAllObjects() as? [[Item]] else {
                return
            }
            for array in items {
                for arraysObject in array {
                    if let index = uuids.index(of: arraysObject.uuid) {
                        arraysObject.favorites = isFavorites
                        uuids.remove(at: index)
                    }
                }
            }
            
            collectionView?.performBatchUpdates({ [weak self] in
                if let `self` = self{
                    self.collectionView?.reloadItems(at: arrayOfPath)
                }
                }, completion: nil)
        }
    }
    
    func addFilesToFavorites(items: [Item]){
        if let unwrapedFilters = originalFilters, isFavoritesOnly(filters: unwrapedFilters) {
            delegate?.needReloadData?()
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
        guard !items.isEmpty else {
            return
        }

        var objectsForRemoving = [Item]()
        var localObjectsForReplace = [Item]()
        
        if let unwrapedFilters = originalFilters,
            !showOnlyRemotes(filters: unwrapedFilters) {
            
            var serverObjects = [Item]()
            
            for object in items {
                if object.isLocalItem {
                    objectsForRemoving.append(object)
                } else {
                    serverObjects.append(object)
                }
            }
            
            var serversUUIDs = [String]()
            let items = getAllObjects()
            for array in items {
                for arraysObject in array {
                    if !arraysObject.isLocalItem {
                        serversUUIDs.append(arraysObject.uuid)
                    }
                }
            }
            objectsForRemoving = objectsForRemoving.filter({
                return !serversUUIDs.contains($0.uuid)
            })
        
            let localUUIDS = serverObjects.map {
                $0.getUUIDAsLocal()
            }
            
            localObjectsForReplace = CoreDataStack.default.allLocalItems(withUUIDS: localUUIDS)

            let uuids = localObjectsForReplace.map({ $0.uuid })
            
            if (localObjectsForReplace.count != serverObjects.count) {
                for object in serverObjects {
                    if !uuids.contains(object.getUUIDAsLocal()) {
                        objectsForRemoving.append(object)
                    }
                }
            }
            
            for object in localObjectsForReplace {
                if let index = serversUUIDs.index(of: object.getUUIDAsLocal()) {
                    serversUUIDs.remove(at: index)
                }
            }
            
            for localObject in localObjectsForReplace {
                for (index, object) in allMediaItems.enumerated() {
                    if object.uuid == localObject.getUUIDAsLocal() {
                        allMediaItems[index] = localObject
                    }
                }
            }
            
            if (localObjectsForReplace.count > 0) {
                var newArray = [[BaseDataSourceItem]]()
                let items = getAllObjects()
                for array in items {
                    var sectionArray = [BaseDataSourceItem]()
                    for arraysObject in array {
                        if let index = uuids.index(of: arraysObject.getUUIDAsLocal()) {
                            sectionArray.append(localObjectsForReplace[index])
                        } else {
                            sectionArray.append(arraysObject)
                        }
                    }
                    newArray.append(sectionArray)
                }
                
                setAllItems(items: newArray)
            }
        }else {
            objectsForRemoving = items
        }
        
        updateCellsForObjects(objectsForDelete: objectsForRemoving, objectsForUpdate: localObjectsForReplace)
        
        delegate?.didDelete?(items: items)
    }
    
    private func updateCellsForObjects(objectsForDelete: [BaseDataSourceItem], objectsForUpdate:[BaseDataSourceItem]) {
        if objectsForDelete.isEmpty && objectsForUpdate.isEmpty {
            return
        }
        
        var arrayOfPathForDelete = [IndexPath]()
        var arrayOfPathForUpdate = [IndexPath]()
        var arrayOfSection = [Int]()
        
        for item in objectsForDelete {
            if let path = getIndexPathForObject(objectUUID: item.uuid) {
                arrayOfPathForDelete.append(path)
            }
        }
        
        if arrayOfPathForDelete.count > 0{
            var newArray = [[BaseDataSourceItem]]()
            var uuids = objectsForDelete.map { $0.uuid }
            
            var section = 0
            let items = getAllObjects()
            for array in items {
                var newSectionArray = [BaseDataSourceItem]()
                for arraysObject in array {
                    if let index = uuids.index(of: arraysObject.uuid) {
                        uuids.remove(at: index)
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
            if let path = getIndexPathForObject(objectUUID: item.uuid) {
                arrayOfPathForUpdate.append(path)
            }
        }
        
        /////
        if isPaginationDidEnd {
            debugPrint("LastPage Reload updateCellsForObjects")
        }
        debugPrint("Reload updateCellsForObjects")
        collectionView?.reloadData()
        
//        collectionView.performBatchUpdates({[weak self] in
//            if let `self` = self{
//                self.collectionView.deleteItems(at: arrayOfPathForDelete)
//                self.collectionView.deleteSections(IndexSet(arrayOfSection))
//            }
//        }) { [weak self] (flag) in
//            if let `self` = self{
//                self.collectionView.reloadItems(at: arrayOfPathForUpdate)
//            }
//        }
    }
    
    func newFolderCreated(){
        if let unwrapedFilters = originalFilters,
            canShowFolderFilters(filters: unwrapedFilters) {
            delegate?.needReloadData?()
        }
    }
    
    func newAlbumCreated(){
        if let unwrapedFilters = originalFilters,
            canShowAlbumsFilters(filters: unwrapedFilters) {
            delegate?.needReloadData?()
        }
    }
    
    func newStoryCreated() {
        
    }
    
    func updatedAlbumCoverPhoto(item: BaseDataSourceItem) {
        updateCellsForObjects(objectsForDelete: [BaseDataSourceItem](), objectsForUpdate: [item])
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
            delegate?.needReloadData?()
            updateCoverPhoto()
        }
    }
    
    func filesAddedToAlbum() {
        if let unwrapedFilters = originalFilters,
            isAlbumDetail(filters: unwrapedFilters) {
            delegate?.needReloadData?()
        }
        updateCoverPhoto()
    }
    
    func filesUploadToFolder() {
        if let unwrapedFilters = originalFilters,
            canUploadFromLifeBox(filters: unwrapedFilters) {
            delegate?.needReloadData?()
        }
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
    
    func filesMoved(items: [Item], toFolder folderUUID: String){
        if let uuid = parentUUID, uuid != folderUUID{
            deleteItems(items: items)
        }else if let unwrapedFilters = originalFilters,
            canShowFolderFilters(filters: unwrapedFilters) {
            deleteItems(items: items)
        }
    }
    
    func syncFinished() {
        if isLocalOnly(){
            return
        }
        if let unwrapedFilters = originalFilters  {
            if isFavoritesOnly(filters: unwrapedFilters) || isAlbumDetail(filters: unwrapedFilters){
                return
            }
        }
        
        if !needShowProgressInCell{
            delegate?.needReloadData?()
        }
    }
    
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        if let compairedView = object as? BaseDataSourceForCollectionView {
            return compairedView == self
        }
        return false
    }
    
    func updateCoverPhoto() {
        delegate?.updateCoverPhotoIfNeeded?()
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
            allItems.count > 0
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
