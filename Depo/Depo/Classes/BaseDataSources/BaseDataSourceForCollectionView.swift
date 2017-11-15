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
    
    @objc optional func scrollViewDidScroll(scrollView: UIScrollView)
}

class BaseDataSourceForCollectionView: NSObject, LBCellsDelegate, BasicCollectionMultiFileCellActionDelegate, UIScrollViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var isPaginationDidEnd = false
    
    internal weak var collectionView: UICollectionView!
    
    var displayingType: BaseDataSourceDisplayingType = .greed
    
    weak var delegate: BaseDataSourceForCollectionViewDelegate?
    
    internal var preferedCellReUseID: String?
    
    private var fileDataSource =  FilesDataSource()
    
    private var isSelectionStateActive = false
    
    var selectedItemsArray = Set<String>()
    
    private var headers = Set([CollectionViewSimpleHeaderWithText]())
    
    var enableSelectionOnHeader = true
    
    var maxSelectionCount: Int = -1
    
    var canReselect: Bool = false
    
    var currentSortType: SortedRules = .timeUp
    
    var originalFilters: [GeneralFilesFiltrationType]?
    
    var allFolders = [WrapData]()
    var allMediaItems = [WrapData]()
    var allItems = [[WrapData]]()
    var allLocalItems = [WrapData]()
    
    private func compoundItems(appendedItems: [WrapData]) {
        allMediaItems.append(contentsOf: appendedItems)
        var allItemsWithLocals = allMediaItems

        
         allItemsWithLocals = appendLocalItems(originalItemsArray: allMediaItems)
        breakItemsIntoSections(breakingArray: allItemsWithLocals)
//        allFolders.append(appendedItems.filter{$0})
    }
    
    private func breakItemsIntoSections(breakingArray: [WrapData]){
        debugPrint("new array count is ",breakingArray.count)
        allItems.removeAll()
        for item in breakingArray {
            autoreleasepool {
                if allItems.count > 0,
                    let lastItem = allItems.last?.last {
                    switch currentSortType {
                    case .timeUp, .timeDown:
                        addByDate(lastItem: lastItem, newItem: item)
                    case .lettersAZ, .lettersZA, .albumlettersAZ, .albumlettersZA:
                        addByName(lastItem: lastItem, newItem: item)
                    case .sizeAZ, .sizeZA:
                        addBySize(lastItem: lastItem, newItem: item)
                    case .timeUpWithoutSection, .timeDownWithoutSection:
                        allItems.append(contentsOf: [breakingArray])
                        return
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
    
    private func appendLocalItems(originalItemsArray: [WrapData]) -> [WrapData] {
        var tempoArray = [WrapData]()
        var tempoLocalArray = [WrapData]()
        
        if let unwrapedFilters = originalFilters, let specificFilters = getFileFilterType(filters: unwrapedFilters) {
            switch specificFilters {
            case .video:
                tempoLocalArray = allLocalItems.filter{$0.fileType == .video}
            case .image:
                tempoLocalArray = allLocalItems.filter{$0.fileType == .image}
            default:
                break
            }
        }
        if tempoLocalArray.count == 0 {
            return originalItemsArray
        }

        var remoteItemsMD5List = tempoArray.map{return $0.md5}
        for remoteItem in originalItemsArray {
            for localItem in tempoLocalArray {
                guard !remoteItemsMD5List.contains(localItem.md5) else {
                    break
                }
                tempoArray.append(localItem)
                remoteItemsMD5List.append(localItem.md5)
            }
            
            tempoArray.append(remoteItem)
        }
        
            switch currentSortType {
            case .timeUp, .timeUpWithoutSection:
                tempoArray.sort{$0.creationDate! > $1.creationDate!}
            case .timeDown, .timeDownWithoutSection:
                tempoArray.sort{$0.creationDate! < $1.creationDate!}
            case .lettersAZ, .albumlettersAZ:
                tempoArray.sort{$0.name!.first! > $1.name!.first!}
            case .lettersZA, .albumlettersZA:
                tempoArray.sort{$0.name!.first! < $1.name!.first!}
            case .sizeAZ:
                tempoArray.sort{$0.fileSize > $1.fileSize}
            case .sizeZA:
                tempoArray.sort{$0.fileSize < $1.fileSize}
        }
            
        return tempoArray
    }
    
    private func addByDate(lastItem: WrapData, newItem: WrapData) {
        if let lastItemCreatedDate = lastItem.creationDate,
            let newItemCreationDate = newItem.creationDate {
            if lastItemCreatedDate.getYear() == newItemCreationDate.getYear(),
                lastItemCreatedDate.getMonth() == newItemCreationDate.getMonth() {
                debugPrint("item appended to SECTION ", allItems.count - 1)
                allItems[allItems.count - 1].append(newItem)
                
            } else {
                allItems.append([newItem])
            }
        } else {
            allItems.append([newItem])
        }
        
    }
    
    private func addByName(lastItem: WrapData, newItem: WrapData) {
        if let lastItemName = lastItem.name, let newItemName = newItem.name {
            if lastItemName.first == newItemName.first {
                allItems[allItems.count - 1].append(newItem)
            } else {
                allItems.append([newItem])
            }
            debugPrint("item appended to SECTION ", allItems.count - 1)
            
        } else {
            allItems.append([newItem])
        }
    }
    
    private func addBySize(lastItem: WrapData, newItem: WrapData) {
        allItems[allItems.count-1].append(newItem)
    }
    
    private func getHeaderText(indexPath: IndexPath) -> String {
        
        return "TESTO"
    }
    
    func getAllLocalItems() -> [WrapData] {
        let fetchRequest = NSFetchRequest<MediaItem>(entityName: "MediaItem")
        let predicate = PredicateRules().predicate(filters: [.localStatus(.local)])
        let sortDescriptors = CollectionSortingRules(sortingRules: currentSortType).rule.sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        guard let fetchResult = try? CoreDataStack.default.mainContext.fetch(fetchRequest) else {
            return []
        }
        return fetchResult.map{ return WrapData(mediaItem: $0) }
    }
    
    func appendCollectionView(items: [WrapData]) {
        compoundItems(appendedItems: items)
        //TODO: Append local items also here
//        reloadData()
    }
    
    func dropData() {
        allLocalItems.removeAll()
        allItems.removeAll()
        allMediaItems.removeAll()
        allFolders.removeAll()
        
        allLocalItems.append(contentsOf: getAllLocalItems())
        reloadData()
    }
    
    private var sortingRules: SortedRules
    
    init(sortingRules: SortedRules = .timeUp) {
        self.sortingRules = sortingRules
        super.init()
    }
    
    func setupCollectionView(collectionView: UICollectionView, filters: [GeneralFilesFiltrationType]?){
        
        originalFilters = filters
        
        self.collectionView = collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        
        allLocalItems.append(contentsOf: getAllLocalItems())
        
        registerHeaders()
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
                            CollectionViewCellsIdsConstant.albumCell]
        
        registreList.forEach {
            let listNib = UINib(nibName: $0, bundle: nil)
            collectionView.register(listNib, forCellWithReuseIdentifier: $0)
        }

    }
    
    private func registerHeaders() {
        let headerNib = UINib(nibName: CollectionViewSuplementaryConstants.baseDataSourceForCollectionViewReuseID,
                              bundle: nil)
        collectionView.register(headerNib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: CollectionViewSuplementaryConstants.baseDataSourceForCollectionViewReuseID)

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
        let array = collectionView.visibleCells
        for cell in array {
            guard let cell_ = cell as? CollectionViewCellDataProtocol else{
                continue
            }
            
            let indexPath = collectionView.indexPath(for: cell)
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
        
        for header in headers{
            header.setSelectedState(selected: isHeaderSelected(section: header.selectionView.tag), activateSelectionState: isSelectionStateActive && enableSelectionOnHeader)
        }
    }
    
    func getAllObjects() -> [[BaseDataSourceItem]]{
        var array = [[BaseDataSourceItem]]()
//        let sections = fetchService.controller.sections
//        let sectionsCount = sections?.count ?? 0
//        for section in 0...sectionsCount - 1 {
//            let rowCount = sections?[section].numberOfObjects ?? 0
//            var subArray = [BaseDataSourceItem]()
//            for row in 0...rowCount - 1 {
//                let indexPath = IndexPath(row: row, section: section)
//                if let obj = itemForIndexPath(indexPath: indexPath) {
//                    subArray.append(obj)
//                }
//            }
//            array.append(subArray)
//        }
        return array
    }
    
    func selectAll(isTrue: Bool){
        if (isTrue) {
//            let sections = fetchService.controller.sections
//            let sectionsCount = sections?.count ?? 0
//            for section in 0...sectionsCount - 1 {
//                let rowCount = sections?[section].numberOfObjects ?? 0
//                for row in 0...rowCount - 1 {
//                    let indexPath = IndexPath(row: row, section: section)
//                    if let obj = itemForIndexPath(indexPath: indexPath) {
//                        selectedItemsArray.insert(obj.uuid)
//                    }
//                }
//            }
        }else{
            selectedItemsArray.removeAll()
        }
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func updateDisplayngType(type: BaseDataSourceDisplayingType){
        displayingType = type
        collectionView.reloadData()
    }
    
    func getSelectedItems() -> [BaseDataSourceItem] {
        let array = CoreDataStack.default.mediaItemByUUIDs(uuidList: Array(selectedItemsArray))
        return array
    }
    
    
    //MARK: LBCellsDelegate
    
    func onLongPress(cell: UICollectionViewCell){
        if  let forwardDelegate = self.delegate,
            let path = collectionView.indexPath(for: cell),
            let object = itemForIndexPath(indexPath: path) {
            
            onSelectObject(object: object)
            forwardDelegate.onLongPressInCell()
        }
    }
    
    
    
    //MARK: selection
    
    func updateSelectionCount(){
        self.delegate?.onChangeSelectedItemsCount(selectedItemsCount: selectedItemsArray.count)
    }
    
    func isObjctSelected(object: BaseDataSourceItem) -> Bool {
        return selectedItemsArray.contains(object.uuid)
    }
    
    func onSelectObject(object: BaseDataSourceItem){
        if (isObjctSelected(object: object)){
            selectedItemsArray.remove(object.uuid)
        }else{
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
            selectedItemsArray.insert(object.uuid)
        }
        
        for header in headers{
            header.setSelectedState(selected: isHeaderSelected(section: header.selectionView.tag),
                                    activateSelectionState: isSelectionStateActive && enableSelectionOnHeader)
        }
        
        updateSelectionCount()
    }
    
    func isHeaderSelected(section: Int) -> Bool {
//        guard let unwrapedSections = fetchService.controller.sections,
//            section < unwrapedSections.count else {
//                return false
//        }
//        let array: [MediaItem] = unwrapedSections[section].objects as! [MediaItem]
//        let result: [String] = array.flatMap { $0.wrapedObject.uuid }
//        let subSet = Set<String>(result)
//
//        return subSet.isSubset(of: selectedItemsArray)
        return false
        
    }
    
    func selectSectionAt(section: Int){
//        let array: [MediaItem] = fetchService.controller.sections?[section].objects as! [MediaItem]
//        let objectsArray: [BaseDataSourceItem] = array.flatMap { $0.wrapedObject }
//
//        if (isHeaderSelected(section: section)){
//            for obj in objectsArray {
//                selectedItemsArray.remove(obj.uuid)
//            }
//        }else{
//            for obj in objectsArray {
//                selectedItemsArray.insert(obj.uuid)
//            }
//        }
//
//        let visibleCells = collectionView.visibleCells
//        for cell in visibleCells {
//            guard let cell_ = cell as? CollectionViewCellDataProtocol,
//                let indexPath = collectionView.indexPath(for: cell),
//                (indexPath.section == section),
//                let object = itemForIndexPath(indexPath: indexPath)
//                else{
//                    continue
//            }
//
//            cell_.setSelection(isSelectionActive: isSelectionStateActive,
//                               isSelected: isObjctSelected(object: object))
//            cell_.confireWithWrapperd(wrappedObj: object)
//
//        }
//        if isSelectionStateActive {
//            delegate?.onChangeSelectedItemsCount(selectedItemsCount: self.selectedItemsArray.count)
//        }
    }
    
    func updateVisibleCells(){
        let array = collectionView.visibleCells
        for cell in array {
            guard let cell_ = cell as? CollectionViewCellDataProtocol else{
                continue
            }
            
            let indexPath = collectionView.indexPath(for: cell)
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
    }
    
    func isInSelectionMode() -> Bool {
        return isSelectionStateActive
    }
    
    //MARK: collectionViewDataSource
    
    func itemForIndexPath(indexPath: IndexPath) -> BaseDataSourceItem? {
        guard allItems.count > 0 else {
            return nil
        }
        return allItems[indexPath.section][indexPath.row]//fetchService.object(at: indexPath)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return allItems.count//fetchService.controller.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < allItems.count else {
            return 0
        }
        
        return allItems[section].count//fetchService.controller.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat {
        return 50
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReUseID!,
                                                      for: indexPath)
        return  cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let unwrapedObject = itemForIndexPath(indexPath: indexPath),
            let cell_ = cell as? CollectionViewCellDataProtocol else {
                return
        }
        
        cell_.updating()
        //let selected = isObjctSelected(object: unwrapedObject)
        cell_.setSelection(isSelectionActive: isSelectionStateActive, isSelected: isObjctSelected(object: unwrapedObject))
        cell_.confireWithWrapperd(wrappedObj: unwrapedObject)
        cell_.setDelegateObject(delegateObject: self)
        
        guard let wraped = unwrapedObject as? Item else{
            return
        }
        
        cell_.setImage(with: wraped.patchToPreview)
        
//        fileDataSource.getImage(patch: wraped.patchToPreview) { image in
//            let contains = self.collectionView?.indexPathsForVisibleItems.contains(indexPath)
//            if contains == true {
//                cell_.setImage(image: image)
//                return
//            }
//        }
        let countRow:Int = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        let isLastSection = Bool((numberOfSections(in: collectionView) - 1) == indexPath.section)
        let isLastCell = Bool((countRow - 1) == indexPath.row)
        
        if isLastCell, isLastSection, !isPaginationDidEnd {
            self.delegate?.getNextItems()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let unwrapedObject = itemForIndexPath(indexPath: indexPath) as? Item else {
            return
        }
        
//        fileDataSource.cancelImgeRequest(path: unwrapedObject.patchToPreview)
        
        guard let cell_ = cell as? CollectionViewCellDataProtocol else {
            return
        }
//        cell_.setImage(image: nil)
        cell_.setSelection(isSelectionActive: isSelectionStateActive,
                           isSelected: isObjctSelected(object: unwrapedObject))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let object = itemForIndexPath(indexPath: indexPath)
        guard let unwrapedObject = object else {
            return
        }
        if (isSelectionStateActive){
            onSelectObject(object: unwrapedObject)
            let cell = collectionView.cellForItem(at: indexPath)
            guard let cell_ = cell as? CollectionViewCellDataProtocol else {
                return
            }
            cell_.setSelection(isSelectionActive: isSelectionStateActive, isSelected: isObjctSelected(object: unwrapedObject))
        }else{
            if  let forwardDelegate = self.delegate {
                let object = itemForIndexPath(indexPath: indexPath)
                guard let unwrapedObject = object else {
                    return
                }
                
                let array = getAllObjects()
                for subArray in array {
                    for obj in subArray{
                        if (obj.uuid == unwrapedObject.uuid){
                            forwardDelegate.onItemSelected(item: obj, from: array)
                            return
                        }
                    }
                }
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
            return 5.0
        }else{
            return 5.0
        }
    }
    
    //|||||
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if (Device.isIpad){
            return 5.0
        }else{
            return 3.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var h: CGFloat = 50
        //        if (!fetchService.needSeparateBySection()){
        //            h = 0
        //        }
        
        return CGSize(width: collectionView.contentSize.width, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewSuplementaryConstants.baseDataSourceForCollectionViewReuseID, for: indexPath)
            
            let textHeader = headerView as! CollectionViewSimpleHeaderWithText

            let title = "TEST HEADER"//fetchService.headerText(indexPath: indexPath)

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
            
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }
}
