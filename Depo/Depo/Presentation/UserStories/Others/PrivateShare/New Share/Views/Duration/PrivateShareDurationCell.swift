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
            newValue.font = .TurkcellSaturaDemFont(size: 16)
            newValue.textAlignment = .center
            newValue.textColor = .lightGray
        }
    }
    
    @IBOutlet private weak var borderView: UIView! {
        willSet {
            newValue.clipsToBounds = true
            newValue.layer.cornerRadius = newValue.frame.height * 0.5
        }
    }
    
    override var isSelected: Bool {
        didSet {
            borderView.backgroundColor = isSelected ? ColorConstants.aquaMarineTwo : .clear
            titleLabel.textColor = isSelected ? .white : .lightGray
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
