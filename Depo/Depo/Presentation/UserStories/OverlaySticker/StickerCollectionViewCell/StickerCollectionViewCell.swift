//
//  StickerCollectionViewCell.swift
//  Depo
//
//  Created by Maxim Soldatov on 12/21/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import YYImage

final class StickerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var previewImage: UIImageView! {
        willSet {
            newValue.layer.borderColor = ColorConstants.stickerBorderColor.cgColor
            newValue.layer.borderWidth = 1
            newValue.contentMode = .scaleAspectFit
            newValue.isUserInteractionEnabled = false
        }
    }
    
    func setupImageView(previewImage: UIImage) {
        self.previewImage.image = previewImage
    }
}
