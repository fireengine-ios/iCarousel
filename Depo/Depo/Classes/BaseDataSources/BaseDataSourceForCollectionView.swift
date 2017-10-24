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

class BaseDataSourceForCollectionView: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LBCellsDelegate, BasicCollectionMultiFileCellActionDelegate, UIScrollViewDelegate {
    
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
    
    var fetchService: FetchService!
    
    var originalFilters: [GeneralFilesFiltrationType]? //DO I NEED THIS?
    
    func setupCollectionView(collectionView: UICollectionView, filters: [GeneralFilesFiltrationType]?){

        originalFilters = filters
        
        self.collectionView = collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let headerNib = UINib(nibName: CollectionViewSuplementaryConstants.baseDataSourceForCollectionViewReuseID,
                              bundle: nil)
        collectionView.register(headerNib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: CollectionViewSuplementaryConstants.baseDataSourceForCollectionViewReuseID)
        
        let registreList = [CollectionViewCellsIdsConstant.cellForImage,
                            CollectionViewCellsIdsConstant.cellForStoryImage,
                            CollectionViewCellsIdsConstant.cellForVideo,
                            CollectionViewCellsIdsConstant.cellForAudio,
                            CollectionViewCellsIdsConstant.baseMultiFileCell,
                            CollectionViewCellsIdsConstant.audioSelectionCell,
                            CollectionViewCellsIdsConstant.baseMultiFileCell,
                            CollectionViewCellsIdsConstant.photosOrderCell,
                            CollectionViewCellsIdsConstant.folderSelectionCell]
        
        registreList.forEach {
            let listNib = UINib(nibName: $0, bundle: nil)
            collectionView.register(listNib, forCellWithReuseIdentifier: $0)
        }
        
        fetchService = FetchService(batchSize: 140, delegate: self)
        fetchService.performFetch(sortingRules: .timeUp, filtes: originalFilters, delegate: self)
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
            header.setSelectedState(selected: isHeaderSelected(section: header.tag), activateSelectionState: isSelectionStateActive && enableSelectionOnHeader)
        }
    }
    
    func getAllObjects() -> [[BaseDataSourceItem]]{
        var array = [[BaseDataSourceItem]]()
        let sections = fetchService.controller.sections
        let sectionsCount = sections?.count ?? 0
        for section in 0...sectionsCount - 1 {
            let rowCount = sections?[section].numberOfObjects ?? 0
            var subArray = [BaseDataSourceItem]()
            for row in 0...rowCount - 1 {
                let indexPath = IndexPath(row: row, section: section)
                if let obj = itemForIndexPath(indexPath: indexPath) {
                    subArray.append(obj)
                }
            }
            array.append(subArray)
        }
        return array
    }
    
    func selectAll(isTrue: Bool){
        if (isTrue) {
            let sections = fetchService.controller.sections
            let sectionsCount = sections?.count ?? 0
            for section in 0...sectionsCount - 1 {
                let rowCount = sections?[section].numberOfObjects ?? 0
                for row in 0...rowCount - 1 {
                    let indexPath = IndexPath(row: row, section: section)
                    if let obj = itemForIndexPath(indexPath: indexPath) {
                        selectedItemsArray.insert(obj.uuid)
                    }
                }
            }
        }else{
            selectedItemsArray.removeAll()
        }
    }
    
    func reloadData() {
        
        collectionView.reloadData()
        fetchService.controller.delegate = self
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
    
    
    //MARK: collectionViewDataSource
    
    internal func itemForIndexPath(indexPath: IndexPath) -> BaseDataSourceItem? {
        return fetchService.object(at: indexPath)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchService.controller.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchService.controller.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat{
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
        let selected = isObjctSelected(object: unwrapedObject)
        cell_.setSelection(isSelectionActive: isSelectionStateActive, isSelected: isObjctSelected(object: unwrapedObject))
        cell_.confireWithWrapperd(wrappedObj: unwrapedObject)
        cell_.setDelegateObject(delegateObject: self)
        
        guard let wraped = unwrapedObject as? Item else{
            return
        }
        
        fileDataSource.getImage(patch: wraped.patchToPreview) { [weak self] (image) in
            let contains = self?.collectionView.indexPathsForVisibleItems.contains(indexPath)
            if let value = contains,
               value == true {
                cell_.setImage(image: image)
                return
            }
        }
//        let countRow:Int = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
//        let isLastSection = Bool((numberOfSections(in: collectionView) - 1) == indexPath.section)
//        let isLastCell = Bool((countRow - 1) == indexPath.row)
//
//        if isLastCell &&
//            isLastSection {
//            self.delegate?.getNextItems()
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let unwrapedObject = itemForIndexPath(indexPath: indexPath) as? Item else {
            return
        }
        
        fileDataSource.cancelImgeRequest(path: unwrapedObject.patchToPreview)
        
        guard let cell_ = cell as? CollectionViewCellDataProtocol else {
            return
        }
        cell_.setImage(image: nil)
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
        if (!fetchService.needSeparateBySection()){
            h = 0
        }
        
        return CGSize(width: collectionView.contentSize.width, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewSuplementaryConstants.baseDataSourceForCollectionViewReuseID, for: indexPath)
           
            let textHeader = headerView as! CollectionViewSimpleHeaderWithText
            let title = fetchService.headerText(indexPath: indexPath)
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
            header.setSelectedState(selected: isHeaderSelected(section: header.tag), activateSelectionState: isSelectionStateActive && enableSelectionOnHeader)
        }
        
        updateSelectionCount()
    }
    
    func isHeaderSelected(section: Int) -> Bool{
        let array: [MediaItem] = fetchService.controller.sections?[section].objects as! [MediaItem]
        let result: [String] = array.flatMap { $0.wrapedObject.uuid }
        let subSet = Set<String>(result)
        
        return subSet.isSubset(of: selectedItemsArray) 
    }
    
    func selectSectionAt(section: Int){
        let array: [MediaItem] = fetchService.controller.sections?[section].objects as! [MediaItem]
        let objectsArray: [BaseDataSourceItem] = array.flatMap { $0.wrapedObject }
        
        if (isHeaderSelected(section: section)){
            for obj in objectsArray {
                selectedItemsArray.remove(obj.uuid)
            }
        }else{
            for obj in objectsArray {
                selectedItemsArray.insert(obj.uuid)
            }
        }
        
        let visibleCells = collectionView.visibleCells
        for cell in visibleCells {
            guard let cell_ = cell as? CollectionViewCellDataProtocol,
                  let indexPath = collectionView.indexPath(for: cell),
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
}
