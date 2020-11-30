//
//  TBMatikPhotoView.swift
//  Depo
//
//  Created by Andrei Novikau on 9/19/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

final class TBMatikPhotoView: UIView, NibInit {

    @IBOutlet private weak var noImageBackgroundView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.photoCell.withAlphaComponent(0.85)
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 4
        }
    }
    
    @IBOutlet private weak var noImageLabel: UILabel! {
        willSet {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let text = TextConstants.tbMaticPhotosNoPhotoText
            let attributedString = NSMutableAttributedString(string: text,
                                                             attributes: [.font: UIFont.TurkcellSaturaFont(size: 20),
                                                                          .foregroundColor: UIColor.lrBrownishGrey,
                                                                          .paragraphStyle: paragraphStyle])
            
            
            let range = (text as NSString).range(of: TextConstants.tbMaticPhotosNoPhotoBoldText)
            if range.location != NSNotFound {
                attributedString.setAttributes([.font: UIFont.TurkcellSaturaBolFont(size: 20),
                                                .foregroundColor: UIColor.lrBrownishGrey,
                                                .paragraphStyle: paragraphStyle],
                                               range: range)
            }
            
            newValue.attributedText = attributedString
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }

    @IBOutlet private weak var imageView: UIImageView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 4
        }
    }
    
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    
    var hasImage: Bool {
        return imageView.image != nil
    }
    
    var image: UIImage? {
        imageView.image
    }
    
    var setImageHandler: VoidHandler?
    
    private var cellImageManager: CellImageManager?
    private var uuid: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
    }
    
    func setup(with item: Item?) {
        imageView.image = nil
        imageView.alpha = 0
        cellImageManager?.cancelImageLoading()
        
        if let preview = item?.patchToPreview, case let .remoteUrl(url) = preview {
            loadImage(with: url)
        } else {
            setImage(nil)
        }
    }
    
    private func loadImage(with url: URL?) {
        guard let url = url else {
            setImage(nil)
            return
        }
        
        let cacheKey = url.byTrimmingQuery
        cellImageManager = CellImageManager.instance(by: cacheKey)
        uuid = cellImageManager?.uniqueId
        
        loadingIndicator.startAnimating()
        
        let imageSetBlock: CellImageManagerOperationsFinished = { [weak self] image, cached, shouldBeBlurred, uniqueId in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                guard let image = image, self.uuid == uniqueId else {
                    self.setImage(nil)
                    return
                }
                self.setImage(image)
            }
        }
        
        cellImageManager?.loadImage(thumbnailUrl: nil, url: url, isOwner: true, completionBlock: imageSetBlock)
    }

    private func setImage(_ image: UIImage?) {
        loadingIndicator.stopAnimating()

        if let image = image {
            imageView.contentMode = image.size.width < image.size.height ? .scaleAspectFill : .scaleAspectFit
            imageView.image = image
            
            UIView.animate(withDuration: NumericConstants.setImageAnimationDuration) {
                self.imageView.alpha = 1
            }
        } else {
            noImageBackgroundView.isHidden = false
            imageView.isHidden = true
        }
        setImageHandler?()
    }
}
