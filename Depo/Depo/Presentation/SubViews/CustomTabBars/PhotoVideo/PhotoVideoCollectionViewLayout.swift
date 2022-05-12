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

    let gridSize: GridSize
    var pinsSectionHeadersToLayoutGuide: UILayoutGuide?

    var columns: CGFloat { CGFloat(gridSize.rawValue) }
    private let padding: CGFloat = 1

    required init?(coder aDecoder: NSCoder) {
        gridSize = .four
        super.init(coder: aDecoder)
        setup()
    }
    
    override init() {
        gridSize = .four
        super.init()
        setup()
    }

    init(gridSize: GridSize) {
        self.gridSize = gridSize
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
        return pinsSectionHeadersToLayoutGuide != nil
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let pinsSectionHeadersToLayoutGuide = pinsSectionHeadersToLayoutGuide else {
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
                pinHeaderLayoutAttributes(attributes, to: pinsSectionHeadersToLayoutGuide)
            }
        }
        return layoutAttributes
    }

    override func layoutAttributesForSupplementaryView(
        ofKind elementKind: String,
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        guard elementKind == UICollectionView.elementKindSectionHeader else {
            return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        }

        let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        if let pinsSectionHeadersToLayoutGuide = pinsSectionHeadersToLayoutGuide,
           let attributes = attributes {
            pinHeaderLayoutAttributes(attributes, to: pinsSectionHeadersToLayoutGuide)
        }

        return attributes
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

        guard let attributes = attributes as? PhotoVideoCollectionViewLayoutAttributes else {
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

        let headerFrame = attributes.frame
        let pinOffset = collectionView.contentOffset.y + layoutGuide.layoutFrame.origin.y
        let minY = firstItemAttributes.frame.minY - headerFrame.height
        let maxY = lastItemAttributes.frame.maxY - headerFrame.height
        let y = min(max(pinOffset, minY), maxY)
        attributes.frame.origin.y = y

        attributes.isPinned = y > minY && y < lastItemAttributes.frame.maxY
    }
}

extension PhotoVideoCollectionViewLayout {
    enum GridSize: Int {
        case three = 3
        case four = 4
        case six = 6

        var next: GridSize? {
            switch self {
            case .three: return .four
            case .four: return .six
            case .six: return nil
            }
        }

        var previous: GridSize? {
            switch self {
            case .three: return nil
            case .four: return .three
            case .six: return .four
            }
        }
    }

}
