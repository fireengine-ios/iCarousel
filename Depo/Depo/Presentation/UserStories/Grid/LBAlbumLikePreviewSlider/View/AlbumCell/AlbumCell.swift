//
//  AlbumCell.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/4/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol SmartAlbumCell {
    func setup(withItem item: SliderItem)
}

class AlbumCell: UICollectionViewCell, SmartAlbumCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var previewBackView: UIView!
    @IBOutlet private weak var previewImage1: LoadingImageView!
    @IBOutlet private weak var previewImage2: LoadingImageView!
    @IBOutlet private weak var previewImage3: LoadingImageView!
    @IBOutlet private weak var previewImage4: LoadingImageView!
    @IBOutlet private weak var placeholderImage: UIImageView!
    @IBOutlet private weak var bigPreviewImage: LoadingImageView!

    
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
            
            setupImage(previewImage1, path: items.first)
            setupImage(previewImage2, path: items[safe: 1])
            setupImage(previewImage3, path: items[safe: 2])
            setupImage(previewImage4, path: items[safe: 3])
        } else {
            previewBackView.isHidden = true
            placeholderImage.image = item.placeholderImage
        }
    }
    
    fileprivate func setupImage(_ imageView: LoadingImageView, path: PathForItem?) {
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
