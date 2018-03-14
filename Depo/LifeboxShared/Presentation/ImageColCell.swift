//
//  ImageColCell.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 2/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class ImageColCell: UICollectionViewCell {
    
    @IBOutlet private weak var photoImageView: UIImageView! {
        didSet {
            photoImageView.backgroundColor = UIColor.lightGray
        }
    }
    
    func setup(with shareData: ShareData) {
        ShareDataImageLoader.shared.loadImage(for: photoImageView, with: shareData)
    }
    
    func setup(isCurrentUploading: Bool) {
        photoImageView.alpha = isCurrentUploading ? 1 : 0.6 /// design constants
    }
}
