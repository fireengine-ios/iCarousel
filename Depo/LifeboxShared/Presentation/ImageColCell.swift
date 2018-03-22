//
//  ImageColCell.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 2/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class ImageColCell: UICollectionViewCell {
    
    private var urlIdentificator: URL?
    
    @IBOutlet private weak var photoImageView: UIImageView! {
        didSet {
            photoImageView.backgroundColor = UIColor.lightGray
        }
    }
    
    func config(with shareData: ShareData) {
        urlIdentificator = shareData.url
        DispatchQueue.global().async { [weak self] in
            FileManager.shared.waitFilePreparation(at: shareData.url) { [weak self] result in
                if self?.urlIdentificator == shareData.url {
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
    }
}
