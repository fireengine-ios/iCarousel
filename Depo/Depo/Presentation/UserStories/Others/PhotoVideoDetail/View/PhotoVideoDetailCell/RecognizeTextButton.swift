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
    enum Status {
        case disabled
        case enabled
        case processing
        case activated
    }

    var status: Status = .enabled {
        didSet {
            isHidden = status == .disabled
            isUserInteractionEnabled = status != .processing
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let squareSize = max(44, max(size.width, size.height))
        return CGSize(width: squareSize, height: squareSize)
    }

    private func setup() {
        if #available(iOS 15.0, *) {
            setupiOS15()
        } else {
            setupPreiOS15()
        }
    }

    @available(iOS 15, *)
    private func setupiOS15() {
        tintColor = .lrTealish
        configurationUpdateHandler = { button in
            var config: UIButton.Configuration = button.isSelected ? .filled() : .gray()
            config.image = UIImage(systemName: "text.viewfinder")
            config.cornerStyle = .capsule
            button.configuration = config
        }
        setNeedsUpdateConfiguration()
    }

    private func setupPreiOS15() {
        //TODO: pre ios 15
    }
}
