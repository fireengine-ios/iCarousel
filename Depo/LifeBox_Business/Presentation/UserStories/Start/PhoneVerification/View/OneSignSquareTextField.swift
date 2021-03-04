//
//  OneSignSquareTextField.swift
//  Depo
//
//  Created by Anton Ignatovich on 04.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class OneSignSquareTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        baseSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        baseSetup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 5
        layer.borderWidth = 1.3
        layer.borderColor = ColorConstants.a2FABorderColor.cgColor
        layer.backgroundColor = UIColor.white.cgColor
    }

    private func baseSetup() {
        borderStyle = .none
        font = UIFont.GTAmericaStandardRegularFont(size: 22)
        textColor = ColorConstants.infoPageValueText
        textAlignment = .center
    }
}
