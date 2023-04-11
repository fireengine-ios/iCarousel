//
//  InstaPickHashtagCollectionViewDataSource.swift
//  Depo
//
//  Created by Raman Harhun on 1/15/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

///https://github.com/mischa-hildebrand/AlignedCollectionViewFlowLayout/blob/master/AlignedCollectionViewFlowLayout/Classes/AlignedCollectionViewFlowLayout.swift

class InstaPickHashtagCollectionViewDataSource: UICollectionViewFlowLayout {
    
    var hashtags: [String] = []
    
    private var contentWidth: CGFloat? {
        guard let collectionViewWidth = collectionView?.frame.size.width else {
            return nil
        }
        return collectionViewWidth - sectionInset.left - sectionInset.right
    }
    
    override func prepare() {
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
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

//MARK: - UICollectionViewDelegateFlowLayout
extension InstaPickHashtagCollectionViewDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let textHeight = NumericConstants.instaPickHashtagCellHeight
        let textFont = UIFont.TurkcellSaturaMedFont(size: 14)
        let width = hashtags[indexPath.row].width(for: textHeight, font: textFont) + NumericConstants.instaPickHashtagCellWidthConstant
        
        return CGSize(width: width, height: NumericConstants.instaPickHashtagCellHeight)
    }
}

//MARK: - UICollectionViewDataSource
extension InstaPickHashtagCollectionViewDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hashtags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: InstaPickHashtagCell.self, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? InstaPickHashtagCell {
            cell.configure(with: hashtags[indexPath.row], delegate: self)
        }
    }
}

//MARK: - InstaPickHashtagCellDelegate
extension InstaPickHashtagCollectionViewDataSource: InstaPickHashtagCellDelegate {
    func dismiss(cell: InstaPickHashtagCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else {
            return
        }
        
        hashtags.remove(at: indexPath.row)
        collectionView?.performBatchUpdates({ [weak self] in
            self?.collectionView?.deleteItems(at: [indexPath])
            }, completion: nil)
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
    
    func isRepresentingFirstItemInLine(collectionViewLayout: InstaPickHashtagCollectionViewDataSource) -> Bool {
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
    
    func isRepresentingLastItemInLine(collectionViewLayout: InstaPickHashtagCollectionViewDataSource) -> Bool {
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
    
    private func alignToPrecedingItem(collectionViewLayout: InstaPickHashtagCollectionViewDataSource) {
        
        if let precedingItemAttributes = collectionViewLayout.layoutAttributesForItem(at: precedingIndexPath) {
            frame.origin.x = precedingItemAttributes.frame.maxX
        }
    }
    
    private func alignToFollowingItem(collectionViewLayout: InstaPickHashtagCollectionViewDataSource) {
        
        if let followingItemAttributes = collectionViewLayout.layoutAttributesForItem(at: followingIndexPath) {
            frame.origin.x = followingItemAttributes.frame.minX - frame.size.width
        }
    }
    
    func alignHorizontally(collectionViewLayout: InstaPickHashtagCollectionViewDataSource) {
        if isRepresentingFirstItemInLine(collectionViewLayout: collectionViewLayout) {
            alignToLeft(with: collectionViewLayout.sectionInset)
        } else {
            alignToPrecedingItem(collectionViewLayout: collectionViewLayout)
        }
    }
}
