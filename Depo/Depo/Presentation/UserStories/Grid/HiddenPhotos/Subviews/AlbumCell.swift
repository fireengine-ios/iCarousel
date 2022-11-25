//
//  AlbumCell.swift
//  Depo
//
//  Created by Andrei Novikau on 12/17/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class AlbumCell: BaseCollectionViewCell {
    
    @IBOutlet private var thumbnailsContainer: UIView! {
        willSet {
            newValue.backgroundColor = .white
            newValue.layer.borderWidth = 0.5
            newValue.layer.masksToBounds = true
            newValue.layer.borderColor = AppColor.tint.cgColor
        }
    }
    
    @IBOutlet private weak var thumbnail: LoadingImageView! {
        willSet {
            newValue.backgroundColor = UIColor.lightGray.lighter(by: 20.0)
            newValue.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet private weak var selectionIcon: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = " "
            newValue.font = .appFont(.regular, size: 16)
            newValue.textColor = ColorConstants.darkText
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor =  AppColor.background.color
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelImageLoading()
    }
    
    func setup(with item: BaseDataSourceItem) {
        if let album = item as? AlbumItem {
            titleLabel.text = album.name ?? ""
            thumbnail.loadImage(with: album.preview, smooth: false)
        } else if let item = item as? Item {
            titleLabel.text = item.name ?? ""
            thumbnail.loadImage(with: item, smooth: false)
        } else {
            titleLabel.text = ""
            thumbnail.image = nil
        }
    }

    override func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        selectionIcon.isHidden = !isSelectionActive
        selectionIcon.image = isSelected ? Image.iconSelectFills.image : Image.iconSelectEmpty.image
    }
    
    func cancelImageLoading() {
        thumbnail.cancelLoadRequest()
        thumbnail.image = nil
    }
}
