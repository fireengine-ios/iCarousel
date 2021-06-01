//
//  FileInfoThumbView.swift
//  Depo_LifeTech
//
//  Created by Hady on 6/1/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

class FileInfoThumbView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        isAccessibilityElement = true
        accessibilityLabel = TextConstants.accessibilityClose
        accessibilityTraits = UIAccessibilityTraitButton
    }

    override func accessibilityActivate() -> Bool {
        var responder: UIResponder? = self
        while responder?.next != nil {
            responder = responder?.next
            if let viewController = responder?.next as? PhotoVideoDetailViewController {
                viewController.bottomDetailViewManager?.closeDetailView()
                return true
            }
        }

        return false
    }
}
