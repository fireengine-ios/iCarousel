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
        let insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        self.constant = max(insets.top, 20)
    }
}
