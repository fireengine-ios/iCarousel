//
//  PrivateShareDurationCell.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 11/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PrivateShareDurationCell: UICollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .GTAmericaStandardMediumFont(size: 12)
            newValue.textAlignment = .center
            newValue.textColor = ColorConstants.PrivateShare.durationLabelUnselected
        }
    }
    
    @IBOutlet private weak var borderView: UIView! {
        willSet {
            newValue.clipsToBounds = true
            newValue.layer.cornerRadius = 5
        }
    }
    
    override var isSelected: Bool {
        didSet {
            borderView.backgroundColor = isSelected ? ColorConstants.Text.labelTitleBackground : .clear
            titleLabel.textColor = isSelected ? ColorConstants.Text.labelTitle : ColorConstants.PrivateShare.durationLabelUnselected
        }
    }

    func setup(with duration: PrivateShareDuration) {
        titleLabel.text = duration.title
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        newFrame.size.width = ceil(size.width)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}
