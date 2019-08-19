//
//  SpotifyCollectionViewDataSource.swift
//  Depo
//
//  Created by Andrei Novikau on 7/31/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol SpotifyCollectionDataSourceDelegate: class {
    func needLoadNextPage()
    func onSelect(item: SpotifyObject)
    func didChangeSelectionCount(newCount: Int)
    func onStartSelection()
    func canShowDetails() -> Bool
}

final class SpotifyCollectionViewDataSource<T: SpotifyObject>: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    typealias SpotifyObjectGroup = (key: String, value: [T])
    
    private let collectionView: UICollectionView
    private weak var delegate: SpotifyCollectionDataSourceDelegate?
    
    private(set) var allItems = [T]()
    private var groups = [SpotifyObjectGroup]()
    var sortedRule: SortedRules = .timeDown
    
    private(set) var selectedItems = [T]() {
        didSet {
            delegate?.didChangeSelectionCount(newCount: selectedItems.count)
        }
    }

    var isSelectionStateActive = false 
    var canChangeSelectionState = true
    var selectionFullCell = true
    
    var isPaginationDidEnd = false
    
    var showOnlySelected = false // true for complete import state
    
    var isHeaderless = false
    private var showGroups: Bool {
        return !(isHeaderless || sortedRule == .sizeAZ || sortedRule == .sizeZA)
    }
    
    private var canShowDetails: Bool {
        return delegate?.canShowDetails() ?? false
    }
    
    // MARK: -
    
    required init(collectionView: UICollectionView, delegate: SpotifyCollectionDataSourceDelegate?) {
        self.collectionView = collectionView
        self.delegate = delegate
        super.init()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(nibCell: SpotifyPlaylistCollectionViewCell.self)
        collectionView.register(nibSupplementaryView: CollectionViewSimpleHeaderWithText.self, kind: UICollectionElementKindSectionHeader)
        collectionView.allowsMultipleSelection = true
        collectionView.alwaysBounceVertical = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 70)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
        }
    }
    
    func reset() {
        isPaginationDidEnd = false
        allItems.removeAll()
    }
    
    // MARK: - Selection
    
    func selectAll() {
        selectedItems = allItems
        updateVisibleCells()
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
            collectionView.visibleCells.compactMap { $0 as? SpotifyPlaylistCollectionViewCell }.forEach {
                $0.setSeletionMode(isSelectionStateActive, animated: animated)
                $0.isHiddenArrow = !canShowDetails
            }
        } else {
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        }
    }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return showGroups ? groups.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if showGroups {
            return groups[safe: section]?.value.count ?? 0
        }
        return showOnlySelected ? selectedItems.count : allItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: SpotifyPlaylistCollectionViewCell.self, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SpotifyPlaylistCollectionViewCell,
            let item = item(for: indexPath) else {
            assertionFailure("failed setup cell")
            return
        }

        cell.isHiddenArrow = !canShowDetails
        cell.setSeletionMode(isSelectionStateActive, animated: false)
        cell.setup(with: item, delegate: self, isSelected: selectedItems.contains(item))
        
        if isPaginationDidEnd {
            return
        }
        
        let countRow: Int = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        let isLastCell = countRow - 1 == indexPath.row
        
        if isLastCell {
            delegate?.needLoadNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeue(supplementaryView: CollectionViewSimpleHeaderWithText.self, kind: kind, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        /// fixing iOS11 UICollectionSectionHeader clipping scroll indicator
        /// https://stackoverflow.com/a/46930410/5893286
        if #available(iOS 11.0, *), elementKind == UICollectionElementKindSectionHeader {
            view.layer.zPosition = 0
        }
        guard let view = view as? CollectionViewSimpleHeaderWithText else {
            assertionFailure("failed setup header")
            return
        }
        
        let headerText = groups[safe: indexPath.section]?.key ?? ""
        view.setText(text: headerText)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectionFullCell && isSelectionStateActive {
            guard let cell = collectionView.cellForItem(at: indexPath) as? SpotifyPlaylistCollectionViewCell else {
                assertionFailure("cell not found")
                return
            }
            cell.reverseSelected()
            
        } else if let item = item(for: indexPath) {
            delegate?.onSelect(item: item)
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return showGroups ? CGSize(width: UIScreen.main.bounds.width, height: 50) : .zero
    }
}

// MARK: - Data processing

extension SpotifyCollectionViewDataSource {
    func append(_ newItems: [T]) {
        guard !newItems.isEmpty else {
            isPaginationDidEnd = true
            return
        }

        let reloadCollectionView = allItems.isEmpty
        var filteredNewItems = [T]()
        newItems.forEach { item in
            if !allItems.contains(item) {
                allItems.append(item)
                filteredNewItems.append(item)
            }
        }
        
        if showGroups {
            updateGroupedItems()
        }
        
        if reloadCollectionView {
            collectionView.contentOffset = .zero
            collectionView.reloadData()
        } else {
            let updates = mergeUpdate(filteredNewItems)
            if !updates.insertedIndexPaths.isEmpty {
                collectionView.performBatchUpdates ({
                    if let insertedSections = updates.insertedSections, !insertedSections.isEmpty {
                        collectionView.insertSections(insertedSections)
                    }
                    collectionView.insertItems(at: updates.insertedIndexPaths)
                })
            }
        }
    }
    
    func remove(_ items: [T], completion: @escaping VoidHandler) {
        let indexPaths = items.compactMap { indexPath(for: $0) }
        
        if indexPaths.isEmpty {
            return
        }
        
        items.forEach { allItems.remove($0) }
        
        var deleteSections = IndexSet()
        if showGroups {
            let oldSections = groups.map { $0.key }
            updateGroupedItems()
            let newSections = groups.map { $0.key }
            
            var indexes = [Int]()
            oldSections.enumerated().forEach { index, section in
                if !newSections.contains(section) {
                    indexes.append(index)
                }
            }
            deleteSections = IndexSet(indexes)
        }
        
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: indexPaths)
            if !deleteSections.isEmpty {
                collectionView.deleteSections(deleteSections)
            }
        }, completion: { _ in
            completion()
        })
    }
    
    func update(_ item: T) {
        guard let path = indexPath(for: item) else {
            assertionFailure("nothing to update")
            return
        }
        
        if showGroups {
            groups[path.section].value[path.row] = item
            
            if let index = allItems.firstIndex(where: { $0 == item }) {
                allItems[index] = item
            }
        } else {
            allItems[path.row] = item
        }
        
        collectionView.reloadItems(at: [path])
    }
    
    private func updateGroupedItems() {
        let dict: [String: [T]]
        switch sortedRule.sortingRules {
        case .name:
            dict = Dictionary(grouping: allItems, by: { $0.nameFirstLetter })
        case .date:
            dict = Dictionary(grouping: allItems, by: { $0.monthValue })
        default:
            dict = [String: [T]]()
            assertionFailure("unknown sort type")
        }
        
        switch sortedRule.sortOder {
        case .asc:
            groups = dict.sorted { $0.0 < $1.0 }
        case .desc:
            groups = dict.sorted { $0.0 > $1.0 }
        }
    }
    
    private func mergeUpdate(_ newItems: [T]) -> (insertedSections: IndexSet?, insertedIndexPaths: [IndexPath]) {
        if !showGroups {
            let insertedIndexPaths = (allItems.count - newItems.count..<allItems.count).map { IndexPath(row: $0, section: 0) }
            return (nil, insertedIndexPaths)
        }
        
        let oldSectionNumbers = collectionView.numberOfSections
        let newSectionNumbers = groups.count
        let insertedSections = IndexSet(oldSectionNumbers..<newSectionNumbers)

        var insertedIndexPaths = [IndexPath]()
        groups.enumerated().forEach { section, group in
            group.value.enumerated().forEach { row, item in
                if newItems.contains(item) {
                    insertedIndexPaths.append(IndexPath(row: row, section: section))
                }
            }
        }
        return (insertedSections, insertedIndexPaths)
    }
    
    private func item(for indexPath: IndexPath) -> T? {
        if showGroups {
            return groups[safe: indexPath.section]?.value[safe: indexPath.row]
        }
        return showOnlySelected ? selectedItems[safe: indexPath.row] : allItems[safe: indexPath.row]
    }
    
    private func indexPath(for item: T) -> IndexPath? {
        if showGroups {
            let sectionKey: String
            switch sortedRule.sortingRules {
            case .name:
                sectionKey = item.nameFirstLetter
            case .date:
                sectionKey = item.monthValue
            default:
                assertionFailure("unknown sort type")
                return nil
            }
            
            let sections = groups.map { $0.0 }
            if let section = sections.firstIndex(where: { $0 == sectionKey }),
               let row = groups[section].value.firstIndex(where: {$0 == item }) {
                return IndexPath(row: row, section: section)
            } else {
                return nil
            }
        } else if let row = allItems.firstIndex(where: { $0 == item }) {
            return IndexPath(row: row, section: 0)
        } else {
            return nil
        }
    }
}

// MARK: - SpotifyPlaylistCellDelegate

extension SpotifyCollectionViewDataSource: SpotifyPlaylistCellDelegate {
    
    func onSelect(cell: SpotifyPlaylistCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell),
            let item = item(for: indexPath),
            !selectedItems.contains(item) {
            selectedItems.append(item)
        }
    }
    
    func onDeselect(cell: SpotifyPlaylistCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell),
            let item = item(for: indexPath) {
            selectedItems.remove(item)
        }
    }
    
    func canLongPress() -> Bool {
        return canChangeSelectionState
    }
    
    func onLongPress(cell: UICollectionViewCell) {
        if !isSelectionStateActive,
            let indexPath = collectionView.indexPath(for: cell) {
            startSelection(indexPath: indexPath)
        }
    }
}
