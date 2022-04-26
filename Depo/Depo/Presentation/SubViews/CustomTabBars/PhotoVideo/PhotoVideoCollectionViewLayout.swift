//
//  PhotoVideoCollectionViewLayout.swift
//  Depo
//
//  Created by Andrei Novikau on 4/16/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoVideoCollectionViewLayoutDelegate: AnyObject {
    func targetContentOffset() -> CGPoint?
}

final class PhotoVideoCollectionViewLayout: UICollectionViewFlowLayout {
    
    weak var delegate: PhotoVideoCollectionViewLayoutDelegate?
    
    let columns = Device.isIpad ? NumericConstants.numerCellInLineOnIpad : NumericConstants.numerCellInLineOnIphone
    
    private let padding: CGFloat = 1
    var sectionHedersPinToLayoutGuide: UILayoutGuide?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init() {
        super.init()
        setup()
    }

    private func setup() {
        let viewWidth = UIScreen.main.bounds.width
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        itemSize = CGSize(width: itemWidth, height: itemWidth)

        minimumInteritemSpacing = padding
        minimumLineSpacing = padding
        headerReferenceSize = CGSize(width: 0, height: 50)
    }

    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        
        guard collectionView?.isDragging == false, let contentOffset = delegate?.targetContentOffset() else {
            return
        }
        
        collectionView?.setContentOffset(contentOffset, animated: false)
    }

    override class var layoutAttributesClass: AnyClass { PhotoVideoCollectionViewLayoutAttributes.self }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return sectionHedersPinToLayoutGuide != nil
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let sectionHedersPinToLayoutGuide = sectionHedersPinToLayoutGuide else {
            return super.layoutAttributesForElements(in: rect)
        }

        var layoutAttributes = super.layoutAttributesForElements(in: rect) ?? []

        for index in getHeadersNeedingLayout(in: layoutAttributes) {
            let indexPath = IndexPath(item: 0, section: index)
            let attributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)
            layoutAttributes.append(attributes)
        }

        for attributes in layoutAttributes {
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                pinHeaderLayoutAttributes(attributes, to: sectionHedersPinToLayoutGuide)
            }
        }
        return layoutAttributes
    }

    private func getHeadersNeedingLayout(in layoutAttributes: [UICollectionViewLayoutAttributes]) -> IndexSet {
        var headersNeedingLayout = IndexSet()

        for attributes in layoutAttributes {
            if attributes.representedElementCategory == .cell {
                headersNeedingLayout.insert(attributes.indexPath.section)
            }
        }

        for attributes in layoutAttributes {
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                headersNeedingLayout.remove(attributes.indexPath.section)
            }
        }

        return headersNeedingLayout
    }

    private func pinHeaderLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes, to layoutGuide: UILayoutGuide) {
        guard let collectionView = collectionView else {
            return
        }

        let section = attributes.indexPath.section
        let firstIndexPath = IndexPath(item: 0, section: section)
        let lastIndexPath = IndexPath(item: collectionView.numberOfItems(inSection: section) - 1, section: section)

        guard
            let firstItemAttributes = layoutAttributesForItem(at: firstIndexPath),
            let lastItemAttributes = layoutAttributesForItem(at: lastIndexPath)
        else {
            return
        }

        let frame = attributes.frame
        let offset = collectionView.contentOffset.y + layoutGuide.layoutFrame.origin.y
        let minY = firstItemAttributes.frame.minY - frame.height
        let maxY = lastItemAttributes.frame.maxY - frame.height
        let y = min(max(offset, minY), maxY)
        attributes.frame.origin.y = y

        (attributes as? PhotoVideoCollectionViewLayoutAttributes)?.isPinned = y > minY && y < (maxY + frame.height)
    }
}
