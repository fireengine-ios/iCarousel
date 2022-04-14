//
//  HomeHeaderView.swift
//  Depo
//
//  Created by Hady on 4/12/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

class NavigationHeaderButton: UIButton {
    convenience init(image: NavigationBarImage, target: Any? = nil, action: Selector? = nil) {
        self.init()
        setImage(imageAsset(image), for: .normal)
        if let target = target, let action = action {
            addTarget(target, action: action, for: .primaryActionTriggered)
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 40, height: 40)
    }
}

class NavigationHeaderView: UIView, NibInit {
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var rightItemsStackView: UIStackView!
    @IBOutlet private weak var leftItemsStackView: UIStackView!

    func setLeftItems(_ items: [UIView]) {
        leftItemsStackView.arrangedSubviews.forEach { subview in
            leftItemsStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        for item in items {
            leftItemsStackView.addArrangedSubview(item)
        }
    }

    func setRightItems(_ items: [UIView]) {
        rightItemsStackView.arrangedSubviews.forEach { subview in
            rightItemsStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        for item in items {
            rightItemsStackView.addArrangedSubview(item)
        }
    }
}
