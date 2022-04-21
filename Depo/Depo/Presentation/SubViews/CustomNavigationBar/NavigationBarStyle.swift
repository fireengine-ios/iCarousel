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
    case black
}

extension NavigationBarStyle {
    var isTranslucent: Bool {
        false
    }

    var barTintColor: UIColor {
        switch self {
        case .default:
            return color(.navigationBarBackground)
        case .black:
            return color(.navigationBarBackgroundBlack)
        }
    }

    var titleColor: UIColor {
        switch self {
        case .default:
            return color(.navigationBarTitle)
        case .black:
            return color(.navigationBarTitleBlack)
        }
    }

    var titleFont: UIFont {
        return UIFont.appFont(.medium, size: 16, relativeTo: .title1)
    }

    var tintColor: UIColor {
        switch self {
        case .default:
            return color(.navigationBarIcons)

        case .black:
            return color(.navigationBarIconsBlack)
        }
    }

    var backIndicatorImage: UIImage? { NavigationBarImage.back.image }

    var backIndicatorTransitionMaskImage: UIImage? { backIndicatorImage }

    var backButtonTitlePositionAdjustment: UIOffset {
        UIOffset(horizontal: 0, vertical: -0.5)
    }
}
