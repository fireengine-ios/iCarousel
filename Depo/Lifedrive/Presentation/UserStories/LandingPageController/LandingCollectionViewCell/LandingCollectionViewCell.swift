//
//  LandingCollectionViewCell.swift
//  lifedrive
//
//  Created by Andrei Novikau on 10/22/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class LandingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.billoBlue
            newValue.font = UIFont.PoppinsBoldFont(size: 25)
            newValue.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var subtitleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.removeConnection
            newValue.font = UIFont.SFProRegularFont(size: 15)
            newValue.textAlignment = .center
            newValue.numberOfLines = 3
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    func setup(with item: LandingItem) {
        imageView.image = item.image
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
    }
}
