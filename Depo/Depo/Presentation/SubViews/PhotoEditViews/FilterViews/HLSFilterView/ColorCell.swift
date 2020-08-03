//
//  ColorCell.swift
//  Depo
//
//  Created by Andrei Novikau on 7/28/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    
    @IBOutlet private weak var colorView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = newValue.frame.height * 0.5
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = ColorConstants.filterBackColor
    }
    
    func setup(color: UIColor, isSelected: Bool) {
        setSelected(isSelected)
        colorView.backgroundColor = color
    }
    
    func setSelected(_ isSelected: Bool) {
        contentView.layer.borderColor = isSelected ? UIColor.blue.cgColor : ColorConstants.filterBackColor.cgColor
        contentView.layer.borderWidth = 2
    }
}
