//
//  ForYouCollectionViewCell.swift
//  Depo
//
//  Created by Burak Donat on 23.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

final class ForYouCollectionViewCell: UICollectionViewCell {
    
    private var cellImageManager: CellImageManager?
    
    @IBOutlet private weak var thumbnailImage: LoadingImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
            newValue.layer.cornerRadius = 5
        }
    }
    
    func configure(with wrapData: WrapData, currentView: ForYouSections) {
        switch wrapData.patchToPreview {
        case .remoteUrl(let url):
            //thumbnailImage.sd_setImage(with: url, completed: nil)
            setImage(with: url!)
        default:
            break
        }
    }
    
    func configureForCollage(with wrapData: WrapData) {
        if wrapData.tmpDownloadUrl != nil {
            switch wrapData.patchToPreview {
            case .remoteUrl(let url):
                setImage(with: url!)
            default:
                break
            }
        } else {
            thumbnailImage.image = Image.createCollageThumbnail.image
        }
    }
    
    private func setImage(image: UIImage?, animated: Bool) {
        thumbnailImage.contentMode = .scaleAspectFill
        if animated {
            thumbnailImage.layer.opacity = NumericConstants.numberCellDefaultOpacity
            thumbnailImage.image = image
            UIView.animate(withDuration: NumericConstants.setImageAnimationDuration, animations: {
                self.thumbnailImage.layer.opacity = NumericConstants.numberCellAnimateOpacity
            })
        } else {
            thumbnailImage.image = image
        }
    }
    
    
    private func setImageRecover(with url: URL) {
        let cacheKey = url.byTrimmingQuery
        cellImageManager = CellImageManager.instance(by: cacheKey)
        let imageSetBlock: CellImageManagerOperationsFinished = { [weak self] image, cached, shouldBeBlurred, uniqueId in
            DispatchQueue.toMain {
                guard let image = image else {
                    return
                }
                self?.setImage(image: image, animated: false)
            }
        }
        cellImageManager?.loadImage(thumbnailUrl: nil, url: url, isOwner: true, completionBlock: imageSetBlock)
    }
    
    private func setImage(with url: URL) {
        let cacheKey = url.byTrimmingQuery
        cellImageManager = CellImageManager.instance(by: cacheKey)
        let imageSetBlock: CellImageManagerOperationsFinished = { [weak self] image, cached, shouldBeBlurred, uniqueId in
            DispatchQueue.toMain {
                guard let image = image else {
                    self?.setImageRecover(with: url)
                    return
                }
                self?.setImage(image: image, animated: false)
            }
        }
        cellImageManager?.loadImage(thumbnailUrl: nil, url: url, isOwner: true, completionBlock: imageSetBlock)
    }
    
    func configure(with data: InstapickAnalyze) {
        thumbnailImage.sd_setImage(with: data.fileInfo?.metadata?.mediumUrl, completed: nil)
    }
    
    func configure(with data: WrapData) {
        thumbnailImage.loadImageIncludingGif(with: data)
        
    }
}
