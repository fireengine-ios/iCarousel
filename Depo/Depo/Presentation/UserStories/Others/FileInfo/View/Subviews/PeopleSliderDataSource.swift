//
//  PeopleSliderDataSource.swift
//  Depo
//
//  Created by Raman Harhun on 5/13/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol PeopleSliderDataSourceDelegate: class {
    func didSelect(item: PeopleOnPhotoItemResponse)
    func needLoadNextPage()
    func onStartSelection()
}

final class PeopleSliderDataSource: NSObject {
    
    private let collectionView: UICollectionView
    private weak var delegate: PeopleSliderDataSourceDelegate?
    
    private(set) var items = [PeopleOnPhotoItemResponse]()
    
    private(set) var isSelectionActive = false
    var isPaginationDidEnd = false
    
    //MARK: - Init
    
    required init(collectionView: UICollectionView, delegate: PeopleSliderDataSourceDelegate?) {
        self.collectionView = collectionView
        self.delegate = delegate
        
        super.init()
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(nibCell: PeopleCollectionViewCell.self)
        collectionView.allowsMultipleSelection = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 100, height: 130)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 16
        }
    }
    
    //MARK: - Shared methods

    func appendItems(_ newItems: [PeopleOnPhotoItemResponse]) {
        if newItems.isEmpty {
            if !isPaginationDidEnd {
                delegate?.needLoadNextPage()
            }
            return
        }

        if items.isEmpty {
            items = newItems
            collectionView.reloadData()
        } else {
            let insertItems = newItems.filter { !items.contains($0) }
            
            if insertItems.isEmpty {
                collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
                return
            }
            
            let startIndex = items.count
            let endIndex = startIndex + insertItems.count - 1
           
            items.append(contentsOf: insertItems)
           
            let indexPaths = (startIndex...endIndex).map { IndexPath(item: $0, section: 0) }
            
            collectionView.performBatchUpdates({
                collectionView.insertItems(at: indexPaths)
            }, completion: { [weak self] _ in
                self?.checkLoadNextPage(for: self?.collectionView.indexPathsForVisibleItems.sorted().last)
            })
        }
    }
    
    func reset() {
        items.removeAll()
        isPaginationDidEnd = false
        collectionView.reloadData()
    }
}

//MARK: - UICollectionViewDataSource

extension PeopleSliderDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: PeopleCollectionViewCell.self, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard
            let cell = cell as? PeopleCollectionViewCell,
            let item = items[safe: indexPath.row] else {
                assertionFailure()
                return
        }
        
        cell.setup(with: item)
        checkLoadNextPage(for: indexPath)
    }
    
    private func checkLoadNextPage(for indexPath: IndexPath?) {
        guard !isPaginationDidEnd, let indexPath = indexPath else {
            return
        }
        
        let countRow = self.collectionView(collectionView, numberOfItemsInSection: 0)
        if indexPath.row == countRow - 1 {
            delegate?.needLoadNextPage()
        }
    }
}

//MARK: - UICollectionViewDelegate

extension PeopleSliderDataSource: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(">>>>", indexPath)
        guard let selectedItem = items[safe: indexPath.row] else {
            return
        }
        delegate?.didSelect(item: selectedItem)
    }
}
