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
        /// lineBreakMode must be at the beginning!
        buttonLabel.lineBreakMode = .byClipping

        buttonLabel.adjustsFontSizeToFitWidth = true
        buttonLabel.numberOfLines = 0
        buttonLabel.minimumScaleFactor = 0.5
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

        setBackgroundColor(ColorConstants.darkBlueColor, for: .normal)
        setBackgroundColor(ColorConstants.darkBlueColor.lighter(by: 30.0), for: .disabled)
        setTitleColor(ColorConstants.whiteColor, for: .normal)
        setTitleColor(ColorConstants.lightGrayColor, for: .disabled)
    }
    
    override func layoutSubviews() {
        /// call before "super.layoutSubviews()".
        /// needs for "titleLabel?.frame = UIEdgeInsetsInsetRect(bounds, insets)"
        setInsets()
        
        super.layoutSubviews()
    }
    
    private func setInsets() {
        guard bounds.height > 0 else {
            return
        }
        let inset = frame.height * 0.3
        insets = UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: inset)
    }
}
