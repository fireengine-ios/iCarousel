//
//  UploadGalleryAssetPickerCollectionManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 29.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation


final class UploadGalleryAssetPickerCollectionManager: NSObject {
    private weak var collectionView: QuickSelectCollectionView?
    
    private var assets = SynchronizedArray<PHAsset>()
    
    
    init(collection: QuickSelectCollectionView) {
        super.init()
        
        collectionView = collection
        setupCollection()
    }
    
    
    //MARK: Public
    
    func reload(with items: [PHAsset]) {
        assets.replace(with: items) { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
        }
    }
    
    
    //MARK: Private
    private func setupCollection() {
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        collectionView?.register(nibCell: UploadGalleryAssetPickerCell.self)
        
        collectionView?.isQuickSelectAllowed = true
        collectionView?.alwaysBounceVertical = true
    }
    
}


//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension UploadGalleryAssetPickerCollectionManager: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: UploadGalleryAssetPickerCell.self, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? UploadGalleryAssetPickerCell, let asset = assets[indexPath.row] else {
            return
        }
        
        cell.setup(with: asset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension UploadGalleryAssetPickerCollectionManager: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfColumns = Device.isIpad ? NumericConstants.numerCellInLineOnIpad : NumericConstants.numerCellInLineOnIphone
        let sideInsets = collectionView.adjustedContentInset.left + collectionView.adjustedContentInset.right
        let horizonatlSpacing = Device.isIpad ? NumericConstants.iPadGreedHorizontalSpace : NumericConstants.iPhoneGreedHorizontalSpace
        let spacing = horizonatlSpacing * (numberOfColumns - 1)
        
        let side = (collectionView.bounds.size.width - sideInsets - spacing) / numberOfColumns
        
        return CGSize(width: side, height: side)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(topBottom: 0, rightLeft: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }

}
