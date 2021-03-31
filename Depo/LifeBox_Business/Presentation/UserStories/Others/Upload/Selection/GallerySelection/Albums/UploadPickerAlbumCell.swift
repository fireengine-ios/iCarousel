//
//  UploadPickerAlbumCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 30.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class UploadPickerAlbumCell: UICollectionViewCell {

    static let height: CGFloat = 44
    
    @IBOutlet private weak var albumName: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .GTAmericaStandardRegularFont(size: 16)
            newValue.textColor = ColorConstants.Text.labelTitle
            newValue.textAlignment = .left
        }
    }
    
    @IBOutlet private weak var numberOfItems: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .GTAmericaStandardRegularFont(size: 12)
            newValue.textColor = ColorConstants.Text.labelTitle
            newValue.textAlignment = .right
        }
    }
    
    @IBOutlet private weak var separator: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.separator
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        albumName.text = ""
        numberOfItems.text = "(0)"
    }
    
    func setup(with album: LocalAlbumInfo) {
        albumName.text = album.name
        numberOfItems.text = "(\(album.numberOfItems))"
    }

}
