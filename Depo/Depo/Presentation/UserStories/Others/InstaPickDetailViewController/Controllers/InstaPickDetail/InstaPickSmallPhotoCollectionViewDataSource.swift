//
//  InstaPickSmallPhotoCollectionViewDataSource.swift
//  Depo
//
//  Created by yilmaz edis on 16.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit

protocol InstaPickPhotoViewDelegate: AnyObject {
    func didTapOnImage(_ model: InstapickAnalyze?)
    func currentIndexWithScroll(index: Int)
}

class InstaPickSmallPhotoCollectionViewDataSource: UICollectionViewFlowLayout {
    
    var smallPhotos: [InstapickAnalyze] = []
    var currentIndex = 0
    
    weak var delegate: InstaPickPhotoViewDelegate?
    
    override init() {
        super.init()
        
        scrollDirection = .horizontal
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let numberOfCells = Array(0..<collectionView.numberOfSections)
            .map { collectionView.numberOfItems(inSection: $0) }
            .reduce(0, +)
        
        if numberOfCells >= 6 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        return UIEdgeInsets(top: 0, left: CGFloat((6 - numberOfCells) * 20), bottom: 0, right: 0)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        currentIndex = Int(abs(scrollView.contentOffset.x) / CGFloat(20))
        delegate?.currentIndexWithScroll(index: currentIndex)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension InstaPickSmallPhotoCollectionViewDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 41, height: 41)
    }
}

//MARK: - UICollectionViewDataSource
extension InstaPickSmallPhotoCollectionViewDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return smallPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: InstaPickSmallPhotoCell.self, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? InstaPickSmallPhotoCell {
            cell.configure(with: smallPhotos[indexPath.row])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didTapOnImage(smallPhotos[indexPath.item])
    }
}
