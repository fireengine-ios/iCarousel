//
//  UploadGalleryAssetPickerCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 29.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class UploadGalleryAssetPickerCell: UICollectionViewCell {
    private var assetId: String?
    
    @IBOutlet private weak var imageView: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
            newValue.backgroundColor = .clear
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        assetId = nil
    }
    
    func setup(with asset: PHAsset) {
        guard asset.localIdentifier != assetId else {
            return
        }
        
        assetId = asset.localIdentifier
        
        LocalMediaStorage.default.getPreviewImage(asset: asset) { [weak self] image in
            DispatchQueue.main.async {
                guard self?.assetId == asset.localIdentifier else {
                    return
                }
                
                self?.imageView.image = image
            }
        }
    }
}
