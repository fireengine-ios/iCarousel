//
//  BasicCollectionMultiFileDataSource.swift
//  Depo
//
//  Created by Aleksandr on 6/29/17.
//  Copyright © 2017 com.igones. All rights reserved.
//


class BasicCollectionMultiFileDataSource: NSObject, UICollectionViewDataSource {
    var multiFileModels: [[WrapData]]?//sorted array
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let multiFileModels = multiFileModels else {
            return 5//TEST
        }
        return multiFileModels.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "BasicCollectionMultiFileCell", for: indexPath)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SupplementaryLabelHeaderID", for: indexPath)
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        
//    }
    
    
//    func indexTitles(for collectionView: UICollectionView) -> [String]? {
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
//        
//    }
}
