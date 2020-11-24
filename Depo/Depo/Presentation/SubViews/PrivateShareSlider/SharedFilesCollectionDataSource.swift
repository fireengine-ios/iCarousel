//
//  SharedFilesCollectionDataSource.swift
//  Depo
//
//  Created by Alex Developer on 24.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol SharedFilesCollectionDataSourceDelegate: class {
    func cellTouched()
    
}

final class SharedFilesCollectionDataSource: NSObject {
    weak var delegate: SharedFilesCollectionDataSourceDelegate?
}

extension SharedFilesCollectionDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension SharedFilesCollectionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeue(cell: SharedFilesSliderCell.self, for: indexPath)
    }
}
