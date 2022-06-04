//
//  BaseTabBarCard.swift
//  Depo
//
//  Created by Hady on 6/4/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

private let kDefaultCornerRadius: CGFloat = 16
private let kAdditionalBottomMargin: CGFloat = 16

class BaseTabBarCard: UIView {
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint! {
        willSet {
            newValue.constant += kAdditionalBottomMargin
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = AppColor.tabBarCardBackground.color

        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = kDefaultCornerRadius

        clipsToBounds = false
        layer.shadowColor = AppColor.tabBarCardShadow.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 24
        layer.shadowOffset = CGSize(width: 0, height: 8)
    }
}
