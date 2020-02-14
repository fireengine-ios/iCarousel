//
//  TrashBinDataSource.swift
//  Depo
//
//  Created by Andrei Novikau on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol TrashBinDataSourceDelegate: class {
    func needLoadNextItemsPage()
    func needLoadNextAlbumPage()
    func didSelect(item: Item)
    func didSelect(album: BaseDataSourceItem)
    func onStartSelection()
    func didChangeSelectedItems(count: Int)
    func onMoreButtonTapped(sender: Any, item: Item)
}

final class TrashBinDataSource: NSObject {
    
    private typealias InsertItemResult = (indexPath: IndexPath?, section: Int?)
    private typealias ChangesItemResult = (indexPaths: [IndexPath], sections: IndexSet)
    
    private let linePadding = Device.isIpad ? NumericConstants.iPadGreedHorizontalSpace : NumericConstants.iPhoneGreedHorizontalSpace
    private let columnPadding = Device.isIpad ? NumericConstants.iPadGreedInset : NumericConstants.iPhoneGreedInset
    private let columns = Device.isIpad ? NumericConstants.numerCellInDocumentLineOnIpad : NumericConstants.numerCellInDocumentLineOnIphone
    
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.baseFilesGreedCollectionDataSource)
    
    private let collectionView: UICollectionView
    private weak var delegate: TrashBinDataSourceDelegate?
    private var albumSlider: AlbumsSliderCell?
    
    private(set) var allItems = [[Item]]()
    private var selectedItems = [Item]()
    
    private var showGroups: Bool {
        return sortedRule.isContained(in: [.lettersAZ, .lettersZA, .timeUp, .timeDown])
    }
    
    var sortedRule: SortedRules = .timeUp
    var viewType: MoreActionsConfig.ViewType = .List {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private(set) var isSelectionStateActive = false
    private var isPaginationDidEnd = false
    
    private let filesDataSource = FilesDataSource()
    
    var isEmpty: Bool {
        let albumsEmpty = albumSlider?.isEmpty ?? true
        return itemsIsEmpty && albumsEmpty
    }
    
    var itemsIsEmpty: Bool {
        return allItems.first(where: { !$0.isEmpty }) == nil
    }
    
    private lazy var cellGridSize: CGSize = {
        let viewWidth = UIScreen.main.bounds.width
        let paddingWidth = (columns + 1) * columnPadding
        let itemWidth = floor((viewWidth - paddingWidth) / columns)
        return CGSize(width: itemWidth, height: itemWidth)
    }()
    
    private lazy var cellListSize: CGSize = {
        return CGSize(width: UIScreen.main.bounds.width, height: 65)
    }()
    
    var allSelectedItems: [BaseDataSourceItem] {
        return selectedItems + (albumSlider?.selectedItems ?? [])
    }
    
    //MARK: - Init
    
    required init(collectionView: UICollectionView, delegate: TrashBinDataSourceDelegate?) {
        self.collectionView = collectionView
        self.delegate = delegate
        
        super.init()
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        registerCells()
        collectionView.register(nibSupplementaryView: CollectionViewSimpleHeaderWithText.self, kind: UICollectionElementKindSectionHeader)
        collectionView.allowsMultipleSelection = true
        collectionView.alwaysBounceVertical = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = columnPadding
            layout.minimumLineSpacing = linePadding
        }
    }
    
    private func registerCells() {
        let registreList = [AlbumsSliderCell.self,
                            BasicCollectionMultiFileCell.self]
        
        registreList.forEach { collectionView.register(nibCell: $0) }
    }
}

//MARK: - Public methods

extension TrashBinDataSource {
    
    func append(albums: [BaseDataSourceItem]) {
        albumSlider?.appendItems(albums)
    }
    
    func finishLoadAlbums() {
        albumSlider?.finishLoadAlbums()
    }
    
    func append(items: [Item], completion: @escaping VoidHandler) {
        if items.isEmpty {
            isPaginationDidEnd = true
        }
        
        dispatchQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            let isEmpty = self.itemsIsEmpty
            let insertResult = self.append(newItems: items)
            guard !insertResult.indexPaths.isEmpty else {
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
            
            DispatchQueue.main.async {
                if isEmpty {
                    self.collectionView.reloadData()
                    completion()
                } else {
                    self.collectionView.performBatchUpdates({
                        if !insertResult.sections.isEmpty {
                            self.collectionView.insertSections(insertResult.sections)
                        }
                        self.collectionView.insertItems(at: insertResult.indexPaths)
                    }, completion: { _ in
                        completion()
                    })
                }
            }
        }
    }
    
    func remove(items: [Item], completion: @escaping VoidHandler) {
        dispatchQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            if let parentUUID = items.first(where: { $0.parent != nil })?.parent {
                self.updateItems(count: items.count, forFolder: parentUUID, increment: false)
            }

            let deleteResult = self.delete(items: items)
            guard !deleteResult.indexPaths.isEmpty else {
                DispatchQueue.main.async {
                    completion()
                }
                return
            }

            DispatchQueue.main.async {
                if self.itemsIsEmpty {
                    self.collectionView.reloadData()
                    completion()
                } else {
                    self.collectionView.performBatchUpdates({
                        self.collectionView.deleteItems(at: deleteResult.indexPaths)
                        if !deleteResult.sections.isEmpty {
                            self.collectionView.deleteSections(deleteResult.sections)
                        }
                    }, completion: {_ in
                        completion()
                    })
                }
            }
        }
    }
    
    func updateItem(_ item: Item) {
        guard let indexPath = indexPath(for: item.uuid) else {
            return
        }
        
        allItems[indexPath.section - 1][indexPath.row] = item
        collectionView.reloadItems(at: [indexPath])
    }
    
    func removeSlider(items: [BaseDataSourceItem], completion: VoidHandler? = nil) {
        albumSlider?.removeItems(items, completion: completion)
    }
    
    func reset() {
        itemsReset()
        albumSliderReset()
    }
    
    func itemsReset() {
        allItems.removeAll()
        selectedItems.removeAll()
        isPaginationDidEnd = false
        collectionView.reloadData()
    }
    
    func albumSliderReset() {
        albumSlider?.reset()
    }
    
    func startSelection(indexPath: IndexPath? = nil) {
        isSelectionStateActive = true
        updateVisibleCells()
        
        delegate?.onStartSelection()
        
        if let indexPath = indexPath, let item = item(for: indexPath) {
            selectedItems.append(item)
            collectionView.reloadItems(at: [indexPath])
            updateSelectionCount()
        }
        
        if albumSlider?.isSelectionActive == false {
            albumSlider?.startSelection()
        }
    }
    
    func cancelSelection() {
        isSelectionStateActive = false
        selectedItems.removeAll()
        albumSlider?.stopSelection()
        updateVisibleCells()
    }
    
    func getSameTypeItems(for fileType: FileType, from items: [Item]) -> [Item] {
        if fileType.isDocument {
            return items.filter { $0.fileType.isDocument }
        } else if fileType == .video || fileType == .image {
            return items.filter { $0.fileType == .video || $0.fileType == .image }
        }
        return items.filter { $0.fileType == fileType }
    }
    
    private func updateVisibleCells() {
        collectionView.visibleCells.compactMap { $0 as? BasicCollectionMultiFileCell }.forEach {
            $0.setSelection(isSelectionActive: isSelectionStateActive, isSelected: false)
        }
    }
    
    private func updateSelectionCount() {
        delegate?.didChangeSelectedItems(count: allSelectedItems.count)
    }
}

//MARK: - Data processing

extension TrashBinDataSource {
    
    private func item(for indexPath: IndexPath) -> Item? {
        guard allItems.count > indexPath.section - 1, allItems[indexPath.section - 1].count > indexPath.row else {
            return nil
        }
        return allItems[safe: indexPath.section - 1]?[safe: indexPath.row]
    }
    
    private func indexPath(for uuid: String) -> IndexPath? {
        for (section, items) in allItems.enumerated() {
            if let row = items.firstIndex(where: { $0.uuid == uuid }) {
                return IndexPath(row: row, section: section + 1)
            }
        }
        return nil
    }
    
    private func headerText(for item: Item) -> String {
        switch sortedRule {
        case .timeUp, .timeDown:
            return item.creationDate?.getDateInTextForCollectionViewHeader() ?? ""
        case .lettersAZ, .lettersZA:
            return item.name?.firstLetter ?? ""
        default:
            assertionFailure()
            return ""
        }
    }
    
    private func headerText(indexPath: IndexPath) -> String {
        guard let itemsInSection = allItems[safe: indexPath.section - 1], let item = itemsInSection.first else {
            assertionFailure()
            return ""
        }
        return headerText(for: item)
    }
    
    private func append(newItems: [Item]) -> ChangesItemResult {
        var insertedIndexPaths = [IndexPath]()
        var insertedSections = IndexSet()
        
        let allMedia = allItems.flatMap { $0 }
        let insertItems = newItems.filter { !allMedia.contains($0) }
        
        for item in insertItems {
            autoreleasepool {
                let insertResult: InsertItemResult?
                if !itemsIsEmpty,
                    let lastItem = allItems.last?.last {
                    switch sortedRule {
                    case .timeUp, .timeDown:
                        insertResult = addByDate(lastItem: lastItem, newItem: item)
                    case .lettersAZ, .lettersZA:
                        insertResult = addByName(lastItem: lastItem, newItem: item)
                    case .sizeAZ, .sizeZA:
                        insertResult = addBySize(lastItem: lastItem, newItem: item)
                    default:
                        insertResult = nil
                    }
                } else {
                    insertResult = appendSection(with: item)
                }
                
                if let indexPath = insertResult?.indexPath {
                    insertedIndexPaths.append(indexPath)
                }
                
                if let section = insertResult?.section {
                    insertedSections.insert(section)
                }
            }
        }
        return (insertedIndexPaths, insertedSections)
    }
    
    private func delete(items: [Item]) -> ChangesItemResult {
        var deletedIndexPaths = [IndexPath]()
        var deletedSections = IndexSet()
        let idsForRemove = items.map { $0.uuid }
        var newArray = [[Item]]()
        
        for (section, array) in allItems.enumerated() {
            var newSectionArray = [Item]()
            for (item, object) in array.enumerated() {
                if idsForRemove.contains(object.uuid) {
                    deletedIndexPaths.append(IndexPath(item: item, section: section + 1))
                } else {
                    newSectionArray.append(object)
                }
            }
            
            if newSectionArray.isEmpty {
                deletedSections.insert(section + 1)
            } else {
                newArray.append(newSectionArray)
            }
        }
        
        allItems = newArray
        
        return (deletedIndexPaths, deletedSections)
    }
    
    private func addByDate(lastItem: Item, newItem: Item) -> InsertItemResult {
        guard let lastItemdDate = lastItem.creationDate,
            let newItemDate = newItem.creationDate else {
            return (nil, nil)
        }
        
        if lastItemdDate.getYear() == newItemDate.getYear(),
            lastItemdDate.getMonth() == newItemDate.getMonth(),
            !itemsIsEmpty {
            return appendInLastSection(newItem: newItem)
        } else {
            return appendSection(with: newItem)
        }
    }
    
    private func addByName(lastItem: WrapData, newItem: WrapData) -> InsertItemResult {
        let lastItemFirstLetter = lastItem.name?.firstLetter ?? ""
        let newItemFirstLetter = newItem.name?.firstLetter ?? ""
        
        if !lastItemFirstLetter.isEmpty, !newItemFirstLetter.isEmpty,
            lastItemFirstLetter == newItemFirstLetter,
            !itemsIsEmpty {
            return appendInLastSection(newItem: newItem)
        } else {
            return appendSection(with: newItem)
        }
    }
    
    private func addBySize(lastItem: WrapData, newItem: WrapData) -> InsertItemResult {
        if !itemsIsEmpty {
            return appendInLastSection(newItem: newItem)
        }
        return (nil, nil)
    }
    
    private func appendInLastSection(newItem: Item) -> InsertItemResult {
        guard !itemsIsEmpty else {
            assertionFailure()
            return (nil, nil)
        }
        
        let section = allItems.count - 1
        let item = allItems[section].count
        let indexPath = IndexPath(item: item, section: section + 1)
        allItems[section].append(newItem)
        return (indexPath, nil)
    }
    
    private func appendSection(with newItem: Item) -> InsertItemResult {
        let section = allItems.count + 1
        let indexPath = IndexPath(item: 0, section: section)
        allItems.append([newItem])
        return (indexPath, section)
    }
    
    private func updateItems(count: Int, forFolder folderUUID: String, increment: Bool) {
        guard let indexPath = indexPath(for: folderUUID),
            let item = item(for: indexPath),
            let childCount = item.childCount else {
            return
        }
    
        if increment {
            item.childCount = childCount + Int64(count)
        } else {
            item.childCount = childCount - Int64(count)
        }
        
        DispatchQueue.main.async {
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: [indexPath])
            }, completion: nil)
        }
    }
}

//MARK: - UICollectionViewDataSource

extension TrashBinDataSource: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return allItems.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        guard section - 1 < allItems.count else {
            return 0
        }
        return allItems[section - 1].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            return collectionView.dequeue(cell: AlbumsSliderCell.self, for: indexPath)
        } else {
            return collectionView.dequeue(cell: BasicCollectionMultiFileCell.self, for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            return UICollectionReusableView()
        }
        return collectionView.dequeue(supplementaryView: CollectionViewSimpleHeaderWithText.self, kind: kind, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let cell = cell as? AlbumsSliderCell else {
                return
            }
            
            if albumSlider == nil {
                albumSlider = cell
                albumSlider?.reset()
            }
            
            cell.delegate = self
            cell.setup(title: TextConstants.trashBinAlbumSliderTitle, emptyText: TextConstants.trashBinAlbumSliderEmpty)
            return
        }
        
        guard let cell = cell as? BasicCollectionMultiFileCell,
            let item = item(for: indexPath) else {
            assertionFailure("failed setup cell")
            return
        }
        
        cell.updating()
        cell.setSelection(isSelectionActive: isSelectionStateActive, isSelected: selectedItems.contains(item))
        cell.configureWithWrapper(wrappedObj: item)
        cell.setDelegateObject(delegateObject: self)
        cell.filesDataSource = filesDataSource
        cell.loadImage(item: item, indexPath: indexPath)
        
        if isPaginationDidEnd {
            return
        }

        let countRow = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        let isLastCell = countRow - 1 == indexPath.row && indexPath.section == collectionView.numberOfSections - 1

        if isLastCell {
            delegate?.needLoadNextItemsPage()
        }
    }
    
    /// fixing iOS11 UICollectionSectionHeader clipping scroll indicator
    /// https://stackoverflow.com/a/46930410/5893286
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        /// fixing iOS11 UICollectionSectionHeader clipping scroll indicator
        /// https://stackoverflow.com/a/46930410/5893286
        if #available(iOS 11.0, *), elementKind == UICollectionElementKindSectionHeader {
            view.layer.zPosition = 0
        }
        guard indexPath.section > 0, let view = view as? CollectionViewSimpleHeaderWithText else {
            return
        }

        view.setText(text: headerText(indexPath: indexPath))
    }
}

//MARK: - UICollectionViewDelegate

extension TrashBinDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section > 0, let item = item(for: indexPath) else {
            return
        }
        
        if isSelectionStateActive {
            if selectedItems.contains(item) {
                selectedItems.remove(item)
            } else {
                selectedItems.append(item)
            }
            collectionView.reloadItems(at: [indexPath])
            updateSelectionCount()
        } else  {
            delegate?.didSelect(item: item)
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
 
extension TrashBinDataSource: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat {
        return showGroups && section > 0 ? 50 : 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height: CGFloat = showGroups && section > 0 ? 50 : 0
        return CGSize(width: collectionView.bounds.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: collectionView.bounds.width, height: AlbumsSliderCell.height)
        } else if viewType == .Grid {
            return cellGridSize
        } else {
            return cellListSize
        }
    }
}

//MARK: - LBCellsDelegate

extension TrashBinDataSource: LBCellsDelegate, BasicCollectionMultiFileCellActionDelegate {
    
    func canLongPress() -> Bool {
        return true
    }
    
    func onLongPress(cell: UICollectionViewCell) {
        if !isSelectionStateActive {
            startSelection(indexPath: collectionView.indexPath(for: cell))
            albumSlider?.startSelection()
        } else if let indexPath = collectionView.indexPath(for: cell) {
            collectionView(self.collectionView, didSelectItemAt: indexPath)
        }
    }
    
    func morebuttonGotPressed(sender: Any, itemModel: Item?) {
        if let item = itemModel {
            delegate?.onMoreButtonTapped(sender: sender, item: item)
        }
    }
}

//MARK: - AlbumsSliderCellDelegate

extension TrashBinDataSource: AlbumsSliderCellDelegate {
    
    func didSelect(item: BaseDataSourceItem) {
        delegate?.didSelect(album: item)
    }
    
    func didChangeSelectionAlbumsCount(_ count: Int) {
        updateSelectionCount()
    }
    
    func needLoadNextAlbumPage() {
        delegate?.needLoadNextAlbumPage()
    }
    
    func onStartSelection() {
        startSelection()
    }
}
