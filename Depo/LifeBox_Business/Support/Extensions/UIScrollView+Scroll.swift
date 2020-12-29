//
//  UIScrollView+Scroll.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 2/8/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension UIScrollView {
    func scrollToBottom(animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.height)
        setContentOffset(bottomOffset, animated: animated)
    }
}
