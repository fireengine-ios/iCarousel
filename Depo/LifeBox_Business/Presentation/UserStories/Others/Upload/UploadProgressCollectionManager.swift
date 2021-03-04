//
//  UploadProgressCollectionManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 01.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation


final class UploadProgressCollectionManager: NSObject {
    private weak var collectionView: UICollectionView! {
        didSet {
            setupCollection()
        }
    }
    
    var numberOfItems: Int {
        return sortedItems.count
    }
    
    
    private var sortedItems = SynchronizedArray<UploadProgressItem>()
    
    //MARK: - Public
    
    func clean() {
        sortedItems.removeAll { [weak self] _ in
            self?.reload()
        }
    }
    
    func reload() {
        sortItems { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    func reload(with items: [UploadProgressItem]) {
        sortedItems.replace(with: items) { [weak self] in
            self?.reload()
        }
    }
    
    func append(items: [UploadProgressItem]) {
        sortedItems.append(items)
        reload()
    }
    
    func remove(item: UploadProgressItem) {
        guard let index = sortedItems.index(where: { $0.item == item.item }) else {
            return
        }
        
        sortedItems.safeRemove(at: index) { [weak self] removedItem in
            let indexPath = IndexPath(row: index, section: 0)
            self?.collectionView.performBatchUpdates {
                self?.collectionView.deleteItems(at: [indexPath])
            } completion: { _ in
                //
            }
        }
    }
    
    func update(item: UploadProgressItem) {
        let itemToUpdate = sortedItems.first { existingItem in
            existingItem.item == item.item
        }
        itemToUpdate?.set(status: item.status)
        reload()
    }
    
    func setProgress(item: UploadProgressItem, ratio: Float) {
        guard
            let index = sortedItems.index(where: { $0.item == item.item }),
            let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? UploadProgressCell
        else {
            return
        }
        
        cell.set(ratio: ratio)
    }
    
    //MARK: - Private
    
    private func setupCollection() {
        DispatchQueue.toMain {
            self.collectionView.register(nibCell: UploadProgressCell.self)
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
        }
    }
    
    private func sortItems(completion: @escaping VoidHandler) {
        sortedItems.sortItself(by: UploadProgressItem.Comparison.ascending, completion: completion)
    }
}

//MARK: - static
extension UploadProgressCollectionManager {
    static func with(collectionView: UICollectionView) -> UploadProgressCollectionManager {
        let manager = UploadProgressCollectionManager()
        manager.collectionView = collectionView
        return manager
    }
}


//MARK: - UICollectionViewDelegate
extension UploadProgressCollectionManager: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let item = sortedItems[indexPath.row], let cell =  cell as? UploadProgressCell else {
            return
        }
        
        cell.setup(with: item)
        cell.delegate = self
    }
}

//MARK: - UICollectionViewDataSource
extension UploadProgressCollectionManager: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: UploadProgressCell.self, for: indexPath)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedItems.count
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension UploadProgressCollectionManager: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.bounds.size.width
        let height = UploadProgressCell.height
        
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 22, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}


extension UploadProgressCollectionManager: UploadProgressCellDelegate {
    func onRemoveTapped(cell: UploadProgressCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }

        if let itemToRemove = sortedItems[indexPath.row]?.item {
            UploadProgressManager.shared.remove(item: itemToRemove)
        }
    }
}
