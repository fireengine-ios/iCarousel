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
        let size = super.intrinsicContentSize
        let squareSize = max(Self.size, max(size.width, size.height))
        return CGSize(width: squareSize, height: squareSize)
    }

    private func setup() {
//        if #available(iOS 15.0, *) {
//            setupiOS15()
//        } else {
        setupPreiOS15()
//        }
    }

//    @available(iOS 15.0, *)
//    private func setupiOS15() {
//        tintColor = .lrTealish
//        configurationUpdateHandler = { button in
//            var config: UIButton.Configuration = button.isSelected ? .filled() : .gray()
//            config.image = UIImage(systemName: "text.viewfinder")
//            config.cornerStyle = .capsule
//            button.configuration = config
//        }
//        setNeedsUpdateConfiguration()
//    }

    private func setupPreiOS15() {
        if #available(iOS 13.0, *) {
            let image = UIImage(systemName: "text.viewfinder")
            setImage(image?.withTintColor(.lrTealish), for: .normal)
            setImage(image?.withTintColor(.white), for: .selected)
        }
        setBackgroundColor(UIColor.systemGray.withAlphaComponent(0.6), for: .normal)
        setBackgroundColor(UIColor.lrTealish, for: .selected)

        layer.cornerRadius = intrinsicContentSize.height / 2
        layer.masksToBounds = true
    }
}
