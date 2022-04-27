//
//  HeaderContainingViewController+Config.swift
//  Depo
//
//  Created by Hady on 4/21/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

extension HeaderContainingViewController {
    enum HeaderContentIntersectionMode: CGFloat {
        case `default` = 49
        case none = 0
    }

    enum StatusBarBackgroundViewStyle {
        case blurEffect(style: UIBlurEffect.Style)
        case plain(color: AppColor)
    }
}
