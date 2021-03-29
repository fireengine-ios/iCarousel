//
//  UploadGalleryPickerCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 29.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class UploadGalleryPickerCell: UICollectionViewCell {
    
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
    }
}
