//
//  UploadSelectionListCollectionManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 04.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation


final class UploadSelectionListCollectionManager: NSObject {
    private weak var collectionView: UICollectionView! {
        didSet {
            setupCollection()
        }
    }
    
    var items: [WrapData] {
        sortedItems.getArray()
    }
    
    
    private var sortedItems = SynchronizedArray<WrapData>()
    
    //MARK: - Public
    
    func reload() {
        sortItems { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    func reload(with items: [WrapData]) {
        sortedItems.replace(with: items) { [weak self] in
            self?.reload()
        }
    }
    
    func remove(item: WrapData) {
        guard let index = sortedItems.index(where: { $0 == item }) else {
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
    
    //MARK: - Private
    
    private func setupCollection() {
        DispatchQueue.toMain {
            self.collectionView.register(nibCell: UploadSelectionCell.self)
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
        }
    }
    
    private func sortItems(completion: @escaping VoidHandler) {
        //
    }
}

//MARK: - static
extension UploadSelectionListCollectionManager {
    static func with(collectionView: UICollectionView) -> UploadSelectionListCollectionManager {
        let manager = UploadSelectionListCollectionManager()
        manager.collectionView = collectionView
        return manager
    }
}


//MARK: - UICollectionViewDelegate
extension UploadSelectionListCollectionManager: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let item = sortedItems[indexPath.row], let cell =  cell as? UploadSelectionCell else {
            return
        }
        
        cell.setup(with: item)
        cell.delegate = self
    }
}

//MARK: - UICollectionViewDataSource
extension UploadSelectionListCollectionManager: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: UploadSelectionCell.self, for: indexPath)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedItems.count
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension UploadSelectionListCollectionManager: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.bounds.size.width - 40
        let height = UploadSelectionCell.height
        
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 22, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}


extension UploadSelectionListCollectionManager: UploadSelectionCellDelegate {
    func onRemoveTapped(cell: UploadSelectionCell) {
        guard let indexPath = collectionView.indexPath(for: cell), let item = sortedItems[indexPath.row] else {
            return
        }
        
        remove(item: item)
    }
}

