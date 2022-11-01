//
//  ForYouGradientCollectionViewCell.swift
//  Depo
//
//  Created by Burak Donat on 29.10.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

class ForYouGradientCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var thumbnailImage: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
            newValue.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 2
            newValue.font = .appFont(.medium, size: 14)
            newValue.textColor = .white
        }
    }
    
    @IBOutlet private weak var emptyAlbumView: UIView! {
        willSet {
            newValue.isHidden = true
            newValue.layer.borderWidth = 1
            newValue.layer.cornerRadius = 5
            newValue.layer.borderColor = AppColor.darkTint.cgColor
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        addGradientLayer()
    }
    
    func configureAlbum(with album: AlbumItem) {
        titleLabel.text = album.name
        
        switch album.preview?.patchToPreview {
        case .remoteUrl(let url):
            emptyAlbumView.isHidden = url != nil
            thumbnailImage.sd_setImage(with: url, completed: nil)
        default:
            break
        }
    }
    
    func configure(with wrapData: WrapData) {
        emptyAlbumView.isHidden = true
        titleLabel.text = wrapData.name
        
        switch wrapData.patchToPreview {
        case .remoteUrl(let url):
            thumbnailImage.sd_setImage(with: url, completed: nil)
        default:
            break
        }
    }
    
    private func addGradientLayer() {
        thumbnailImage.addGradient(firstColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
                                   secondColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor)
    }

}
