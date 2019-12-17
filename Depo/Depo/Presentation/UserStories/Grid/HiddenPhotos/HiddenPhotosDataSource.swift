//
//  HiddenPhotosDataSource.swift
//  Depo
//
//  Created by Andrei Novikau on 12/12/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol HiddenPhotosDataSourceDelegate: class {
    func needLoadNextPhotoPage()
    func needLoadNextAlbumPage()
    func didSelectPhoto(item: Item)
    func didSelectAlbum(item: BaseDataSourceItem)
    func onStartSelection()
}

final class HiddenPhotosDataSource: NSObject {
    
    private typealias InsertItemResult = (indexPath: IndexPath?, section: Int?)
    private typealias ChangesItemResult = (indexPaths: [IndexPath], sections: IndexSet)
    
    private let padding: CGFloat = 1
    private let columns = Device.isIpad ? NumericConstants.numerCellInLineOnIpad : NumericConstants.numerCellInLineOnIphone
    
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.baseFilesGreedCollectionDataSource)
    
    private let collectionView: UICollectionView
    private weak var delegate: HiddenPhotosDataSourceDelegate?
    private var albumSlider: AlbumsSliderCell? {
        return collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? AlbumsSliderCell
    }
    
    private(set) var allItems = [[Item]]()
    private(set) var selectedItems = [Item]()
    
    private var showGroups: Bool {
        return sortedRule.isContained(in: [.lettersAZ, .lettersZA, .sizeZA, .timeUp, .timeDown])
    }
    
    var sortedRule: SortedRules = .timeDown
    private(set) var isSelectionStateActive = false
    private var isPaginationDidEnd = false
    
    var isEmpty: Bool {
        var result = true
        allItems.forEach { items in
            if !items.isEmpty {
                result = false
                return
            }
        }
        return result
    }
    
    private lazy var photoCellSize: CGSize = {
        let viewWidth = UIScreen.main.bounds.width
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        return CGSize(width: itemWidth, height: itemWidth)
    }()
    
    //MARK: - Init
    
    required init(collectionView: UICollectionView, delegate: HiddenPhotosDataSourceDelegate?) {
        self.collectionView = collectionView
        self.delegate = delegate
        
        super.init()
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(nibCell: CollectionViewCellForPhoto.self)
        collectionView.register(nibCell: CollectionViewCellForVideo.self)
        collectionView.register(nibCell: AlbumsSliderCell.self)
        collectionView.register(nibSupplementaryView: CollectionViewSimpleHeaderWithText.self, kind: UICollectionElementKindSectionHeader)
        collectionView.allowsMultipleSelection = true
        collectionView.alwaysBounceVertical = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
        }
    }
}

//MARK: - Public methods

extension HiddenPhotosDataSource {
    
    func appendAlbum(items: [BaseDataSourceItem]) {
        albumSlider?.appendItems(items)
    }
    
    func append(items: [Item]) {
        if items.isEmpty {
            isPaginationDidEnd = true
        }
        
        if allItems.isEmpty {
            allItems.append(items)
            collectionView.reloadData()
        } else {
            dispatchQueue.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                let insertResult = self.insert(newItems: items)
                guard !insertResult.indexPaths.isEmpty else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.collectionView.performBatchUpdates({
                        if !insertResult.sections.isEmpty {
                            self.collectionView.insertSections(insertResult.sections)
                        }
                        self.collectionView.insertItems(at: insertResult.indexPaths)
                    }, completion: nil)
                }
            }
        }
    }
    
    func remove(items: [Item]) {
        dispatchQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            let deleteResult = self.delete(items: items)
            guard !deleteResult.indexPaths.isEmpty else {
                return
            }

            DispatchQueue.main.async {
                if self.allItems.isEmpty {
                    self.collectionView.reloadData()
                } else {
                    self.collectionView.performBatchUpdates({
                        self.collectionView.deleteItems(at: deleteResult.indexPaths)
                        if !deleteResult.sections.isEmpty {
                            self.collectionView.deleteSections(deleteResult.sections)
                        }
                    }, completion: nil)
                }
            }
        }
    }
    
    func reset() {
        allItems.removeAll()
        selectedItems.removeAll()
        isPaginationDidEnd = false
        albumSlider?.reset()
    }
    
    func startSelection(indexPath: IndexPath? = nil) {
        isSelectionStateActive = true
        updateVisibleCells(isSelectionStateActive)
        
        delegate?.onStartSelection()
        
        if let indexPath = indexPath, let item = item(for: indexPath) {
            selectedItems.append(item)
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func cancelSelection() {
        isSelectionStateActive = false
        selectedItems.removeAll()
        updateVisibleCells(isSelectionStateActive)
    }
    
    private func updateVisibleCells(_ isSelectionStateActive: Bool? = nil, animated: Bool = true) {
        if let isSelectionStateActive = isSelectionStateActive {
            collectionView.visibleCells.compactMap { $0 as? CollectionViewCellDataProtocol }.forEach {
                $0.setSelection(isSelectionActive: isSelectionStateActive, isSelected: false)
            }
        } else {
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        }
    }
}

//MARK: - Data processing

extension HiddenPhotosDataSource {
    
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
            return firstLetter(of: item.name)
        default:
            return ""
        }
    }
    
    private func headerText(indexPath: IndexPath) -> String {
        guard let itemsInSection = allItems[safe: indexPath.section - 1], let item = itemsInSection.first else {
            return ""
        }
        return headerText(for: item)
    }
    
    private func insert(newItems: [Item]) -> ChangesItemResult {
        var insertedIndexPaths = [IndexPath]()
        var insertedSections = IndexSet()
        
        for item in newItems {
            autoreleasepool {
                if let lastItem = allItems.last?.last {
                    let insertResult: InsertItemResult?
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
                    
                    if let indexPath = insertResult?.indexPath {
                        insertedIndexPaths.append(indexPath)
                    }
                    
                    if let section = insertResult?.section {
                        insertedSections.insert(section)
                    }
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
                    deletedIndexPaths.append(IndexPath(item: item, section: section))
                } else {
                    newSectionArray.append(object)
                }
            }
            
            if newSectionArray.isEmpty {
                deletedSections.insert(section)
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
        let lastItemFirstLetter = firstLetter(of: lastItem.name)
        let newItemFirstLetter = firstLetter(of: newItem.name)
        
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
    
    private func firstLetter(of string: String?) -> String {
        if let character = string?.first {
            return String(describing: character).uppercased()
        }
        return ""
    }
}

//MARK: - UICollectionViewDataSource

extension HiddenPhotosDataSource: UICollectionViewDataSource {
    
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
//            assertionFailure("failed return cell")
            return collectionView.dequeue(cell: CollectionViewCellForPhoto.self, for: indexPath)
        }
        
        switch item.fileType {
        case .image:
             return collectionView.dequeue(cell: CollectionViewCellForPhoto.self, for: indexPath)
        case .video:
             return collectionView.dequeue(cell: CollectionViewCellForVideo.self, for: indexPath)
        default:
             return collectionView.dequeue(cell: CollectionViewCellForPhoto.self, for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeue(supplementaryView: CollectionViewSimpleHeaderWithText.self, kind: kind, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let cell = cell as? AlbumsSliderCell else {
                return
            }
            
            cell.delegate = self
            cell.setup(title: TextConstants.hiddenBinAlbumSliderTitle, emptyText: TextConstants.hiddenBinAlbumSliderEmpty)
            return
        }
        
        guard let cell = cell as? CollectionViewCellDataProtocol,
            let item = item(for: indexPath) else {
//            assertionFailure("failed setup cell")
            return
        }
        
        cell.setSelection(isSelectionActive: isSelectionStateActive, isSelected: selectedItems.contains(item))
        cell.configureWithWrapper(wrappedObj: item)
        cell.setDelegateObject(delegateObject: self)

        if isPaginationDidEnd {
            return
        }

        let countRow = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        let isLastCell = countRow - 1 == indexPath.row && indexPath.section == collectionView.numberOfSections - 1

        if isLastCell {
            delegate?.needLoadNextPhotoPage()
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
        guard let view = view as? CollectionViewSimpleHeaderWithText else {
            return
        }

        view.setText(text: headerText(indexPath: indexPath))
    }
}

//MARK: - UICollectionViewDelegate

extension HiddenPhotosDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section > 0 else {
            return
        }
        
        if isSelectionStateActive {
            
        } else if let item = item(for: indexPath) {
            delegate?.didSelectPhoto(item: item)
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
 
extension HiddenPhotosDataSource: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat {
        return showGroups && section > 0 ? 50 : 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height: CGFloat = showGroups && section > 0 ? 50 : 0
        return CGSize(width: collectionView.contentSize.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: collectionView.contentSize.width, height: AlbumsSliderCell.height)
        }
        return photoCellSize
    }
}

//MARK: - LBCellsDelegate

extension HiddenPhotosDataSource: LBCellsDelegate {
    
    func canLongPress() -> Bool {
        return true
    }
    
    func onLongPress(cell: UICollectionViewCell) {
        if !isSelectionStateActive, let indexPath = collectionView.indexPath(for: cell) {
            startSelection(indexPath: indexPath)
        }
    }
}

//MARK: - AlbumsSliderViewDelegate

extension HiddenPhotosDataSource: AlbumsSliderCellDelegate {
    func didSelect(item: BaseDataSourceItem) {
        delegate?.didSelectAlbum(item: item)
    }
    
    func didChangeSelectionCount(_ count: Int) {
        
    }
    
    func needLoadNextAlbumPage() {
        delegate?.needLoadNextAlbumPage()
    }
}
