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
    
    private var sortedItems = SynchronizedArray<UploadProgressItem>()
    
    //MARK: - Public
    
    func clean() {
        sortedItems.removeAll { [weak self] _ in
            self?.reload()
        }
    }
    
    func reload() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
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
    
    func remove(items: [UploadProgressItem]) {
        let group = DispatchGroup()
        items.forEach { itemToRemove in
            group.enter()
            sortedItems.remove { existingItem in
                existingItem.item == itemToRemove.item
            } completion: {  _ in
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.reload()
        }
    }
    
    func update(item: UploadProgressItem) {
        let itemToUpdate = sortedItems.first { existingItem in
            existingItem.item == item.item
        }
        itemToUpdate?.set(status: item.status)
        reload()
    }
    
    //MARK: - Private
    
    private func setupCollection() {
        DispatchQueue.toMain {
            self.collectionView.register(nibCell: UploadProgressCell.self)
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
        }
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
