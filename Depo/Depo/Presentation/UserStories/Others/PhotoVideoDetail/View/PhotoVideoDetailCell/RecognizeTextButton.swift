//
//  RecognizeTextButton.swift
//  Depo
//
//  Created by Hady on 12/27/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import UIKit

final class RecognizeTextButton: UIButton {
    static let size: CGFloat = 44

    convenience init() {
        self.init(type: .custom)
        setup()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: Self.size, height: Self.size)
    }

    private func setup() {
        setImage(Image.iconOcr.image, for: .normal)
        imageEdgeInsets = UIEdgeInsets(topBottom: 10, rightLeft: 10)
        tintColor = .white
        setBackgroundColor(AppColor.recognizeBackground.color, for: .normal)
        setBackgroundColor(AppColor.button.color, for: .selected)

        layer.cornerRadius = Self.size / 2
        layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.contentMode = .scaleAspectFit
    }
}
