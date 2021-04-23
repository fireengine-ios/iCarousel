//
//  SharedFilesSliderPlusCell.swift
//  Depo
//
//  Created by Andrei Novikau on 29.12.20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class SharedFilesSliderPlusCell: UICollectionViewCell {

    @IBOutlet private weak var borderView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.borderWidth = 2
            newValue.layer.borderColor = ColorConstants.marineTwo.color.cgColor
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = "+"
            newValue.font = .GTAmericaStandardBoldFont(size: 40)
            newValue.textColor = ColorConstants.marineTwo.color
            newValue.textAlignment = .center
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        borderView.layer.cornerRadius = borderView.frame.width * 0.5
    }

}
