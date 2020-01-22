//
//  StickerCollectionViewCell.swift
//  Depo
//
//  Created by Maxim Soldatov on 12/21/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import YYImage
import SDWebImage

final class StickerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var previewImageView: YYAnimatedImageView! {
        willSet {
            newValue.layer.borderColor = ColorConstants.stickerBorderColor.cgColor
            newValue.layer.borderWidth = 1
            newValue.contentMode = .scaleAspectFit
            newValue.isUserInteractionEnabled = false
        }
    }
    
    var stickerType: AttachedEntityType = .gif {
        didSet {
            switch stickerType {
            case .gif:
                previewImageView.startAnimating()
            case .image:
                previewImageView.stopAnimating()
            }
        }
    }
    
    func setup(with object: SmashStickerResponse, type: AttachedEntityType) {
        previewImageView.image = nil
        previewImageView.sd_cancelCurrentImageLoad()
        previewImageView.sd_setImage(with: object.thumbnailPath, completed: nil)
        stickerType = type
    }
    
    func setupGif(image: UIImage) {
        if stickerType == .gif {
            previewImageView.image = image
        }
    }
}
