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
    
    private var cache = [UICollectionViewLayoutAttributes]()
    private var updateItems = [UICollectionViewUpdateItem]()

    private var cellPadding: CGFloat = 6.0
    private var contentHeight: CGFloat = 0.0
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override class var layoutAttributesClass: AnyClass {
        return UICollectionViewLayoutAttributes.self
    }
    
    var cellW: CGFloat = 0
    
    ///increase by one till end of columns count then reset
    private func changeColumn(_ column: inout Int) {
        if (column >= (numberOfColumns - 1)) {
            column = 0
        } else {
            column = column + 1
        }
    }

    override func prepare() {
        cache.removeAll()

        if cache.isEmpty, let collectionView = collectionView, let delegate = delegate {
            //To Do add sections
            let headerH = delegate.collectionView(collectionView: collectionView, heightForHeaderinSection: 0)
            let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                                                    with: IndexPath(row: 0, section: 0))
            headerAttributes.frame = CGRect(x: 0.0,
                                            y: 0.0,
                                            width: contentWidth,
                                            height: headerH)
            cache.append(headerAttributes)

            var column = 0
            var yOffset = Array(repeating: headerH, count: numberOfColumns)
            
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            let xOffset = (0 ..< numberOfColumns).map { columnWidth * CGFloat($0) }

            contentHeight = 0.0

            let paddings = cellPadding * 2
            for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)

                let width = columnWidth - paddings

                let cellHeight = delegate.collectionView(collectionView: collectionView, heightForCellAtIndexPath: indexPath, withWidth: width)
                let height = cellHeight + paddings

                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                    .insetBy(dx: cellPadding, dy: cellPadding)

                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                
                cache.append(attributes)

                debugPrint("attributes \(attributes)")

                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height

                changeColumn(&column)
            }

            debugPrint("attributes ----------------------------")
        }
    }

//    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
//        self.updateItems.removeAll()
//        self.updateItems.append(contentsOf: updateItems)
//
//        if !cache.isEmpty, let collectionView = collectionView, let delegate = delegate {
//            var column = 0
//
//            for updateItem in updateItems {
//                switch updateItem.updateAction {
//                case .delete:
//                    cache.remove(at: updateItem.indexPathBeforeUpdate?.row ?? 0)
//
//                case .insert, .reload:
//                    guard let indexPath = updateItem.indexPathAfterUpdate else {
//                        break
//                    }
//
//                    let columnWidth = contentWidth / CGFloat(numberOfColumns)
//                    cellW = columnWidth
//
//                    var xOffset = [CGFloat]()
//                    for column in 0 ..< numberOfColumns {
//                        xOffset.append(CGFloat(column) * columnWidth )
//                    }
//
//                    if (column >= (numberOfColumns - 1)) {
//                        column = 0
//                    } else {
//                        column = column + 1
//                    }
//
//                    let yOffset = cache[safe: indexPath.row]?.frame.maxY ?? 0
//
//                    let width = columnWidth - cellPadding * 2
//                    let cellHeight = delegate.collectionView(collectionView: collectionView, heightForCellAtIndexPath: indexPath, withWidth: width)
//                    let height = cellHeight + cellPadding * 2
//
//                    let frame = CGRect(x: xOffset[column], y: yOffset, width: columnWidth, height: height)
//                        .insetBy(dx: cellPadding, dy: cellPadding)
//
//                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//
//                    attributes.frame = frame
//                    cache.insert(attributes, at: indexPath.row)
//
//                    contentHeight = max(contentHeight, frame.maxY)
//
//                case .move:
//                    guard let before = updateItem.indexPathBeforeUpdate, let after = updateItem.indexPathAfterUpdate else {
//                        break
//                    }
//
//                    cache.swapAt(before.row, after.row)
//
//                case .none: break
//                }
//            }
//        }
//    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
                
        updateItems.forEach {
            switch $0.updateAction {
            case .delete:
                guard let indexPath = $0.indexPathBeforeUpdate, itemIndexPath == indexPath else {
                    break
                }
                
                attributes?.alpha = 0
                attributes?.transform = CGAffineTransform(scaleX: 1, y: 0)

            case .insert:
                guard let indexPath = $0.indexPathAfterUpdate, let frame = cache[safe: indexPath.row]?.frame, indexPath == itemIndexPath else {
                    break
                }
                
                attributes?.alpha = 0
                attributes?.transform = CGAffineTransform(translationX: cellPadding, y: frame.height)
                
            default: break
            }
        }
        
        return attributes
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        
        self.updateItems.removeAll()
    }
    
    override var collectionViewContentSize: CGSize {
        //content size should be more then frame size because, if content size will be less than frame scrolling will not work
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
        return cache.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[safe: indexPath.row]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let headerAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: indexPath)
        let headerH = delegate?.collectionView(collectionView: collectionView!, heightForHeaderinSection: indexPath.section)
        headerAttribute.frame = CGRect(x: 0.0, y: 0.0, width: contentWidth, height: headerH ?? 0)
        return headerAttribute
    }
    
    func frameFor(indexPath: IndexPath) -> CGRect {
        guard let attribute = cache.first(where: { $0.indexPath == indexPath }) else {
            return .zero
        }
        
        return attribute.frame
    }
}
