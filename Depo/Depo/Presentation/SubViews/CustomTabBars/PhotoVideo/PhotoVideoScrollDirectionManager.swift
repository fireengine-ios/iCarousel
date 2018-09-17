//
//  PhotoVideoScrollDirectionManager.swift
//  Depo
//
//  Created by Konstantin on 9/17/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


enum ScrollDirection {
    /// up - new items appear from the TOP of screen
    /// down - new items appear from the BOTTOM of screen
    case up
    case down
    case none
    
    init(yValue: CGFloat) {
        if yValue == 0 {
            self = .none
        } else {
            self = yValue > 0 ? .up: .down
        }
    }
}


class PhotoVideoScrollDirectionManager {

    private (set) var scrollDirection: ScrollDirection = .none
    private var lastContentOffset: CGPoint = .zero
    
    
    func handleScrollBegin(with contentOffset: CGPoint) {
        lastContentOffset = contentOffset
    }
    
    func handleScrollEnd(with contentOffset: CGPoint) {
        let yOffset = lastContentOffset.y - contentOffset.y
        lastContentOffset = contentOffset
        scrollDirection = ScrollDirection(yValue: yOffset)
    }
}
