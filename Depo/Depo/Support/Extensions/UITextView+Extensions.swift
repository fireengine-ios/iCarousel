//
//  UITextView+Extensions.swift
//  Depo
//
//  Created by Andrei Novikau on 6/12/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

extension UITextViewDelegate {
    func defaultHandle(url: URL, interaction: UITextItemInteraction) -> Bool {
        if interaction == .presentActions {
            return true
        }
        return UIApplication.shared.openSafely(url)
    }
}
