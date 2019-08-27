//
//  QuickSelectCollectionView.swift
//  Depo
//
//  Created by Konstantin Studilin on 25/07/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import UIKit


protocol QuickSelectCollectionViewDelegate: class {
    func didLongPress(at indexPath: IndexPath?)
    func didEndLongPress(at indexPath: IndexPath?)
}


final class QuickSelectCollectionView: UICollectionView {
    
    private enum SelectionMode {
        case selecting, deselecting, none
        
        var toBool: Bool? {
            switch self {
            case .selecting: return true
            case .deselecting: return false
            case .none: return nil
            }
        }
    }
    
    
    weak var longPressDelegate: QuickSelectCollectionViewDelegate?
    
    var isQuickSelectAllowed = false
    private(set) var isQuickSelecting = false
    
    private var selectionMode: SelectionMode = .none
    
    // saved index pathes
    private var beginIndexPath: IndexPath?
    private var lastAffectedRange: ClosedRange<IndexPath>?
    private var selectedOriginallyIndexPaths = [IndexPath]()
    
    // scroll speed
    private var currentScrollSpeed: CGFloat = 0.0
    private let minScrollSpeed: CGFloat = 4.0
    private let deltaScrollSpeed: CGFloat = UIScreen.main.bounds.height
    
    private let autoScrollStepTime =  1.0/60.0 // 60 FPS
    private let autoScrollStepsNumber = 8
    
    private var offsetRange: ClosedRange<CGFloat> = 0...0
    
    // scroll triggering
    private let scrollTriggeringScreenRatio: CGFloat = 0.25
    private lazy var topScrollTriggeringInset = UIScreen.main.bounds.height * scrollTriggeringScreenRatio
    private lazy var bottomScrollTriggeringInset = UIScreen.main.bounds.height * (1 - scrollTriggeringScreenRatio)
    
    private var shouldAutoScroll = false
    private var isScrolling = false
    
    
    private lazy var longPressRecognizer: QuickSelectGestureRecognizer = {
        let recognizer = QuickSelectGestureRecognizer(target: self, action: #selector(didLongTapChange(_:)))
        recognizer.minimumPressDuration = 0.15
        recognizer.delaysTouchesBegan = true
        return recognizer
    }()
    
    private var pointedIndexPath: IndexPath? {
        let point = longPressRecognizer.location(in: self)
        return indexPathForItem(at: point)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)

        setup()
    }
    
    private func setup() {
        gestureRecognizers?.append(longPressRecognizer)
        allowsMultipleSelection = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateOffsetRange()
    }
    
    private func updateOffsetRange() {
        let inset: UIEdgeInsets
        if #available(iOS 11.0, *) {
            inset = adjustedContentInset
        } else {
            inset = contentInset
        }
        
        let maxBottomOffset = contentSize.height + inset.bottom - frame.height
        offsetRange = -inset.top...max(0.0, maxBottomOffset)
    }
    
    @objc private func didLongTapChange(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            if let indexPath = pointedIndexPath, let cellIsSelected = cellForItem(at: indexPath)?.isSelected {
                isQuickSelecting = isQuickSelectAllowed
                longPressDelegate?.didLongPress(at: pointedIndexPath)
                
                setItem(isSelected: !cellIsSelected, indexPath: indexPath)
            
                beginIndexPath = indexPath
                selectedOriginallyIndexPaths = indexPathsForSelectedItems ?? []
                selectionMode = cellIsSelected ? .deselecting : .selecting
            } else {
                selectionMode = .none
            }
        case .changed:
            guard isQuickSelectAllowed else {
                return
            }
            
            /// preventing gaps in selection
            let point = gestureRecognizer.location(in: self)
            if bounds.contains(point) {
                shouldAutoScroll = true
                autoScroll()
            } else {
                shouldAutoScroll = false
            }
        default:
            isQuickSelecting = false
            longPressDelegate?.didEndLongPress(at: pointedIndexPath)
            shouldAutoScroll = false
            beginIndexPath = nil
            lastAffectedRange = nil
            selectedOriginallyIndexPaths.removeAll()
            currentScrollSpeed = 0.0
            selectionMode = .none
        }
    }
    

    private func updateSelection() {
        guard
            let startIndexPath = beginIndexPath,
            let endIndexPath = pointedIndexPath
        else {
            return
        }
        
        let lowerIndexPath = min(startIndexPath, endIndexPath)
        let upperIndexPath = max(startIndexPath, endIndexPath)
        
        let currentRange = ClosedRange(uncheckedBounds: (lowerIndexPath, upperIndexPath))
        
        guard currentRange != lastAffectedRange else {
            return
        }
        
//        print("range: \(currentRange)")
        
        var positiveIndexPaths = [IndexPath]()
        var negativeIndexPaths = [IndexPath]()
        
        if let lastRange = lastAffectedRange {
            switch (currentRange.lowerBound, currentRange.upperBound) {
            case (lastRange.lowerBound, let upperBound) where upperBound < lastRange.upperBound:
                let neagtiveRange = ClosedRange(uncheckedBounds: (upperBound, lastRange.upperBound))
                negativeIndexPaths = indexPaths(in: neagtiveRange)
                negativeIndexPaths.removeFirst()
                
            case (lastRange.lowerBound, let upperBound) where upperBound >= lastRange.upperBound:
                let positiveRange = ClosedRange(uncheckedBounds: (lastRange.upperBound, upperBound))
                positiveIndexPaths = indexPaths(in: positiveRange)
                
            case (let lowerBound, lastRange.upperBound) where lowerBound > lastRange.lowerBound:
                let negativeRange = ClosedRange(uncheckedBounds: (lastRange.lowerBound, lowerBound))
                negativeIndexPaths = indexPaths(in: negativeRange)
                negativeIndexPaths.removeLast()
                
            case (let lowerBound, lastRange.upperBound) where lowerBound <= lastRange.lowerBound:
                let positiveRange = ClosedRange(uncheckedBounds: (lowerBound, lastRange.lowerBound))
                positiveIndexPaths = indexPaths(in: positiveRange)
                
            default:
                negativeIndexPaths = indexPaths(in: lastRange)
                positiveIndexPaths = indexPaths(in: currentRange)
            }
        } else {
            positiveIndexPaths = indexPaths(in: currentRange)
        }
        
//        print("positive range: \(positiveIndexPaths)")
//        print("negative range: \(negativeIndexPaths)")
        
        positiveIndexPaths.forEach { updateSelection(at: $0, restoring: false) }
        negativeIndexPaths.forEach { updateSelection(at: $0, restoring: true) }
        
        lastAffectedRange = currentRange
    }
    
    private func updateSelection(at indexPath: IndexPath, restoring: Bool) {
        guard let expectedSelection = selectionMode.toBool else {
            return
        }
    
        if restoring {
            let wasSelectedOriginally = selectedOriginallyIndexPaths.contains(indexPath)
            setItem(isSelected: wasSelectedOriginally, indexPath: indexPath)
        } else {
            setItem(isSelected: expectedSelection, indexPath: indexPath)
        }
    }
    
    private func setItem(isSelected: Bool, indexPath: IndexPath) {
        if isSelected {
            selectItem(at: indexPath, animated: false, scrollPosition: [])
            delegate?.collectionView?(self, didSelectItemAt: indexPath)
        } else {
            deselectItem(at: indexPath, animated: false)
            delegate?.collectionView?(self, didDeselectItemAt: indexPath)
        }
    }
    
    private func autoScroll() {
        guard !isScrolling else {
            return
        }

        isScrolling = true
        
        updateSelection()
        
        updateCurrentScrollSpeed()
        scroll { [weak self] in
            guard let self = self else {
                return
            }
            
            self.isScrolling = false
            
            self.updateSelection()
            
            if self.shouldAutoScroll {
                self.autoScroll()
            }
        }
    }
    
    private func scroll(completion: @escaping VoidHandler) {
        /// breaking scroll offset into small steps allows us to have smooth scrolling
        /// check if autoscroll is still allowed once in autoScrollStepTime * autoScrollStepsNumber seconds
        let stepOffsetY = currentScrollSpeed / CGFloat(autoScrollStepsNumber)
        
        let group = DispatchGroup()
        for _ in 0..<autoScrollStepsNumber {
            group.enter()
            let newContentOffset = CGPoint(x: contentOffset.x, y: contentOffset.y + stepOffsetY)
            if offsetRange ~= newContentOffset.y {
                setContentOffset(newContentOffset, animated: false)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + autoScrollStepTime) {
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main, execute: completion)
    }
    
    private func updateCurrentScrollSpeed() {
        /// location in window
        let pointY = longPressRecognizer.location(in: nil).y
        
        if pointY < topScrollTriggeringInset {
            let ratio = 1 - (pointY / topScrollTriggeringInset)
            currentScrollSpeed = -(minScrollSpeed + deltaScrollSpeed * ratio)
        } else if pointY > bottomScrollTriggeringInset {
            let deltaY = pointY - bottomScrollTriggeringInset
            let ratio = deltaY / bottomScrollTriggeringInset
            currentScrollSpeed = minScrollSpeed + deltaScrollSpeed * ratio
        } else {
            currentScrollSpeed = 0.0
        }
        
    }
    
    private func indexPaths(in range: ClosedRange<IndexPath>) -> [IndexPath] {
        guard let dataSource = dataSource else {
            return []
        }
        
        var indexPaths = [IndexPath]()
        let beginSection = range.lowerBound.section
        let endSection = range.upperBound.section
        
        guard beginSection != endSection else {
            for row in range.lowerBound.row...range.upperBound.row {
                indexPaths.append(IndexPath(row: row, section: beginSection))
            }
            return indexPaths
        }
        
        for row in range.lowerBound.row..<dataSource.collectionView(self, numberOfItemsInSection: beginSection) {
            indexPaths.append(IndexPath(row: row, section: beginSection))
        }
        for row in 0...range.upperBound.row {
            indexPaths.append(IndexPath(row: row, section: endSection))
        }
        
        for section in (range.lowerBound.section + 1)..<range.upperBound.section {
            for row in 0..<dataSource.collectionView(self, numberOfItemsInSection: section) {
                indexPaths.append(IndexPath(row: row, section: section))
            }
        }
        return indexPaths
    }
}
