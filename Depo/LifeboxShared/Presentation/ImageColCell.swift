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

//CGSize+Scale
extension CGSize {
    var screenScaled: CGSize {
        return self * UIScreen.main.scale
    }
    
    static func * (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width * right, height: left.height * right)
    }
    
    /// maybe will be need
//    static func * (left: CGSize, right: CGSize) -> CGSize {
//        return CGSize(width: left.width * right.width, height: left.height * right.height)
//    }
}

extension UIImageView {
    func setScreenScaledImage(_ newImage: UIImage?) {
        image = newImage?.resizedImage(to: bounds.size.screenScaled)
    }
}
