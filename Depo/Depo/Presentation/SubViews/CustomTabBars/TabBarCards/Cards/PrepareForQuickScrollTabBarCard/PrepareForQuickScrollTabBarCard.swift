//
//  PrepareForQuickScrollTabBarCard.swift
//  Depo
//
//  Created by Hady on 6/4/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

final class PrepareForQuickScrollTabBarCard: BaseTabBarCard, NibInit {

    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.font = UIFont.appFont(.medium, size: 12, relativeTo: .body)
            newValue.numberOfLines = 1
            newValue.minimumScaleFactor = 0.5
            newValue.maximumContentSizeCategory = .extraExtraExtraLarge
            newValue.textColor = AppColor.tabBarCardLabel.color
            newValue.text = TextConstants.prepareQuickScroll
        }
    }

    @IBOutlet private weak var progressView: IndeterminateProgressBar! {
        willSet {
            newValue.primaryColor = AppColor.tabBarCardProgressTint.color
            newValue.secondaryColor = AppColor.tabBarCardProgressTrack.color
            newValue.layer.cornerRadius = newValue.frame.height / 2
        }
    }
}
