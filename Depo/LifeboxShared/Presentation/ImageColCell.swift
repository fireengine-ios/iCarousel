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
    
    func setup(with shareData: ShareData) {
        self.urlIdentificator = shareData.url
        ShareDataImageLoader.shared.loadImage(for: photoImageView, with: shareData, urlIdentificator: urlIdentificator!)
        
//        DispatchQueue.global().async { [weak self] in
//            self?.urlIdentificator = shareData.url
//            FileManager.shared.waitFilePreparation(at: shareData.url) { [weak self] result in
//                if self?.urlIdentificator == shareData.url {
//                    DispatchQueue.main.async {
//                        switch result {
//                        case .success(_):
//                            self?.photoImageView.setScreenScaledImage(shareData.image)
//                        case .failed(_):
//                            self?.photoImageView.image = #imageLiteral(resourceName: "ImageNoDocuments")
//                        }
//                        self?.photoImageView.backgroundColor = UIColor.white
//                    }
//                }
//            }
//        }
    }
    
    func setup(isCurrentUploading: Bool) {
        photoImageView.alpha = isCurrentUploading ? 1 : 0.6
    }
}

final class ShareDataImageLoader {
    
    static let shared = ShareDataImageLoader()
    
    private let cash = NSCache<NSURL, UIImage>()
    
    func loadImage(for imageView: UIImageView, with shareData: ShareData, urlIdentificator: URL) {
        
        if let image = cash.object(forKey: shareData.url as NSURL) {
            let resizedImage = image.resizedImage(to: imageView.bounds.size.screenScaled)
            imageView.image = resizedImage
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            FileManager.shared.waitFilePreparation(at: shareData.url) { [weak self] result in
                
                switch result {
                case .success(_):
                    guard let image = shareData.image else {
                        return
                    }
                    self?.cash.setObject(image, forKey: shareData.url as NSURL)
                    
                    let resizedImage = image.resizedImage(to: imageView.bounds.size.screenScaled)
                    
                    DispatchQueue.main.async {
                        if urlIdentificator == shareData.url {
                            imageView.image = resizedImage
                        }
                        
                    }
                case .failed(_):
                    DispatchQueue.main.async {
                        if urlIdentificator == shareData.url {
                            imageView.image = #imageLiteral(resourceName: "ImageNoDocuments")
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    imageView.backgroundColor = UIColor.white
                }
            }
        }   
    }
    
}
