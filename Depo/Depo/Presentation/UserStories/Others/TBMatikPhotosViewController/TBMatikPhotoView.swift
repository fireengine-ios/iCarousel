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
            
            let text = TextConstants.TBMatic.Photos.noPhotoText
            let attributedString = NSMutableAttributedString(string: text,
                                                             attributes: [.font: UIFont.TurkcellSaturaFont(size: 20),
                                                                          .foregroundColor: UIColor.lrBrownishGrey,
                                                                          .paragraphStyle: paragraphStyle])
            
            
            let range = (text as NSString).range(of: TextConstants.TBMatic.Photos.noPhotoBoldText)
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
    
    private var shadowView: UIView?
    
    var needShowShadow = false {
        didSet {
            if !loadingIndicator.isAnimating {
                checkShadow()
            }
        }
    }
    
    var hasImage: Bool {
        return imageView.image != nil
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
                guard let image = image, let uuid = self.uuid, uuid == uniqueId else {
                    self.setImage(nil)
                    return
                }
                self.setImage(image)
            }
        }
        
        cellImageManager?.loadImage(thumbnailUrl: nil, url: url, completionBlock: imageSetBlock)
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
        checkShadow()
        setImageHandler?()
    }
    
    private func checkShadow() {
        if needShowShadow {
            addContentShadow()
        } else {
            removeContentShadow()
        }
    }
    
    private func addContentShadow() {
        removeContentShadow()
        
        layoutIfNeeded()
        if let image = imageView.image {
            // calculate shadow frame around image
            let height: CGFloat
            if imageView.contentMode == .scaleAspectFill {
                height = imageView.bounds.height
            } else {
                height = image.size.height * imageView.bounds.width / image.size.width
            }
            
            let frame = CGRect(x: imageView.frame.origin.x,
                               y: imageView.frame.origin.y + (imageView.bounds.height - height) * 0.5,
                               width: imageView.bounds.width,
                               height: height)
            
            shadowView = newShadowView(frame: frame)
        } else {
            shadowView = newShadowView(frame: noImageBackgroundView.frame)
        }
        
        addSubview(shadowView!)
        sendSubview(toBack: shadowView!)
    }
    
    private func removeContentShadow() {
        shadowView?.removeFromSuperview()
        shadowView = nil
    }
    
    private func newShadowView(frame: CGRect) -> UIView {
        let shadowView = UIView(frame: frame)
        shadowView.layer.masksToBounds = false
        shadowView.layer.cornerRadius = 4
        shadowView.layer.shadowRadius = 8
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowColor = UIColor.white.cgColor
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowPath = UIBezierPath(rect: shadowView.bounds).cgPath
        return shadowView
    }
}
