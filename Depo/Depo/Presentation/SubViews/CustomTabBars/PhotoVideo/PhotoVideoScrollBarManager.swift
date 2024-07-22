//
//  PhotoVideoScrollBarManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 10/19/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

typealias YearHeightMap = [Int?: CGFloat]
typealias YearHeightTuple = (year: Int?, height: CGFloat)

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
        scrollBar.alpha = 0
        isScrollBarAdded = true
        yearsView.add(to: collectionView)
        scrollBar.add(to: collectionView)
        scrollBar.delegate = delegate
    }
    
    func updateYearsView(with years: [YearHeightTuple]) {
        yearsView.update(by: years)
    }
    
    func scrollViewDidScroll() {
        hideScrollBarAnimatedTimer?.invalidate()
        hideScrollBarAnimatedTimer = nil
    }
    
    func hideScrollBarIfNeed(for contentOffsetY: CGFloat) {
        if contentOffsetY < -scrollBar.originalTopInset {
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
