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
    func onStartSelection()
    func onSelect(item: SpotifyObject)
    func didChangeSelectionCount(newCount: Int)
}

class SpotifyCollectionViewDataSource<T: SpotifyObject>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    typealias SpotifyObjectGroup = (key: String, value: [T])
    
    private let collectionView: UICollectionView
    private weak var delegate: SpotifyCollectionDataSourceDelegate?
    
    private var allItems = [T]()
    private(set) var groups = [SpotifyObjectGroup]()
    
    private(set) var selectedItems = [T]() {
        didSet {
            delegate?.didChangeSelectionCount(newCount: selectedItems.count)
        }
    }

    var isSelectionStateActive = false
    var canChangeSelectionState = true
    
    var isPaginationDidEnd = false
    
    // MARK: -
    
    required init(collectionView: UICollectionView, delegate: SpotifyCollectionDataSourceDelegate?) {
        self.collectionView = collectionView
        self.delegate = delegate
        super.init()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(nibCell: SpotifyPlaylistCollectionViewCell.self)
        collectionView.register(nibSupplementaryView: CollectionViewSimpleHeaderWithText.self, kind: UICollectionElementKindSectionHeader)
        collectionView.allowsMultipleSelection = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 70)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
        }
    }
    
    private func item(for indexPath: IndexPath) -> T? {
        return groups[safe: indexPath.section]?.value[safe: indexPath.row]
    }
    
    private func headerText(at section: Int) -> String {
        if let firstLetter = groups[safe: section]?.value.first?.name.first {
            return String(firstLetter)
        }
        return ""
    }
    
    func append(_ newItems: [T]) {
        guard !newItems.isEmpty else {
            isPaginationDidEnd = true
            return
        }
        
        let reload = allItems.isEmpty
        allItems.append(contentsOf: newItems)
        groups = Dictionary(grouping: allItems, by: { String($0.name.first ?? Character("")) }).sorted {$0.0 < $1.0}
        
        if reload {
            collectionView.reloadData()
        } else {
            var insertedIndexPaths = [IndexPath]()
            groups.enumerated().forEach { section, array in
                array.value.enumerated().forEach { row, item in
                    if newItems.contains(item) {
                        insertedIndexPaths.append(IndexPath(row: row, section: section))
                    }
                }
            }
            if !insertedIndexPaths.isEmpty {
                collectionView.performBatchUpdates ({
                    collectionView.insertItems(at: insertedIndexPaths)
                })
            }
        }
    }
    
    func selectAll() {
        selectedItems = allItems
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups[section].value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: SpotifyPlaylistCollectionViewCell.self, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SpotifyPlaylistCollectionViewCell,
            let item = item(for: indexPath) else {
                return
        }
        cell.setup(with: item, isSelected: selectedItems.contains(item))
        cell.delegate = self
        
        if isPaginationDidEnd {
            return
        }
        
        let countRow: Int = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        let isLastSection = numberOfSections(in: collectionView) - 1 == indexPath.section
        let isLastCell = countRow - 1 == indexPath.row
        
        if isLastSection, isLastCell {
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
            return
        }
        
        view.setText(text: headerText(at: indexPath.section))
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = item(for: indexPath) {
            delegate?.onSelect(item: item)
        }
    }
}

// MARK: - SpotifyPlaylistCellDelegate

extension SpotifyCollectionViewDataSource: SpotifyPlaylistCellDelegate {
    func canLongPress() -> Bool {
        return true
    }
    
    func onLongPress(cell: UICollectionViewCell) {
        if canChangeSelectionState, !isSelectionStateActive {
            if let indexPath = collectionView.indexPath(for: cell) {
//                startSelection(with: indexPath)
            }
            delegate?.onStartSelection()
        }
    }
    
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
}
