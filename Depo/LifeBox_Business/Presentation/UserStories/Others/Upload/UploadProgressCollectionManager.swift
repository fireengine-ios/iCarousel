//
//  UploadProgressCollectionManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 01.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation


final class UploadProgressCollectionManager: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    private weak var collectionView: UICollectionView! {
        willSet {
            newValue.register(nibCell: UploadProgressCell.self)
            newValue.allowsSelection = false
            newValue.isScrollEnabled = true
            newValue.alwaysBounceVertical = true
            newValue.alwaysBounceHorizontal = false
            newValue.delegate = self
            newValue.dataSource = self
        }
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: UploadProgressCell.self, for: indexPath)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
}

extension UploadProgressCollectionManager {
    static func with(collectionView: UICollectionView) -> UploadProgressCollectionManager {
        let manager = UploadProgressCollectionManager()
        manager.collectionView = collectionView
        return manager
    }
}
