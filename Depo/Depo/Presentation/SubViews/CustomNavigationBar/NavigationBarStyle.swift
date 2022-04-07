//
//  NavigationBarStyle.swift
//  Depo
//
//  Created by MacBook on 28/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import UIKit

enum NavigationBarStyle {
    case `default`
    case withLogo
    case black
}

extension NavigationBarStyle {
    var isTranslucent: Bool {
        false
    }

    var barTintColor: UIColor {
        switch self {
        case .default, .withLogo:
            return color(.navigationBarBackground)
        case .black:
            return color(.navigationBarBackgroundBlack)
        }
    }

    var titleColor: UIColor {
        switch self {
        case .default, .withLogo:
            return color(.navigationBarTitle)
        case .black:
            return color(.navigationBarTitleBlack)
        }
    }

    var titleViewSize: CGSize {
        switch self {
        case .withLogo:
            return CGSize(width: 40, height: 40)
        case .default, .black:
            return .zero
        }
    }

    var tintColor: UIColor {
        switch self {
        case .default, .withLogo:
            return color(.navigationBarIcons)

        case .black:
            return color(.navigationBarIconsBlack)
        }
    }

    var backIndicatorImage: UIImage? { imageAsset(NavigationBarImages.back) }

    var backIndicatorTransitionMaskImage: UIImage? { backIndicatorImage }

    var backButtonTitlePositionAdjustment: UIOffset {
        UIOffset(horizontal: 0, vertical: -0.5)
    }
}
