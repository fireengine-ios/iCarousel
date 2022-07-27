//
//  ForYouCollectionViewCell.swift
//  Depo
//
//  Created by Burak Donat on 23.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

class ForYouCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var thumbnailImage: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
            newValue.layer.cornerRadius = 5
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with wrapData: WrapData) {
        switch wrapData.patchToPreview {
        case .remoteUrl(let url):
            thumbnailImage.sd_setImage(with: url, completed: nil)
        default:
            break
        }
    }
    
    func configureAlbum(with album: AlbumItem) {
        switch album.preview?.patchToPreview {
        case .remoteUrl(let url):
            thumbnailImage.sd_setImage(with: url, completed: nil)
        default:
            break
        }
    }
}
