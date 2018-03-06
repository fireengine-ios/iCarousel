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
    
    func config(with shareData: ShareData) {
        DispatchQueue.global().async { [weak self] in
            FileManager.shared.waitFilePreparation(at: shareData.url) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self?.photoImageView.setScreenScaledImage(shareData.image)
                    case .failed(_):
                        self?.photoImageView.image = #imageLiteral(resourceName: "ImageNoDocuments")
                    }
                    self?.photoImageView.backgroundColor = UIColor.white
                }
            }
        }
    }
    
    func setImage(_ image: UIImage?) {
        photoImageView.setScreenScaledImage(image)
    }
}
