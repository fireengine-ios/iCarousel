//
//  AlertFilesActionView.swift
//  Depo
//
//  Created by Hady on 6/14/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

class AlertFilesActionView: UIView, NibInit {
    @IBOutlet private var imageView: UIImageView!

    @IBOutlet private var label: UILabel! {
        willSet {
            newValue.font = UIFont.appFont(.medium, size: 16, relativeTo: .body)
            newValue.textColor = AppColor.label.color
        }
    }

    @IBOutlet private var separatorView: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.separator.color
        }
    }

    func configure(with action: AlertFilesAction, showsBottomSeparator: Bool) {
        imageView.image = action.icon?.image
        label.text = action.title
        separatorView.isHidden = !showsBottomSeparator
    }
}
