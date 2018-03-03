//
//  ImageColCell.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 2/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class ImageColCell: UICollectionViewCell {
    
    @IBOutlet private weak var photoImageView: UIImageView!
    
    func setImage(_ image: UIImage?) {
        photoImageView.setScreenScaledImage(image)
    }
}

private extension UIImageView {
    func setScreenScaledImage(_ newImage: UIImage?) {
        image = newImage?.resizedImage(to: bounds.size.screenScaled)
    }
}
