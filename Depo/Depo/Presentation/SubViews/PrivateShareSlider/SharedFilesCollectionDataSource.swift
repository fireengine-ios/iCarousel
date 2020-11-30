//
//  SharedFilesCollectionDataSource.swift
//  Depo
//
//  Created by Alex Developer on 24.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol SharedFilesCollectionDataSourceDelegate: class {
    func cellTouched(withModel: WrapData)
    
}

final class SharedFilesCollectionDataSource: NSObject {
    weak var delegate: SharedFilesCollectionDataSourceDelegate?
    
    private(set) var files = [WrapData]()
    
    func setup(files: [WrapData]) {
        self.files = files
    }
}

extension SharedFilesCollectionDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard
            let cell = cell as? SharedFilesSliderCell,
            let relatedEntity = files[safe: indexPath.row] //this is one section collection
        else {
            return
        }
        
        cell.setup(item: relatedEntity)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let relatedEntity = files[safe: indexPath.row] //this is one section collection
        else {
            return
        }
        delegate?.cellTouched(withModel: relatedEntity)
    }
}

extension SharedFilesCollectionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return files.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeue(cell: SharedFilesSliderCell.self, for: indexPath)
    }
}

extension SharedFilesCollectionDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 122)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 22
    }
}
