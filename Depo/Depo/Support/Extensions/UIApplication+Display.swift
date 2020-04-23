//
//  UIApplication+Display.swift
//  Depo
//
//  Created by Raman Harhun on 2/6/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

extension UIApplication {
    static func setIdleTimerDisabled(_ isDisabled: Bool) {
        guard isDisabled != UIApplication.shared.isIdleTimerDisabled else {
            return
        }
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = isDisabled
        }
    }
}
