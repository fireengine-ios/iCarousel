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


public class QuickSelectCollectionView: UICollectionView {
    
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
    
    private var selectionMode: SelectionMode = .none
    
    // saved index pathes
    private var beginIndexPath: IndexPath?
    private var lastAffectedRange: ClosedRange<IndexPath>?
    private var selectedOriginallyIndexPaths = [IndexPath]()
    
    // scroll speed
    private var currentScrollSpeed: CGFloat = 0.0
    private let scrollMinSpeed: CGFloat = 4.0
    private let scrollSpeedDelta: CGFloat = UIScreen.main.bounds.height
    
    private let autoScrollStepTime =  1.0/60.0 // 60 FPS
    private let autoScrollStepsNumber = 8
    
    private var offsetRange: ClosedRange<CGFloat> = 0...0
    
    // scroll triggering
    private let scrollTriggeringScreenRatio: CGFloat = 0.25
    private lazy var topScrollTriggeringInset = UIScreen.main.bounds.height * scrollTriggeringScreenRatio
    private lazy var bottomScrollTriggeringInset = UIScreen.main.bounds.height * (1 - scrollTriggeringScreenRatio)
    
    private var shouldAutoScroll = false
    private var isScrolling = false
    
    
    lazy private var longPressRecognizer: UILongPressGestureRecognizer = {
        let recognizer = QuickSelectGestureRecognizer(target: self, action: #selector(didLongTapChange(_:)))
        recognizer.minimumPressDuration = 0.15
        recognizer.delaysTouchesBegan = true
        return recognizer
    }()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)

        setup()
    }
    
    private func setup() {
        gestureRecognizers?.append(longPressRecognizer)
        allowsMultipleSelection = true
    }
    
    public override func layoutSubviews() {
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
        let point = gestureRecognizer.location(in: self)
        let pointedIndexPath = indexPathForItem(at: point)
        
        guard isQuickSelectAllowed else {
            if gestureRecognizer.state == .began, pointedIndexPath != nil {
                longPressDelegate?.didLongPress(at: pointedIndexPath)
            }
            return
        }
        
        switch gestureRecognizer.state {
        case .began:
            if let indexPath = pointedIndexPath, let cellIsSelected = cellForItem(at: indexPath)?.isSelected {
                beginIndexPath = indexPath
                setItem(isSelected: !cellIsSelected, indexPath: indexPath)
                selectedOriginallyIndexPaths = indexPathsForSelectedItems ?? []
                selectionMode = cellIsSelected ? .deselecting : .selecting
            } else {
                selectionMode = .none
            }
        case .changed:
            /// preventing gaps in selection
            if bounds.contains(point) {
                shouldAutoScroll = true
                autoScroll()
            } else {
                shouldAutoScroll = false
            }
        default:
            longPressDelegate?.didEndLongPress(at: pointedIndexPath)
            shouldAutoScroll = false
            beginIndexPath = nil
            lastAffectedRange = nil
            selectedOriginallyIndexPaths = []
            currentScrollSpeed = 0.0
            selectionMode = .none
        }
    }
    

    private func updateSelection(till endIndexPath: IndexPath) {
        guard let startIndexPath = beginIndexPath, startIndexPath != endIndexPath else {
            return
        }
        
        let upperIndexPath = max(startIndexPath, endIndexPath)
        let lowerIndexPath = min(startIndexPath, endIndexPath)
        let currentRange = ClosedRange(uncheckedBounds: (lowerIndexPath, upperIndexPath))
        
        guard currentRange != lastAffectedRange else {
            return
        }
        
//        print(currentRange)
        
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
//                negativeIndexPaths.removeLast()
                
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
        
        positiveIndexPaths.forEach { updateSelection(at: $0, restoring: false) }
        negativeIndexPaths.forEach { updateSelection(at: $0, restoring: true) }
        
//        print("positive: \(positiveIndexPaths)")
//        print("negative: \(negativeIndexPaths)")
        
        lastAffectedRange = currentRange
    }
    
    private func updateSelection(at indexPath: IndexPath, restoring: Bool) {
        guard
            let isSelected = cellForItem(at: indexPath)?.isSelected,
            let expectedSelection = selectionMode.toBool
        else {
            return
        }
    
        if restoring {
            let wasSelectedOriginally = selectedOriginallyIndexPaths.contains(indexPath)
            if wasSelectedOriginally != isSelected {
                setItem(isSelected: wasSelectedOriginally, indexPath: indexPath)
            }
        } else if isSelected != expectedSelection {
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
        
        updateCurrentScrollSpeed()
        
        scroll { [weak self] in
            guard let self = self else {
                return
            }
            
            self.isScrolling = false
            
            let point = self.longPressRecognizer.location(in: self)
            if let pointedIndexPath = self.indexPathForItem(at: point) {
                self.updateSelection(till: pointedIndexPath)
            }
            
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
            currentScrollSpeed = -(scrollMinSpeed + scrollSpeedDelta * ratio)
        } else if pointY > bottomScrollTriggeringInset {
            let deltaY = pointY - bottomScrollTriggeringInset
            let ratio = deltaY / bottomScrollTriggeringInset
            currentScrollSpeed = scrollMinSpeed + scrollSpeedDelta * ratio
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
