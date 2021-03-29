//
//  UploadSelectionListCollectionManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 04.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

protocol UploadSelectionListCollectionManagerDelegate: class {
    func onItemRemoved(isLast: Bool)
}

final class UploadSelectionListCollectionManager: NSObject {
    private weak var collectionView: UICollectionView! {
        didSet {
            setupCollection()
        }
    }
    
    private weak var gradientView: ScrollGradientView!
    
    var items: [WrapData] {
        sortedItems.getArray()
    }
    
    let spaceBetweenRows: CGFloat = 5
    let rowInset = UIEdgeInsets(top: 0, left: 20, bottom: 22, right: 20)
    private var sortedItems = SynchronizedArray<WrapData>()
    
    weak var delegate: UploadSelectionListCollectionManagerDelegate?
    
    //MARK: - Public
    
    func reload(with items: [WrapData]) {
        sortItems(items: items) { [weak self] in
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
                self?.delegate?.onItemRemoved(isLast: self?.sortedItems.isEmpty == true)
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
    
    private func reload() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func sortItems(items: [WrapData], completion: @escaping VoidHandler) {
        let notVideos = items.filter { $0.fileType != .video }.sorted(by: { $0.creationDate ?? Date() > $1.creationDate ?? Date() })
        let videos = items.filter { $0.fileType == .video }.sorted(by: { $0.fileSize < $1.fileSize})
        let resultItems = notVideos + videos
        
        sortedItems.replace(with: resultItems, completion: completion)
    }
}

//MARK: - Static
extension UploadSelectionListCollectionManager {
    static func with(collectionView: UICollectionView, gradientView: ScrollGradientView, delegate: UploadSelectionListCollectionManagerDelegate) -> UploadSelectionListCollectionManager {
        let manager = UploadSelectionListCollectionManager()
        manager.delegate = delegate
        manager.collectionView = collectionView
        manager.gradientView = gradientView
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
        
        let width = collectionView.bounds.size.width - (rowInset.left + rowInset.right)
        let height = UploadSelectionCell.height
        
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return rowInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenRows
    }
}


extension UploadSelectionListCollectionManager: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0, scrollView.contentSize.height > scrollView.frame.size.height {
            gradientView.showAnimated()
        } else {
            gradientView.hideAnimated()
        }
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

