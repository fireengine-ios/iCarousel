//
//  InstaPickHashtagCollectionViewDataSource.swift
//  Depo
//
//  Created by Raman Harhun on 1/15/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class InstaPickCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    private var contentWidth: CGFloat? {
        guard let collectionViewWidth = collectionView?.frame.size.width else {
            return nil
        }
        return collectionViewWidth - sectionInset.left - sectionInset.right
    }
    
    //MARK: - UICollectionViewFlowLayout(override)
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }
        
        layoutAttributes.alignHorizontally(collectionViewLayout: self)
        
        return layoutAttributes
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributesObjects = copy(super.layoutAttributesForElements(in: rect))
        layoutAttributesObjects?.forEach({ (layoutAttributes) in
            setFrame(forLayoutAttributes: layoutAttributes)
        })
        return layoutAttributesObjects
    }
    
    //MARK: - UICollectionViewFlowLayout(private)
    private func setFrame(forLayoutAttributes layoutAttributes: UICollectionViewLayoutAttributes) {
        if layoutAttributes.representedElementCategory == .cell {
            let indexPath = layoutAttributes.indexPath
            if let newFrame = layoutAttributesForItem(at: indexPath)?.frame {
                layoutAttributes.frame = newFrame
            }
        }
    }
    
    fileprivate func originalLayoutAttribute(forItemAt indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.layoutAttributesForItem(at: indexPath)
    }
    
    fileprivate func isFrame(for firstItemAttributes: UICollectionViewLayoutAttributes,
                         inSameLineAsFrameFor secondItemAttributes: UICollectionViewLayoutAttributes) -> Bool {
        guard let lineWidth = contentWidth else {
            return false
        }
        
        let firstItemFrame = firstItemAttributes.frame
        let lineFrame = CGRect(x: sectionInset.left,
                               y: firstItemFrame.origin.y,
                               width: lineWidth,
                               height: firstItemFrame.size.height)
        return lineFrame.intersects(secondItemAttributes.frame)
    }
    
    private func layoutAttributes(forItemsInLineWith layoutAttributes: UICollectionViewLayoutAttributes) -> [UICollectionViewLayoutAttributes] {
        guard let lineWidth = contentWidth else {
            return [layoutAttributes]
        }
        var lineFrame = layoutAttributes.frame
        lineFrame.origin.x = sectionInset.left
        lineFrame.size.width = lineWidth
        return super.layoutAttributesForElements(in: lineFrame) ?? []
    }
    
    private func copy(_ layoutAttributesArray: [UICollectionViewLayoutAttributes]?) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributesArray?.map{ $0.copy() } as? [UICollectionViewLayoutAttributes]
    }
}

//MARK: - UICollectionViewLayoutAttributes
fileprivate extension UICollectionViewLayoutAttributes {
    private var currentSection: Int {
        return indexPath.section
    }
    
    private var currentItem: Int {
        return indexPath.item
    }
    
    private var precedingIndexPath: IndexPath {
        return IndexPath(item: currentItem - 1, section: currentSection)
    }
    
    private var followingIndexPath: IndexPath {
        return IndexPath(item: currentItem + 1, section: currentSection)
    }
    
    func isRepresentingFirstItemInLine(collectionViewLayout: InstaPickCollectionViewFlowLayout) -> Bool {
        if currentItem <= 0 {
            return true
        } else {
            if let layoutAttributesForPrecedingItem = collectionViewLayout.originalLayoutAttribute(forItemAt: precedingIndexPath) {
                return !collectionViewLayout.isFrame(for: self, inSameLineAsFrameFor: layoutAttributesForPrecedingItem)
            } else {
                return true
            }
        }
    }
    
    func isRepresentingLastItemInLine(collectionViewLayout: InstaPickCollectionViewFlowLayout) -> Bool {
        guard let itemCount = collectionViewLayout.collectionView?.numberOfItems(inSection: currentSection) else {
            return false
        }
        
        if currentItem >= itemCount - 1 {
            return true
        } else {
            if let layoutAttributesForFollowingItem = collectionViewLayout.originalLayoutAttribute(forItemAt: followingIndexPath) {
                return !collectionViewLayout.isFrame(for: self, inSameLineAsFrameFor: layoutAttributesForFollowingItem)
            } else {
                return true
            }
        }
    }
    
    func alignToLeft(with sectionInset: UIEdgeInsets) {
        frame.origin.x = sectionInset.left
    }
    
    private func alignToPrecedingItem(collectionViewLayout: InstaPickCollectionViewFlowLayout) {
        let itemSpacing = collectionViewLayout.minimumInteritemSpacing
        
        if let precedingItemAttributes = collectionViewLayout.layoutAttributesForItem(at: precedingIndexPath) {
            frame.origin.x = precedingItemAttributes.frame.maxX + itemSpacing
        }
    }
    
    private func alignToFollowingItem(collectionViewLayout: InstaPickCollectionViewFlowLayout) {
        let itemSpacing = collectionViewLayout.minimumInteritemSpacing
        
        if let followingItemAttributes = collectionViewLayout.layoutAttributesForItem(at: followingIndexPath) {
            frame.origin.x = followingItemAttributes.frame.minX - itemSpacing - frame.size.width
        }
    }
    
    func alignHorizontally(collectionViewLayout: InstaPickCollectionViewFlowLayout) {
        if isRepresentingFirstItemInLine(collectionViewLayout: collectionViewLayout) {
            alignToLeft(with: collectionViewLayout.sectionInset)
        } else {
            alignToPrecedingItem(collectionViewLayout: collectionViewLayout)
        }
    }
}
