//
//  InstaPickSmartAlbumCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 01/02/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage


final class InstaPickSmartAlbumCell: SmartAlbumCell {

    @IBOutlet var gradientBackground: RadialGradientableView! {
        willSet {
            newValue.backgroundColor = UIColor.lrTealish
            newValue.isNeedGradient = true
            newValue.isHidden = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbnailsContainer.backgroundColor = .clear
    }
}
