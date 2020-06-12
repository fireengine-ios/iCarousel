//
//  TopSafeAreaConstraint.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 6/12/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

final class TopSafeAreaConstraint: NSLayoutConstraint {
    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 11.0, *) {
            let insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
            self.constant = max(insets.top, 20)
        } else {
            // Pre-iOS 11.0
            self.constant = 20.0
        }
    }
}
