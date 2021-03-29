//
//  UploadGalleryPickerCollectionManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 29.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation


final class UploadGalleryPickerCollectionManager: NSObject {
    private weak var collectionView: QuickSelectCollectionView?
    
    init(collection: QuickSelectCollectionView) {
        super.init()
        
        collectionView = collection
        
        setupCollection()
    }
    
    
    //MARK: Public
    
    func reload() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    
    //MARK: Private
    
    private func setupCollection() {
        collectionView?.delegate = self
        collectionView?.register(nibCell: UploadGalleryPickerCell.self)
        collectionView?.isQuickSelectAllowed = true
    }
}


extension UploadGalleryPickerCollectionManager {
    static func with(collection: QuickSelectCollectionView) -> UploadGalleryPickerCollectionManager {
        let manager = UploadGalleryPickerCollectionManager(collection: collection)
        return manager
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension UploadGalleryPickerCollectionManager: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: UICollectionViewCell.self, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension UploadGalleryPickerCollectionManager: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfColumns = Device.isIpad ? NumericConstants.numerCellInLineOnIpad : NumericConstants.numerCellInLineOnIphone
        let insetsWidth = NumericConstants.iPhoneGreedInset * (numberOfColumns - 1)
        let side = (collectionView.contentSize.width - insetsWidth) / numberOfColumns
        
        return CGSize(width: side, height: side)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let space = Device.isIpad ? NumericConstants.iPadGreedHorizontalSpace : NumericConstants.iPhoneGreedHorizontalSpace
        return space
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let space = Device.isIpad ? NumericConstants.iPadGreedHorizontalSpace : NumericConstants.iPhoneGreedHorizontalSpace
        return space
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: NumericConstants.iPhoneGreedInset, bottom: 0, right: NumericConstants.iPhoneGreedInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }

}
