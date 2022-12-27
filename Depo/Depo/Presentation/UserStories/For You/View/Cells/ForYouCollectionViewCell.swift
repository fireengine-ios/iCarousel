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
    
    @IBOutlet private weak var thumbnailImage: LoadingImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
            newValue.layer.cornerRadius = 5
        }
    }
    
    func configure(with wrapData: WrapData, currentView: ForYouSections) {
        switch wrapData.patchToPreview {
        case .remoteUrl(let url):
            thumbnailImage.sd_setImage(with: url, completed: nil)
        default:
            break
        }
    }
    
    func configure(with data: InstapickAnalyze) {
        thumbnailImage.sd_setImage(with: data.fileInfo?.metadata?.mediumUrl, completed: nil)
    }
    
    func configure(with data: WrapData) {
        thumbnailImage.loadImageIncludingGif(with: data)
        
    }
}
