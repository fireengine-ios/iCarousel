//
//  GalleryCollectionViewLayout.swift
//  Depo
//
//  Created by Andrei Novikau on 4/16/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol GalleryCollectionViewLayoutDelegate: AnyObject {
    func targetContentOffset() -> CGPoint?
}

final class GalleryCollectionViewLayout: UICollectionViewLayout {

    required init?(coder aDecoder: NSCoder) {
        gridSize = .three
        super.init(coder: aDecoder)
    }

    override init() {
        gridSize = .three
        super.init()
    }

    init(gridSize: GalleryCollectionGridSize) {
        self.gridSize = gridSize
        super.init()
    }

    weak var delegate: GalleryCollectionViewLayoutDelegate?

    let gridSize: GalleryCollectionGridSize
    var pinsSectionHeadersToLayoutGuide: UILayoutGuide?
    var columns: CGFloat {
        CGFloat(gridSize.rawValue)
    }
    
    var graceBannerState: Bool = false
    var graceBannerHeight: CGFloat = 150

    private let itemSpacing: CGFloat = 1
    var cache: [IndexPath: GalleryCollectionViewLayoutAttributes] = [:]
    private var headerCache: [Int: GalleryCollectionViewLayoutAttributes] = [:]
    private let userDefaults = UserDefaultsVars()
    private var lastCallPrepare: Bool = false

    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
        CGSize(width: contentWidth, height: contentHeight)
    }

    override class var layoutAttributesClass: AnyClass {
        GalleryCollectionViewLayoutAttributes.self
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        pinsSectionHeadersToLayoutGuide != nil
    }

    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()

        guard collectionView?.isDragging == false, let contentOffset = delegate?.targetContentOffset() else {
            return
        }

        collectionView?.setContentOffset(contentOffset, animated: false)
    }

    private var isTransitioning = false

    override func prepareForTransition(to newLayout: UICollectionViewLayout) {
        super.prepareForTransition(to: newLayout)
        isTransitioning = true
    }

    override func prepareForTransition(from oldLayout: UICollectionViewLayout) {
        super.prepareForTransition(from: oldLayout)
        isTransitioning = true
    }

    override func finalizeLayoutTransition() {
        super.finalizeLayoutTransition()
        isTransitioning = false
    }
       
    private func setStartTime() {
        let time = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:ss"
        timeFormatter.timeStyle = .short
        _ = timeFormatter.string(from: time)
        userDefaults.isPhotosScreenTime = time
    }
    
    private func diffInTime() -> TimeInterval {
        let timex = userDefaults.isPhotosScreenTime
        let currentTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:ss"
        let diffinSeconds = currentTime.timeIntervalSinceReferenceDate - (timex as AnyObject).timeIntervalSinceReferenceDate
        return diffinSeconds
    }
    
    @objc func callCalculate() {
        calculateCollectionViewHeaderAndContent()
    }
    
    override func prepare() {
        let isPrepairing = CacheManager.shared.isProcessing
        if isPrepairing {
            if cache.isEmpty || diffInTime() >= 10.0  {
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(callCalculate),
                                                       name: .isProcecessPrepairing,
                                                       object: nil)
                setStartTime()
                DispatchQueue.main.async {
                    self.calculateCollectionViewHeaderAndContent()
                }
                lastCallPrepare = true
            }
        } else {
            if cache.isEmpty || lastCallPrepare {
                DispatchQueue.main.async {
                    self.calculateCollectionViewHeaderAndContent()
                }
                lastCallPrepare = false
            }
        }
    }
    
    private func calculateCollectionViewHeaderAndContent() {
        guard let collectionView = self.collectionView, collectionView.numberOfSections > 0 else {
            cache = [:]
            headerCache = [:]
            contentHeight = 0
            return
        }
        
        cache = [:]
        headerCache = [:]
        
        contentHeight = 0
        let itemSize = (contentWidth - (columns - 1) * itemSpacing) / columns
        
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0

        for section in 0..<collectionView.numberOfSections {
            xOffset = 0
            yOffset = contentHeight
            
            let headerAttributes = GalleryCollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                with: IndexPath(item: 0, section: section)
            )
            headerAttributes.zIndex = 1000
            headerCache[section] = headerAttributes
            headerAttributes.frame = CGRect(x: 0, y: yOffset, width: contentWidth, height: section == 0 && graceBannerState ? graceBannerHeight + 50 : 50)
            contentHeight = max(headerAttributes.frame.maxY, contentHeight)
            yOffset = headerAttributes.frame.maxY
            
            var currentXBoundary: CGFloat?
            var currentXBoundarySpans = 1
            
            var nextXStartBoundary: CGFloat?
            for index in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: index, section: section)
                //let columnSpan = CGFloat(columnSpanForItem(at: indexPath))
                let columnSpan = CGFloat(1.0)
                let currentItemSize = itemSize * columnSpan + itemSpacing * (columnSpan - 1)
                
                let attributes = GalleryCollectionViewLayoutAttributes(forCellWith: indexPath)
                cache[indexPath] = attributes
                
                attributes.isSpanned = columnSpan > 1
                attributes.frame = CGRect(
                    x: xOffset,
                    y: yOffset,
                    width: currentItemSize,
                    height: currentItemSize
                )
                contentHeight = max(attributes.frame.maxY, contentHeight)
                
                let endOfLine = currentXBoundary ?? contentWidth
                if itemSize > (endOfLine - attributes.frame.maxX) {
                    let nextLineOffset = columnSpan == 1
                    ? attributes.frame.maxY
                    : attributes.frame.maxY - (attributes.frame.height - itemSize)
                    
                    yOffset = nextLineOffset + itemSpacing
                    xOffset = nextXStartBoundary ?? 0
                    
                    nextXStartBoundary = nil
                    
                    if currentXBoundary == endOfLine {
                        currentXBoundarySpans -= 1
                        if currentXBoundarySpans == 1 {
                            currentXBoundary = nil
                        }
                    }
                } else {
                    xOffset = attributes.frame.maxX + itemSpacing
                }
                
                if columnSpan > 1 && ceil(attributes.frame.maxX) < contentWidth {
                    nextXStartBoundary = attributes.frame.maxX + itemSpacing
                } else if columnSpan > 1 {
                    currentXBoundary = attributes.frame.minX - itemSpacing
                    currentXBoundarySpans = Int(columnSpan)
                }
            }
        }
    }
    
    private func columnSpanForItem(at indexPath: IndexPath) -> Int {
        let itemNumber = indexPath.item + 1
        switch gridSize {
        case .three:
            let isSpanned = itemNumber % 18 == 8 || itemNumber % 18 == 16
            return isSpanned ? 2 : 1
        case .four:
            let isSpanned = itemNumber % 26 == 11 || itemNumber % 26 == 22
            return isSpanned ? 2 : 1
        case .six:
            let isSpanned = itemNumber % 42 == 17 || itemNumber % 42 == 34
            return isSpanned ? 2 : 1
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var result: [GalleryCollectionViewLayoutAttributes] = []
        var headersNeedingLayout = IndexSet()

        for (indexPath, attributes) in cache {
            if rect.intersects(attributes.frame){
                result.append(attributes)
                headersNeedingLayout.insert(indexPath.section)
            }
        }

        let headersAttributes = headersNeedingLayout.compactMap { section in
            headerCache[section]
        }

        if let pinsSectionHeadersToLayoutGuide = pinsSectionHeadersToLayoutGuide {
            for attributes in headersAttributes {
                if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                    pinHeaderLayoutAttributes(attributes, to: pinsSectionHeadersToLayoutGuide)
                }
            }
        }

        return headersAttributes + result
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath]
    }

    override func layoutAttributesForSupplementaryView(
        ofKind elementKind: String,
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        guard elementKind == UICollectionView.elementKindSectionHeader else {
            return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        }

        let attributes = headerCache[indexPath.section]
        if let pinsSectionHeadersToLayoutGuide = pinsSectionHeadersToLayoutGuide,
           let attributes = attributes {
            pinHeaderLayoutAttributes(attributes, to: pinsSectionHeadersToLayoutGuide)
        }

        return attributes
    }

    func getCalculatedHeight(for section: Int) -> CGFloat {
        guard let collectionView = self.collectionView else {
            return .zero
        }

        let numberOfItemsInSection = collectionView.numberOfItems(inSection: section)

        guard numberOfItemsInSection > 0 else {
            return .zero
        }

        let headerFrame = layoutAttributesForSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: section)
        )?.frame ?? .zero

        let firstItemIndex = 0
        let fisrtItemFrame = layoutAttributesForItem(at: IndexPath(item: firstItemIndex, section: section))?.frame ?? .zero

        let lastItemIndex = numberOfItemsInSection - 1
        let lastItemFrame = layoutAttributesForItem(at: IndexPath(item: lastItemIndex, section: section))?.frame ?? .zero

        let sectionHeightWithoutHeader = lastItemFrame.maxY - fisrtItemFrame.minY
        return max(0, sectionHeightWithoutHeader + headerFrame.height)
    }

    private func pinHeaderLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes, to layoutGuide: UILayoutGuide) {
        guard let collectionView = collectionView else {
            return
        }

        guard !isTransitioning else {
            return
        }

        guard let attributes = attributes as? GalleryCollectionViewLayoutAttributes else {
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
        let pinOffset = collectionView.contentOffset.y + layoutGuide.layoutFrame.origin.y + headerFrame.height
        let minY = firstItemAttributes.frame.minY - headerFrame.height
        let maxY = lastItemAttributes.frame.maxY - headerFrame.height
        let y = min(max(pinOffset, minY), maxY)
        attributes.frame.origin.y = y

        attributes.isPinned = y > minY && y < lastItemAttributes.frame.maxY
    }
}
