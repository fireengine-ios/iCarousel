//
//  SwipeSelectingCollectionView.swift
//  TileTime
//
//  Created by Shane Qi on 7/2/17.
//  Copyright © 2017 Shane Qi. All rights reserved.
//

import UIKit

protocol SwipeSelectingCollectionViewDelegate: class {
    func didLongPress(at indexPath: IndexPath?)
}

public class SwipeSelectingCollectionView: UICollectionView {
    
    weak var longPressDelegate: SwipeSelectingCollectionViewDelegate?
    
    private var beginIndexPath: IndexPath?
    private var selectingRange: ClosedRange<IndexPath>?
    private var selectingMode: SelectingMode = .selecting
    private var selectingIndexPaths = Set<IndexPath>()
    private var isAutoStartScroll = false
    private var autoScrollSpeed: CGFloat = 3
    private var autoScrollDirection: AutoScrollDirection?
    private enum AutoScrollDirection {
        case up, down
    }
    private enum SelectingMode {
        case selecting, deselecting
    }
    
    var isSelectionMode = false
    private var scrollSpeed: CGFloat = 0
    private var isScrolling = false
    
    private static let autoscrollOffset: CGFloat = 0.2
    private var topAutoscrollInset = UIScreen.main.bounds.height * SwipeSelectingCollectionView.autoscrollOffset
    private var bottomAutoscrollInset = UIScreen.main.bounds.height * (1 - SwipeSelectingCollectionView.autoscrollOffset)
    
    lazy private var longPressRecognizer: SwipeSelectingGestureRecognizer = {
        let recognizer = SwipeSelectingGestureRecognizer(target: self, action: #selector(didPanSelectingGestureRecognizerChange(_:)))
        recognizer.minimumPressDuration = 0.15
        recognizer.delaysTouchesBegan = true
        return recognizer
    }()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        gestureRecognizers?.append(longPressRecognizer)
        allowsMultipleSelection = true
    }
    
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        gestureRecognizers?.append(longPressRecognizer)
        allowsMultipleSelection = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let superview = superview else {
            return
        }
        topAutoscrollInset = superview.bounds.height * SwipeSelectingCollectionView.autoscrollOffset
        bottomAutoscrollInset = superview.bounds.height * (1 - SwipeSelectingCollectionView.autoscrollOffset)
    }
    
    @objc private func didPanSelectingGestureRecognizerChange(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)
        switch gestureRecognizer.state {
        case .began:
            self.beginIndexPath = indexPathForItem(at: point)
            longPressDelegate?.didLongPress(at: self.beginIndexPath)
            if isSelectionMode, let indexPath = beginIndexPath,
                let isSelected = cellForItem(at: indexPath)?.isSelected {
                selectingMode = (isSelected ? .deselecting : .selecting)
                setSelection(!isSelected, indexPath: indexPath)
            } else { selectingMode = .selecting }
            isScrollEnabled = false
        case .changed:
            handleChangeOf(gestureRecognizer: gestureRecognizer)
        default:
            isAutoStartScroll = false
            beginIndexPath = nil
            selectingRange = nil
            selectingIndexPaths.removeAll()
            isScrollEnabled = true
        }
    }
    
    @objc private func startScroll() {
        guard !isScrolling, isAutoStartScroll, scrollSpeed != 0 else {
            return
        }
        isScrolling = true
        UIView.animate(withDuration: 0.1, animations: {
            var targetY = self.contentOffset.y + self.scrollSpeed
            targetY = max(0, targetY)
            targetY = min(self.contentSize.height - self.bounds.height, targetY)
            self.contentOffset = CGPoint(x: 0, y: targetY)
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            self.isScrolling = false
            self.startScroll()
        })
    }
    
    private func handleChangeOf(gestureRecognizer: UILongPressGestureRecognizer) {
        guard let superview = self.superview else {
            return
        }
        
        let screenPoint = gestureRecognizer.location(in: superview)
        if screenPoint.y < topAutoscrollInset {
            autoScrollDirection = .up
            isAutoStartScroll = true
            scrollSpeed = -speed(at: topAutoscrollInset - screenPoint.y)
            startScroll()
        } else if screenPoint.y > bottomAutoscrollInset {
            autoScrollDirection = .down
            isAutoStartScroll = true
            scrollSpeed = speed(at: screenPoint.y - bottomAutoscrollInset)
            startScroll()
        } else {
            isAutoStartScroll = false
            scrollSpeed = 0
        }
        
        let point = gestureRecognizer.location(in: self)
        
        guard
            var beginIndexPath = beginIndexPath,
            var endIndexPath = indexPathForItem(at: point)
        else {
            return
        }
        
        if endIndexPath < beginIndexPath {
            swap(&beginIndexPath, &endIndexPath)
        }
        let range = ClosedRange(uncheckedBounds: (beginIndexPath, endIndexPath))
        guard range != selectingRange else {
            return
        }
        
        var positiveIndexPaths = [IndexPath]()
        var negativeIndexPaths = [IndexPath]()
        
        if let selectingRange = selectingRange {
            switch (range.lowerBound, range.upperBound) {
            case (selectingRange.lowerBound, let upperBound) where upperBound < selectingRange.upperBound:
                let neagtiveRange = ClosedRange(uncheckedBounds: (upperBound, selectingRange.upperBound))
                negativeIndexPaths = indexPaths(in: neagtiveRange)
                negativeIndexPaths.removeFirst()
                
            case (selectingRange.lowerBound, let upperBound) where upperBound > selectingRange.upperBound:
                let positiveRange = ClosedRange(uncheckedBounds: (selectingRange.upperBound, upperBound))
                positiveIndexPaths = indexPaths(in: positiveRange)
                
            case (let lowerBound, selectingRange.upperBound) where lowerBound > selectingRange.lowerBound:
                let negativeRange = ClosedRange(uncheckedBounds: (selectingRange.lowerBound, lowerBound))
                negativeIndexPaths = indexPaths(in: negativeRange)
                negativeIndexPaths.removeLast()
                
            case (let lowerBound, selectingRange.upperBound) where lowerBound < selectingRange.lowerBound:
                let positiveRange = ClosedRange(uncheckedBounds: (lowerBound, selectingRange.lowerBound))
                positiveIndexPaths = indexPaths(in: positiveRange)
                
            default:
                negativeIndexPaths = indexPaths(in: selectingRange)
                positiveIndexPaths = indexPaths(in: range)
            }
            
        } else {
            positiveIndexPaths = indexPaths(in: range)
        }
        
        for indexPath in negativeIndexPaths {
            doSelection(at: indexPath, isPositive: false)
        }
        for indexPath in positiveIndexPaths {
            doSelection(at: indexPath, isPositive: true)
        }
        selectingRange = range
    }
    
    private func speed(at pointHeight: CGFloat) -> CGFloat {
        return autoScrollSpeed * pointHeight
    }
    
    private func doSelection(at indexPath: IndexPath, isPositive: Bool) {
        // Ignore the begin index path, it's already taken care of when the gesture recognizer began.
        guard indexPath != beginIndexPath else { return }
        guard let isSelected = cellForItem(at: indexPath)?.isSelected else { return }
        let expectedSelection: Bool = {
            switch selectingMode {
            case .selecting: return isPositive
            case .deselecting: return !isPositive
            }
        } ()
        
        if isSelected != expectedSelection {
            if isPositive {
                selectingIndexPaths.insert(indexPath)
            }
            if selectingIndexPaths.contains(indexPath) {
                setSelection(expectedSelection, indexPath: indexPath)
                if !isPositive {
                    selectingIndexPaths.remove(indexPath)
                }
            }
        }
    }
    
    private func setSelection(_ selected: Bool, indexPath: IndexPath) {
        switch selected {
        case true:
            selectItem(at: indexPath, animated: false, scrollPosition: [])
            delegate?.collectionView?(self, didSelectItemAt: indexPath)
        case false:
            deselectItem(at: indexPath, animated: false)
            delegate?.collectionView?(self, didDeselectItemAt: indexPath)
        }
    }
    
    private func indexPaths(in range: ClosedRange<IndexPath>) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        let beginSection = range.lowerBound.section
        let endSection = range.upperBound.section
        guard beginSection != endSection else {
            for row in range.lowerBound.row...range.upperBound.row {
                indexPaths.append(IndexPath(row: row, section: beginSection))
            }
            return indexPaths
        }
        for row in range.lowerBound.row..<dataSource!.collectionView(self, numberOfItemsInSection: beginSection) {
            indexPaths.append(IndexPath(row: row, section: beginSection))
        }
        for row in 0...range.upperBound.row {
            indexPaths.append(IndexPath(row: row, section: endSection))
        }
        
        for section in (range.lowerBound.section + 1)..<range.upperBound.section {
            for row in 0..<dataSource!.collectionView(self, numberOfItemsInSection: section) {
                indexPaths.append(IndexPath(row: row, section: section))
            }
        }
        return indexPaths
    }
}
