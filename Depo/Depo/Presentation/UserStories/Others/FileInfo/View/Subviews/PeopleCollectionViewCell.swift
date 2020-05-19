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
            newValue.text = " "
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 14)
            newValue.textColor = ColorConstants.darkText
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelImageLoading()
    }
    
    func setup(with item: PeopleOnPhotoItemResponse) {
        titleLabel.text = item.name
        
        if let thumbnailURL = item.thumbnailURL {
            DispatchQueue.global().async {
              if let data = try? Data(contentsOf: thumbnailURL)
              {
                DispatchQueue.main.async {
                    self.thumbnail.image = UIImage(data: data)
                }
              }
           }
        }
    }
    
    func cancelImageLoading() {
        thumbnail.cancelLoadRequest()
        thumbnail.image = nil
    }
    
}
