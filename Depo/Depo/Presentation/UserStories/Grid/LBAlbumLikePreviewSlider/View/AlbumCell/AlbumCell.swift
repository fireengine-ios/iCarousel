//
//  AlbumCell.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/4/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AlbumCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var previewBackView: UIView!
    @IBOutlet weak var previewImage1: LoadingImageView!
    @IBOutlet weak var previewImage2: LoadingImageView!
    @IBOutlet weak var previewImage3: LoadingImageView!
    @IBOutlet weak var previewImage4: LoadingImageView!
    @IBOutlet weak var placeholderImage: UIImageView!
    @IBOutlet weak var bigPreviewImage: LoadingImageView!
    
    func setup(withItem item: SliderItem) {
        titleLabel.text = item.name
        
        guard let type = item.type else {
            return
        }
        
        if type == .album {
            setup(withAlbum: item.albumItem)
        } else {
            setup(withSliderItem: item)
        }
        
        placeholderImage.layer.borderColor = type.placeholderBorderColor
        
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitNone
        accessibilityLabel = item.name
    }
    
    private func setup(withAlbum album: AlbumItem?) {
        bigPreviewImage.loadImageForItem(object: album?.preview)
    }
    
    private func setup(withSliderItem item: SliderItem) {
        if let items = item.previewItems, !items.isEmpty {
            previewBackView.isHidden = false
            placeholderImage.image = nil

            setupImage(previewImage1, path: items.first, placeholder: item.previewPlaceholder)
            setupImage(previewImage2, path: items[safe: 1], placeholder: item.previewPlaceholder)
            setupImage(previewImage3, path: items[safe: 2], placeholder: item.previewPlaceholder)
            setupImage(previewImage4, path: items[safe: 3], placeholder: item.previewPlaceholder)
        } else {
            previewBackView.isHidden = true
            placeholderImage.image = item.placeholderImage
        }
    }
    
    fileprivate func setupImage(_ imageView: LoadingImageView, path: PathForItem?, placeholder: UIImage?) {
        if path == nil, placeholder != nil {
            DispatchQueue.toMain {
                imageView.image = placeholder
            }
            return
        }
        imageView.backgroundColor = UIColor.lightGray.lighter(by: 20.0)
        imageView.loadImageByPath(path_: path)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = ""
        placeholderImage.layer.borderWidth = 1
        placeholderImage.layer.borderColor = ColorConstants.blueColor.cgColor
        titleLabel.font = UIFont.TurkcellSaturaMedFont(size: 14)
        titleLabel.textColor = ColorConstants.darkText
    }
}
