//
//  NavigationHeaderButton.swift
//  Depo
//
//  Created by Hady on 4/20/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

final class NavigationHeaderButton: UIButton {
    convenience init(navigationBarImage: NavigationBarImage, target: Any? = nil, action: Selector? = nil) {
        self.init()
        setImage(navigationBarImage.image, for: .normal)
        if let target = target, let action = action {
            addTarget(target, action: action, for: .primaryActionTriggered)
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 40, height: 40)
    }
}
