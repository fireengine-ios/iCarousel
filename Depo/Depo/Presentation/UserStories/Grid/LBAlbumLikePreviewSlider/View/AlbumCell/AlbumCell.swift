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
    @IBOutlet weak var previewBackView: UIView!
    @IBOutlet weak var previewImage1: LoadingImageView!
    @IBOutlet weak var previewImage2: LoadingImageView!
    @IBOutlet weak var previewImage3: LoadingImageView!
    @IBOutlet weak var previewImage4: LoadingImageView!
    
    func setup(forItems items: [Item], titleText: String) {
        setupImage(previewImage1, item: items.first)
        setupImage(previewImage2, item: items[safe: 1])
        setupImage(previewImage3, item: items[safe: 2])
        setupImage(previewImage4, item: items[safe: 3])
        titleLabel.text = titleText
    }
    
    fileprivate func setupImage(_ imageView: LoadingImageView, item: Item?) {
        imageView.backgroundColor = UIColor.lightGray.lighter(by: 20.0)
        if let item = item {
            imageView.loadImageForItem(object: item)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = ""
        previewBackView.layer.borderWidth = 1
        previewBackView.layer.borderColor = ColorConstants.blueColor.cgColor
    }
}
