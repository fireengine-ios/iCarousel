//
//  ShareDataImageLoader.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 3/14/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

/// must be singleton or static cash
final class ShareDataImageLoader {
    
    static let shared = ShareDataImageLoader()
    
    private let cash = NSCache<NSURL, UIImage>()
    
    func loadImage(for imageView: UIImageView, with shareData: ShareData) {
        
        if let image = cash.object(forKey: shareData.url as NSURL) {
            let resizedImage = image.resizedImage(to: imageView.bounds.size.screenScaled)
            imageView.image = resizedImage
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            FilesExistManager.shared.waitFilePreparation(at: shareData.url) { [weak self] result in
                
                switch result {
                case .success(_):
                    guard let image = shareData.image else {
                        return
                    }
                    self?.cash.setObject(image, forKey: shareData.url as NSURL)
                    
                    let resizedImage = image.resizedImage(to: imageView.bounds.size.screenScaled)
                    
                    DispatchQueue.main.async {
                        imageView.image = resizedImage
                    }
                case .failed(_):
                    DispatchQueue.main.async {
                        imageView.image = Images.noDocuments
                    }
                }
                
                DispatchQueue.main.async {
                    imageView.backgroundColor = UIColor.white
                }
            }
        }   
    }
    
}
