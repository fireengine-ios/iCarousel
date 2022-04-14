//
//  HeaderContainingViewControllerChild.swift
//  Depo
//
//  Created by Hady on 4/14/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

protocol HeaderContainingViewControllerChild: AnyObject {
    var scrollViewForHeaderTracking: UIScrollView? { get }
    var navigationHeaderLeftItems: [UIView] { get }
    var navigationHeaderRightItems: [UIView] { get }
}

extension HeaderContainingViewControllerChild {
    var scrollViewForHeaderTracking: UIScrollView? { nil }
    var navigationHeaderLeftItems: [UIView] { [] }
    var navigationHeaderRightItems: [UIView] { [] }
}
