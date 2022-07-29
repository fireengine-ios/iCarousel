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
            newValue.font = .appFont(.medium, size: 14)
            newValue.textAlignment = .center
            newValue.textColor = AppColor.filesLabel.color
        }
    }
    
    @IBOutlet private weak var borderView: UIView! {
        willSet {
            newValue.clipsToBounds = true
            newValue.addRoundedShadows(cornerRadius: 12,
                                       shadowColor: AppColor.filesBigCellShadow.cgColor,
                                       opacity: 0.4, radius: 4.0, offset: CGSize(width: .zero, height: 4.0))
        }
    }

    func setup(with duration: PrivateShareDuration) {
        titleLabel.text = duration.title
    }
    
    func setSelection(isSelected: Bool) {
        borderView.backgroundColor = isSelected ? AppColor.filesSharedTabSeperator.color : AppColor.filesShareDurationBackground.color
        titleLabel.textColor = isSelected ? .white : AppColor.filesLabel.color
        borderView.layer.shadowOpacity = isSelected ? 0.0 : 0.4
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
