//
//  LoginErrorBannerView.swift
//  Depo_LifeTech
//
//  Created by Anton Ignatovich on 19.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

class LoginErrorBannerView: UIView {

    private lazy var messageLabel: UILabel = {
        let newValue = UILabel()

        newValue.textColor = UIColor(named: "loginErrorLabelTextColor")
        newValue.font = UIFont.GTAmericaStandardRegularFont(size: 12)
        newValue.textAlignment = .center
        newValue.lineBreakMode = .byWordWrapping
        newValue.numberOfLines = 0
        newValue.isOpaque = true

        return newValue
    }()

    @IBInspectable var shouldShowUnderlineLayer = true {
        didSet {
            updateUnderlineLayerVisibility()
        }
    }

    private let underlineLayer: CALayer = {
        let newValue = CALayer()

        newValue.backgroundColor = ColorConstants.profileGrayColor.cgColor

        return newValue
    }()

    private let underlineWidth: CGFloat = 1.0

    var message: String? {
        didSet {
            messageLabel.text = message
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        underlineLayer.frame = CGRect(x: 0.0,
                                      y: frame.size.height - underlineWidth,
                                      width: frame.width,
                                      height: underlineWidth);
        updateUnderlineLayerVisibility()
    }

    private func setup() {
        layer.addSublayer(underlineLayer)
        addSubview(messageLabel)

        messageLabel.text = ""

        setupLayout()
    }

    private func setupLayout() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.topAnchor.constraint(equalTo: topAnchor).activate()
        messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor).activate()
        messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor).activate()
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).activate()
    }

    private func updateUnderlineLayerVisibility() {
        underlineLayer.isHidden = !shouldShowUnderlineLayer
    }
}

