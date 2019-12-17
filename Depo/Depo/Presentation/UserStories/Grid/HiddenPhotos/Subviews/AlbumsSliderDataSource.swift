//
//  AlbumsSliderDataSource.swift
//  Depo
//
//  Created by Andrei Novikau on 12/12/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol AlbumsSliderDataSourceDelegate: class {
    func didSelect(item: BaseDataSourceItem)
    func didChangeSelectionCount(_ count: Int)
    func needLoadNextPage()
    func onStartSelection()
}

final class AlbumsSliderDataSource: NSObject {
    
    private let collectionView: UICollectionView
    private weak var delegate: AlbumsSliderDataSourceDelegate?
    
    private(set) var items = [BaseDataSourceItem]()
    private(set) var selectedItems = [BaseDataSourceItem]() {
        didSet {
            delegate?.didChangeSelectionCount(selectedItems.count)
        }
    }
    
    private(set) var isSelectionActive = false
    var isPaginationDidEnd = false
    
    //MARK: - Init
    
    required init(collectionView: UICollectionView, delegate: AlbumsSliderDataSourceDelegate?) {
        self.collectionView = collectionView
        self.delegate = delegate
        
        super.init()
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .lrSkinTone
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(nibCell: AlbumCell.self)
        collectionView.allowsMultipleSelection = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 100, height: 140)
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 0
        }
    }
    
    //MARK: - Shared methods

    func appendItems(_ newItems: [BaseDataSourceItem]) {
        if newItems.isEmpty {
            return
        }

        if items.isEmpty {
            items = newItems
            collectionView.reloadData()
        } else {
            let startIndex = items.count
            let endIndex = startIndex + newItems.count - 1
           
            items.append(contentsOf: newItems)
           
            let indexPaths = (startIndex...endIndex).map { IndexPath(item: $0, section: 0) }
            collectionView.insertItems(at: indexPaths)
        }
    }
    
    func reset() {
        items.removeAll()
        selectedItems.removeAll()
        isPaginationDidEnd = false
    }
}

extension AlbumsSliderDataSource {
    func startSelection(indexPath: IndexPath? = nil) {
        isSelectionActive = true
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        
        if let indexPath = indexPath {
            delegate?.onStartSelection()
            selectedItems.append(items[indexPath.row])
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func cancelSelection() {
        isSelectionActive = false
        selectedItems.removeAll()
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }
}

//MARK: - UICollectionViewDataSource

extension AlbumsSliderDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: AlbumCell.self, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? AlbumCell else {
            return
        }
        
        let item = items[indexPath.row]
        cell.setup(with: item)
        cell.setSelection(isSelectionActive: isSelectionActive, isSelected: selectedItems.contains(item))
        
        if isPaginationDidEnd {
            return
        }
        
        let countRow = self.collectionView(collectionView, numberOfItemsInSection: 0)

        if indexPath.row == countRow - 1 {
            delegate?.needLoadNextPage()
        }
    }
}

//MARK: - UICollectionViewDelegate

extension AlbumsSliderDataSource: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        
        if isSelectionActive {
            if selectedItems.contains(item) {
                selectedItems.remove(item)
            } else {
                selectedItems.append(item)
            }
            collectionView.reloadItems(at: [indexPath])
        } else {
            delegate?.didSelect(item: item)
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}

extension AlbumsSliderDataSource: LBCellsDelegate {
    
    func canLongPress() -> Bool {
        return true
    }
    
    func onLongPress(cell: UICollectionViewCell) {
        if !isSelectionActive {
            startSelection(indexPath: collectionView.indexPath(for: cell))
        }
    }
}
