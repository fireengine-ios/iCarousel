//
//  LBAlbumLikePreviewSliderDataSource.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 22.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol LBAlbumLikePreviewSliderDataSourceDelegate: class {
    func onItemSelected(item: SliderItem)
}

class LBAlbumLikePreviewSliderDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    internal weak var collectionView: UICollectionView?
    var allItems: [SliderItem] = []
    weak var delegate: LBAlbumLikePreviewSliderDataSourceDelegate?
    
    func setupCollectionView(collectionView: UICollectionView) {
        self.collectionView = collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(nibCell: AlbumCell.self)
    }
    
    func setCollectionView(items: [SliderItem]) {
        allItems = items
        reloadData()
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }        
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: AlbumCell.self, for: indexPath)
        
        let item = allItems[indexPath.item]
        cell.setup(withItem: item)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.onItemSelected(item: allItems[indexPath.item])
    }
    
}
