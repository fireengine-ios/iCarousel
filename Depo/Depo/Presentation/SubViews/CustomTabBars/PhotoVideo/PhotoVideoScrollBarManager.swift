//
//  PhotoVideoScrollBarManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 10/19/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

typealias YearMonthTuple = (year: Int, month: Int)

final class PhotoVideoScrollBarManager {
    
    let scrollBar = ScrollBarView()
    let yearsView = YearsView()
    
    private let scrollBarHiddingDelay: TimeInterval = 3
    private var hideScrollBarAnimatedTimer: Timer?
    
    private var isScrollBarAdded = false
    
    deinit {
        yearsView.freeScrollView()
        scrollBar.freeScrollView()
    }
    
    func addScrollBar(to collectionView: UICollectionView?, delegate: ScrollBarViewDelegate?) {
        guard !isScrollBarAdded, let collectionView = collectionView else {
            return
        }
        isScrollBarAdded = true
        yearsView.add(to: collectionView)
        scrollBar.add(to: collectionView)
        scrollBar.delegate = delegate
    }
    
    func updateYearsView(with allItems: [MediaItem], cellHeight: CGFloat, numberOfColumns: Int) {
        print("+ a")
        if allItems.isEmpty {
            return
        }
    
        // TODO: getCellSizeForList must be called in main queue. for a while it is woking without it
        //        let cellHeight = delegate?.getCellSizeForGreed().height ?? 0
        scrollBar.updateLayout(by: cellHeight)
        yearsView.update(cellHeight: cellHeight, headerHeight: 50, numberOfColumns: numberOfColumns)
        
        let emptyMetaItems = allItems.filter { $0.monthValue == nil }
        if !emptyMetaItems.isEmpty {
            yearsView.update(additionalSections: [(TextConstants.photosVideosViewMissingDatesHeaderText, emptyMetaItems.count)])
        }
        
        
        
        let yearMonthValues: [YearMonthTuple] = allItems.compactMap {
            if let split = $0.monthValue?.split(separator: " "),
                split.count == 2,
                let year = Int(split[0]),
                let mounth = Int(split[1])
            {
                return (year, mounth)
            }
            return nil
        }
        
        yearsView.update(by: yearMonthValues)
    }
    
    func scrollViewDidScroll() {
        hideScrollBarAnimatedTimer?.invalidate()
        hideScrollBarAnimatedTimer = nil
    }
    
    func hideScrollBarIfNeed(for contentOffsetY: CGFloat) {
        if contentOffsetY < 0 {
            scrollBar.alpha = 0
        } else {
            scrollBar.alpha = 1
        }
    }
    
    func startTimerToHideScrollBar() {
        hideScrollBarAnimatedTimer?.invalidate()
        hideScrollBarAnimatedTimer = Timer.scheduledTimer(timeInterval: scrollBarHiddingDelay, target: self, selector: #selector(hideScrollBarAnimated), userInfo: nil, repeats: false)
    }
    
    @objc private func hideScrollBarAnimated() {
        hideScrollBarAnimatedTimer?.invalidate()
        hideScrollBarAnimatedTimer = nil
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.scrollBar.alpha = 0
        }
    }
}
