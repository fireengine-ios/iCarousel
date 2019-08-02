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

class SpotifyCollectionViewDataSource<T: SpotifyObject>: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let collectionView: UICollectionView
    private weak var delegate: SpotifyCollectionDataSourceDelegate?
    
    private var items = [T]()
    
    private(set) var selectedItems = [T]() {
        didSet {
            delegate?.didChangeSelectionCount(newCount: selectedItems.count)
        }
    }

    var isSelectionStateActive = false 
    var canChangeSelectionState = true
    
    var isPaginationDidEnd = false
    
    var showOnlySelected = false 
    
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
    
    func append(_ newItems: [T]) {
        guard !newItems.isEmpty else {
            isPaginationDidEnd = true
            return
        }
    
        if items.isEmpty {
            items = newItems
            collectionView.reloadData()
        } else {
            let insertedIndexPaths = (items.count..<items.count + newItems.count).map { IndexPath(row: $0, section: 0) }
            
            items.append(contentsOf: newItems)
            collectionView.performBatchUpdates ({
                collectionView.insertItems(at: insertedIndexPaths)
            })
        }
    }
    
    func selectAll() {
        selectedItems = items
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }
    
    private func item(for indexPath: IndexPath) -> T? {
        return showOnlySelected ? selectedItems[safe: indexPath.row] : items[safe: indexPath.row]
    }

    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: SpotifyPlaylistCollectionViewCell.self, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SpotifyPlaylistCollectionViewCell,
            let item = item(for: indexPath) else {
                return
        }
        cell.setSeletionMode(isSelectionStateActive, animation: false)
        cell.setup(with: item, isSelected: selectedItems.contains(item))
        cell.delegate = self
        
        if isPaginationDidEnd {
            return
        }
        
        let countRow: Int = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        let isLastCell = countRow - 1 == indexPath.row
        
        if isLastCell {
            delegate?.needLoadNextPage()
        }
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
