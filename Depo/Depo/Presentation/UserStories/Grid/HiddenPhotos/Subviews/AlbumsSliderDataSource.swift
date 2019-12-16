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
}

final class AlbumsSliderDataSource: NSObject {
    
    private let collectionView: UICollectionView
    private weak var delegate: AlbumsSliderDataSourceDelegate?
    
    private var items = [BaseDataSourceItem]()
    private(set) var selectedItems = [BaseDataSourceItem]() {
        didSet {
            delegate?.didChangeSelectionCount(selectedItems.count)
        }
    }
    
    private(set) var isSelectionMode = false
    private var isPaginationDidEnd = false
    
    //MARK: - Init
    
    required init(collectionView: UICollectionView, delegate: AlbumsSliderDataSourceDelegate?) {
        self.collectionView = collectionView
        self.delegate = delegate
        
        super.init()
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = UIColor.lrSkinTone
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(nibCell: SingleThumbnailAlbumCell.self)
        collectionView.allowsMultipleSelection = true
        collectionView.alwaysBounceVertical = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 90, height: 110)
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 0
        }
    }
    
    //MARK: - Shared methods

    func appendItems(_ newItems: [BaseDataSourceItem]) {
        if newItems.isEmpty {
            isPaginationDidEnd = true
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
}

//MARK: - UICollectionViewDataSource

extension AlbumsSliderDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: SingleThumbnailAlbumCell.self, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SingleThumbnailAlbumCell else {
            return
        }        
//        cell.setup(withItem: items[indexPath.item])
        
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
        let selectedItem = items[indexPath.item]
        
        if isSelectionMode {
            if !selectedItems.contains(selectedItem) {
                selectedItems.append(selectedItem)
            }
        } else {
            delegate?.didSelect(item: selectedItem)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard isSelectionMode else {
            return
        }
        
        let deSelectedItem = items[indexPath.item]
        selectedItems.remove(deSelectedItem)
    }
}
