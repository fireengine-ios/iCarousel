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
    private let collectionFlowLayout = UploadGalleryAssetPickerCollectionLayout()
    
    private var assets = SynchronizedArray<PHAsset>()
    private lazy var thumbnailProvider = FilesDataSource()
    
    
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
                self?.collectionView?.refreshControl?.endRefreshing()
            }
        }
    }
    
    
    //MARK: Private
    private func setupCollection() {
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.collectionViewLayout = collectionFlowLayout
        
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
        cell.set(thumbnailProvider: thumbnailProvider)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? UploadGalleryAssetPickerCell, let asset = assets[indexPath.row] else {
            return
        }
        
        cell.setup(with: asset)
        
        if !cell.isSelected {
            let isAlreadySelected = UploadPickerAssetSelectionHelper.shared.has(identifier: asset.localIdentifier)
            if isAlreadySelected {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? UploadGalleryAssetPickerCell else {
            return
        }
        
        cell.onDidEndDisplaying()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = assets[indexPath.row] else {
            return
        }
        
        UploadPickerAssetSelectionHelper.shared.appendAsset(identifier: asset.localIdentifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let asset = assets[indexPath.row] else {
            return
        }
        
        UploadPickerAssetSelectionHelper.shared.removeAsset(identifier: asset.localIdentifier)
    }
    
}
