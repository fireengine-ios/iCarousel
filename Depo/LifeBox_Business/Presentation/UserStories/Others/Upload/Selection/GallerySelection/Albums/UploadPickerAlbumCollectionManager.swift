//
//  UploadPickerAlbumCollectionManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 30.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

protocol UploadPickerAlbumCollectionManagerDelegate: class {
    func didSelectAlbum(with albumId: String)
}


final class UploadPickerAlbumCollectionManager: NSObject {
    
    private weak var collectionView: UICollectionView?
    
    private var albums = SynchronizedArray<LocalAlbumInfo>()
    
    weak var delegate: UploadPickerAlbumCollectionManagerDelegate?
    
    
    init(collection: UICollectionView, delegate: UploadPickerAlbumCollectionManagerDelegate) {
        super.init()
        
        self.delegate = delegate
        collectionView = collection
        setupCollection()
    }
    
    //MARK: Public
    func reload(with items: [LocalAlbumInfo]) {
        albums.replace(with: items) { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
        }
    }
    
    //MARK: Private
    private func setupCollection() {
        DispatchQueue.main.async {
            self.collectionView?.delegate = self
            self.self.collectionView?.dataSource = self
            
            self.collectionView?.register(nibCell: UploadPickerAlbumCell.self)
            
            self.collectionView?.alwaysBounceVertical = true
            self.collectionView?.allowsSelection = true
            self.collectionView?.allowsMultipleSelection = false
        }
    }
}


//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension UploadPickerAlbumCollectionManager: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: UploadPickerAlbumCell.self, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? UploadPickerAlbumCell, let album = albums[indexPath.row] else {
            return
        }
        
        cell.setup(with: album)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let album = albums[indexPath.row] else {
            return
        }
        
        delegate?.didSelectAlbum(with: album.identifier)
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension UploadPickerAlbumCollectionManager: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insets = collectionView.adjustedContentInset.left + collectionView.adjustedContentInset.right
        return CGSize(width: collectionView.bounds.size.width - insets, height: UploadPickerAlbumCell.height)
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
