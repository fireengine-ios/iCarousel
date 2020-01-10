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
}

final class TrashBinDataSource: NSObject {
    
    private typealias InsertItemResult = (indexPath: IndexPath?, section: Int?)
    private typealias ChangesItemResult = (indexPaths: [IndexPath], sections: IndexSet)
    typealias SelectedItems = (items: [Item], albums: [BaseDataSourceItem])
    
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
        let paddingWidth = columnPadding * 2 - (columns - 1) * columnPadding
        let itemWidth = floor((viewWidth - paddingWidth) / columns)
        return CGSize(width: itemWidth, height: itemWidth)
    }()
    
    private lazy var cellListSize: CGSize = {
        return CGSize(width: UIScreen.main.bounds.width, height: 65)
    }()
    
    var allSelectedItems: SelectedItems {
        return (selectedItems, albumSlider?.selectedItems ?? [])
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
                            CollectionViewCellForPhoto.self,
                            CollectionViewCellForVideo.self,
                            CollectionViewCellForAudio.self,
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
            let insertResult = self.insert(newItems: items)
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
    
    func getSameTypeItems(for item: Item) -> [Item] {
        let items = allItems.flatMap { $0 }
        if item.fileType.isDocument {
            return items.filter { $0.fileType.isDocument }
        } else if item.fileType == .video || item.fileType == .image {
            return items.filter { $0.fileType == .video || $0.fileType == .image }
        }
        return items.filter { $0.fileType == item.fileType }
    }
    
    private func updateVisibleCells() {
        collectionView.visibleCells.compactMap { $0 as? CollectionViewCellDataProtocol }.forEach {
            $0.setSelection(isSelectionActive: isSelectionStateActive, isSelected: false)
        }
    }
    
    private func updateSelectionCount() {
        if let selectedAlbumsCount = albumSlider?.selectedItems.count {
            delegate?.didChangeSelectedItems(count: selectedItems.count + selectedAlbumsCount)
        } else {
            delegate?.didChangeSelectedItems(count: selectedItems.count)
        }
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
    
    private func insert(newItems: [Item]) -> ChangesItemResult {
        var insertedIndexPaths = [IndexPath]()
        var insertedSections = IndexSet()
        
        let allMedia = allItems.flatMap { $0 }
        let insertItems = newItems.filter { !allMedia.contains($0) }
        
        for item in insertItems {
            autoreleasepool {
                let insertResult: InsertItemResult?
                if !allItems.isEmpty,
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
            !allItems.isEmpty {
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
            !allItems.isEmpty {
            return appendInLastSection(newItem: newItem)
        } else {
            return appendSection(with: newItem)
        }
    }
    
    private func addBySize(lastItem: WrapData, newItem: WrapData) -> InsertItemResult {
        if !allItems.isEmpty {
            return appendInLastSection(newItem: newItem)
        }
        return (nil, nil)
    }
    
    private func appendInLastSection(newItem: Item) -> InsertItemResult {
        guard !allItems.isEmpty else {
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
        }

        guard let item = item(for: indexPath) else {
            assertionFailure("failed return cell")
            return collectionView.dequeue(cell: CollectionViewCellForPhoto.self, for: indexPath)
        }
        
        if viewType == .List {
            return collectionView.dequeue(cell: BasicCollectionMultiFileCell.self, for: indexPath)
        }
        
        switch item.fileType {
        case .image:
             return collectionView.dequeue(cell: CollectionViewCellForPhoto.self, for: indexPath)
        case .video:
             return collectionView.dequeue(cell: CollectionViewCellForVideo.self, for: indexPath)
        case .audio:
            return collectionView.dequeue(cell: CollectionViewCellForAudio.self, for: indexPath)
        default:
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
        
        guard let cell = cell as? CollectionViewCellDataProtocol,
            let item = item(for: indexPath) else {
            assertionFailure("failed setup cell")
            return
        }
        
        cell.configureWithWrapper(wrappedObj: item)
        cell.setSelection(isSelectionActive: isSelectionStateActive, isSelected: selectedItems.contains(item))
        cell.setDelegateObject(delegateObject: self)
        (cell as? CollectionViewCellForPhoto)?.filesDataSource = filesDataSource
        (cell as? CollectionViewCellForPhoto)?.loadImage(item: item, indexPath: indexPath)
        
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

extension TrashBinDataSource: LBCellsDelegate {
    
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
