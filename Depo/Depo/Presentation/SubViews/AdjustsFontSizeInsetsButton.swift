//
//  AdjustsFontSizeInsetsButton.swift
//  Depo
//
//  Created by Darya Kuliashova on 2/6/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit.UIButton

class AdjustsFontSizeInsetsButton: UIButton {
    var insets: UIEdgeInsets = .zero {
        didSet {
            setNeedsDisplay()
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

    private func setup() {
        guard let buttonLabel = titleLabel else {
            assertionFailure()
            return
        }
        /// must be at the beginning
        buttonLabel.lineBreakMode = .byClipping

        buttonLabel.adjustsFontSizeToFitWidth = true
        buttonLabel.numberOfLines = 0
        buttonLabel.minimumScaleFactor = 0.1
        buttonLabel.textAlignment = .center
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.frame = UIEdgeInsetsInsetRect(bounds, insets)
    }
}

class AdjustsFontSizeInsetsRoundedButton: AdjustsFontSizeInsetsButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height * 0.5
    }
}

final class AdjustsFontSizeInsetsRoundedDarkBlueButton: AdjustsFontSizeInsetsRoundedButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        titleLabel?.font = ApplicationPalette.bigRoundButtonFont

        setBackgroundColor(ColorConstants.darcBlueColor, for: .normal)
        setBackgroundColor(ColorConstants.darcBlueColor.lighter(by: 30.0), for: .disabled)
        setTitleColor(ColorConstants.whiteColor, for: .normal)
        setTitleColor(ColorConstants.lightGrayColor, for: .disabled)
    }
}
