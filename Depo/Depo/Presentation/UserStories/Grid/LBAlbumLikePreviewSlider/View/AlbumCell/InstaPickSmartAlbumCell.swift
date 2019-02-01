//
//  InstaPickSmartAlbumCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 01/02/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage


final class InstaPickSmartAlbumCell: UICollectionViewCell, SmartAlbumCell {

    @IBOutlet private weak var gradientBackground: RadialGradientableView! {
        didSet {
            gradientBackground.backgroundColor = UIColor.lrTealish
            gradientBackground.isNeedGradient = true
            gradientBackground.isHidden = false
        }
    }
    
    @IBOutlet private weak var noItemsBackgroundImage: UIImageView! {
        didSet {
            noItemsBackgroundImage.layer.borderWidth = 1.0
            noItemsBackgroundImage.layer.borderColor = UIColor.white.cgColor
            noItemsBackgroundImage.isHidden = false
        }
    }
    
    @IBOutlet private weak var thumbnailsContainer: UIView! {
        didSet {
            thumbnailsContainer.backgroundColor = .clear
        }
    }
    @IBOutlet private weak var thumbnailTopLeft: UIImageView!
    @IBOutlet private weak var thumbnailTopRight: UIImageView!
    @IBOutlet private weak var thumbnailBottomLeft: UIImageView!
    @IBOutlet private weak var thumbnailBottomRight: UIImageView!
    
    private lazy var thumnbails = [thumbnailTopLeft, thumbnailTopRight,
                                   thumbnailBottomLeft, thumbnailBottomRight]
    
    @IBOutlet weak var name: UILabel! {
        didSet {
            name.text = " "
            name.font = UIFont.TurkcellSaturaMedFont(size: 14)
            name.textColor = ColorConstants.darkText
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for thumbnail in thumnbails {
            thumbnail?.contentMode = .scaleAspectFill
            thumbnail?.clipsToBounds = true
        }
    }
    
    
    func setup(withItem item: SliderItem) {
        name.text = item.name
        setupAccessibility(label: item.name)
        
        guard let previews = item.previewItems, !previews.isEmpty else {
            noItemsBackgroundImage.image = item.placeholderImage
            noItemsBackgroundImage.isHidden = false
            thumbnailsContainer.isHidden = true
            return
        }
        
        thumbnailsContainer.isHidden = false
        noItemsBackgroundImage.isHidden = true
        
        updateThumbnails(with: previews, placeholder: item.previewPlaceholder)
    }
    
    private func updateThumbnails(with previews: [PathForItem], placeholder: UIImage?) {
        for i in 0..<thumnbails.count {
            if case let .some(.remoteUrl(url)) = previews[safe: i] {
                thumnbails[i]?.sd_setImage(with: url, placeholderImage: placeholder, options: [], completed: nil)
            } else {
                thumnbails[i]?.image = placeholder
            }
        }
    }
    
    private func setupAccessibility(label: String?) {
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitNone
        accessibilityLabel = label
    }
}
