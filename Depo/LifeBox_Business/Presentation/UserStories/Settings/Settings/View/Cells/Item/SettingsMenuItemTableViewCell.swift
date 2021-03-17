//
//  SettingsMenuItemTableViewCell.swift
//  Depo
//
//  Created by Anton Ignatovich on 14.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class SettingsMenuItemTableViewCell: UITableViewCell {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardMediumFont(size: 16)
            newValue.textColor = ColorConstants.infoPageValueText
        }
    }
    @IBOutlet private weak var separatorView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.separator
            newValue.isHidden = true
            newValue.alpha = 0.5
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        titleLabel.text = ""
        layer.mask = nil
    }

    func setup(with menuItem: SettingsMenuItem, isFirstCell: Bool = false, isLastCell: Bool = false) {
        let cornersToRound: UIRectCorner = isFirstCell ? [.topLeft, .topRight] : isLastCell ? [.bottomLeft, .bottomRight] : []
        roundCorners(corners: cornersToRound, radius: 5)
        iconImageView.image = menuItem.icon
        titleLabel.text = menuItem.title
        separatorView.isHidden = isLastCell
    }
}
