//
//  AlbumCell.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/4/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AlbumCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = UIFont.TurkcellSaturaMedFont(size: 14)
            titleLabel.textColor = ColorConstants.darkText
        }
    }
    @IBOutlet weak var previewImage: LoadingImageView!
    
    func setup(forItem item: Item, titleText: String) {
        previewImage.backgroundColor = UIColor.lightGray.lighter(by: 20.0)
        previewImage.loadImageForItem(object: item)
        titleLabel.text = titleText
    }
}
