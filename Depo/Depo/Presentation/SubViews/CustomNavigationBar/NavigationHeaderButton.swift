//
//  NavigationHeaderButton.swift
//  Depo
//
//  Created by Hady on 4/20/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

final class NavigationHeaderButton: UIButton {
    convenience init(type: `Type`, target: Any? = nil, action: Selector? = nil) {
        self.init()
        setImage(type.image?.image, for: .normal)
        accessibilityIdentifier = type.accessibilityId
        accessibilityLabel = type.accessibilityLabel
        if let target = target, let action = action {
            addTarget(target, action: action, for: .primaryActionTriggered)
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 28, height: 28)
    }
}

extension NavigationHeaderButton {
    enum `Type` {
        case settings
        case search
        case plus

        var image: NavigationBarImage? {
            switch self {
            case .settings:
                return .headerActionSettings
            case .search:
                return .headerActionSearch
            case .plus:
                return .headerActionPlus
            }
        }

        var accessibilityLabel: String {
            switch self {
            case .settings:
                return TextConstants.settings
            case .search:
                return TextConstants.search
            case .plus:
                return TextConstants.accessibilityPlus
            }
        }

        var accessibilityId: String {
            switch self {
            case .settings:
                return "NavigationHeaderButtonSettings"
            case .search:
                return "NavigationHeaderButtonSearch"
            case .plus:
                return "NavigationHeaderButtonPlus"
            }
        }
    }
}
