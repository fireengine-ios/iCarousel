//
//  EntityInfoHeader.swift
//  Depo
//
//  Created by Anton Ignatovich on 23.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

class EntityInfoHeader: UIView {
    private struct Constants {
        static let leadingTrailingOffset: CGFloat = 20
        static let topOffset: CGFloat = 35
        static let bottomOffset: CGFloat = 15
    }

    private lazy var label: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.GTAmericaStandardRegularFont()
        lbl.textColor = ColorConstants.infoPageValueText
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(label)
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.leadingTrailingOffset).activate()
        label.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topOffset).activate()
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.leadingTrailingOffset).activate()
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.bottomOffset).activate()
    }

    func updateText(to string: String) {
        label.text = string
    }
}
