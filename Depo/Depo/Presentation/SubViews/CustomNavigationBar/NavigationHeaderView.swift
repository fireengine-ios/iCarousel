//
//  HomeHeaderView.swift
//  Depo
//
//  Created by Hady on 4/12/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

final class NavigationHeaderView: UIView, NibInit {

    func setLeftItems(_ items: [UIView]) {
        leftItemsStackView.arrangedSubviews.forEach { subview in
            leftItemsStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        for item in items {
            leftItemsStackView.addArrangedSubview(item)
        }

        leftItemsStackView.isHidden = items.count == 0
    }

    func setRightItems(_ items: [UIView]) {
        rightItemsStackView.arrangedSubviews.forEach { subview in
            rightItemsStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        for item in items {
            rightItemsStackView.addArrangedSubview(item)
        }

        rightItemsStackView.isHidden = items.count == 0
    }


    private static let standardHeight: CGFloat = 166

    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var rightItemsStackView: UIStackView! {
        willSet {
            newValue.spacing = 12
        }
    }

    @IBOutlet private weak var leftItemsStackView: UIStackView! {
        willSet {
            newValue.spacing = 12
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: super.intrinsicContentSize.width, height: Self.standardHeight)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        logoImageView.image = NavigationBarImage.headerLogo.image
        backgroundImageView.image = NavigationBarImage.headerBackground.image
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if let _ = subview.hitTest(convert(point, to: subview), with: event) {
                return true
            }
        }

        return false
    }
}
