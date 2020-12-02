//
//  PeopleCollectionViewCell.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 5/14/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PeopleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private var thumbnailsContainer: UIView! {
        willSet {
            newValue.backgroundColor = .white
        }
    }
    
    @IBOutlet private weak var thumbnail: LoadingImageView! {
        willSet {
            newValue.backgroundColor = UIColor.lightGray.lighter(by: 20.0)
            newValue.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 14)
            newValue.textColor = ColorConstants.darkText
            newValue.lineBreakMode = .byWordWrapping
            newValue.numberOfLines = 0
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelImageLoading()
    }
    
    func setup(with item: PeopleOnPhotoItemResponse) {
        titleLabel.text = item.name
        thumbnail.loadImageData(with: item.thumbnailURL, animated: true)
    }
    
    func cancelImageLoading() {
        thumbnail.cancelLoadRequest()
        thumbnail.image = nil
    }
}
