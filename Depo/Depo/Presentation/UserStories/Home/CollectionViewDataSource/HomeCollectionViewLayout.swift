//
//  HomeCollectionViewLayout.swift
//  Depo
//
//  Created by Oleg on 26.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol CollectionViewLayoutDelegate: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat
    
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat
}

class HomeCollectionViewLayout: UICollectionViewLayout {
    
    weak var delegate: CollectionViewLayoutDelegate?
    
    var numberOfColumns = 1
    var cellPadding: CGFloat = 6.0
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    fileprivate var contentHeight: CGFloat = 0.0
    fileprivate var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)
    }
    
    override class var layoutAttributesClass: AnyClass {
        return UICollectionViewLayoutAttributes.self
    }
    
    var cellW: CGFloat = 0
    
    override func prepare() {
        cache.removeAll()
        if cache.isEmpty, let collectionView = collectionView, let delegate = delegate {
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            contentHeight = 0.0
            //To Do add sections
            let headerH = delegate.collectionView(collectionView: collectionView, heightForHeaderinSection: 0)
            let headerAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(row: 0, section: 0))
            headerAttribute.frame = CGRect(x: 0.0, y: 0.0, width: contentWidth, height: headerH)
            cache.append(headerAttribute)
            
            cellW = columnWidth
            var xOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth )
            }
            var column = 0
            var yOffset = [CGFloat](repeating: headerH, count: numberOfColumns)
            
            for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
                
                let indexPath = IndexPath(item: item, section: 0)
                
                let width = columnWidth - cellPadding * 2
                let cellHeight = delegate.collectionView(collectionView: collectionView, heightForCellAtIndexPath: indexPath, withWidth: width)
                let height = cellPadding + cellHeight + cellPadding
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                attributes.frame = insetFrame
                cache.append(attributes)
                
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                
                if (column >= (numberOfColumns - 1)) {
                    column = 0
                } else {
                    column = column + 1
                }
            }
        }
    }
    
    override var collectionViewContentSize: CGSize {
        //content size should be more then frame size because,  if content size will be less than frame scrolling will not work
        var calculatedContentHeight = contentHeight
        if let cView = collectionView {
            let minContentHeight = cView.frame.size.height + 1 - cView.contentInset.bottom - cView.contentInset.top
            if contentHeight < minContentHeight {
                calculatedContentHeight = minContentHeight
            }
        }
        
        return CGSize(width: contentWidth, height: calculatedContentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes  in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let headerAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: indexPath)
        let headerH = delegate?.collectionView(collectionView: collectionView!, heightForHeaderinSection: indexPath.section)
        headerAttribute.frame = CGRect(x: 0.0, y: 0.0, width: contentWidth, height: headerH ?? 0)
        return headerAttribute
    }
    
    func frameFor(indexPath: IndexPath) -> CGRect {
        for attrib in cache {
            if attrib.indexPath == indexPath {
                return attrib.frame
            }
        }
        return .zero
    }
}
