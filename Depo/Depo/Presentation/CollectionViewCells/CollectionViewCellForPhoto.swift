//
//  CollectionViewCellForPhoto.swift
//  Depo
//
//  Created by Oleg on 01.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import SDWebImage


class CollectionViewCellForPhoto: BaseCollectionViewCell {
    @IBOutlet weak var favoriteIcon: UIImageView!
    
    @IBOutlet weak var imageView: UIImageView!
   
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var cloudStatusImage: UIImageView!
    
    @IBOutlet weak var selectionImageView: UIImageView!
    
    @IBOutlet weak var selectionView: UIView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    static let borderW: CGFloat = 3
    
    private let visualEffectBlur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    private var cellImageManager: CellImageManager?
    private var uuid: String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionView.layer.borderWidth = CollectionViewCellForPhoto.borderW
        selectionView.layer.borderColor = ColorConstants.darkBlueColor.cgColor
        selectionView.alpha = 0
        
        progressView.tintColor = ColorConstants.blueColor
        imageView.backgroundColor = UIColor.clear
        
        favoriteIcon.accessibilityLabel = TextConstants.accessibilityFavorite
        
        visualEffectBlur.alpha = 0.75
        visualEffectBlur.isHidden = true
        visualEffectBlur.frame = imageView.bounds
        visualEffectBlur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        imageView.addSubview(visualEffectBlur)
        
    }
    
    override func configureWithWrapper(wrappedObj: BaseDataSourceItem) {
        guard let wrappered = wrappedObj as? WrapData, !isAlreadyConfigured else {
            return
        }

        progressView.isHidden = true
        
        if let item = wrappedObj as? Item {
            favoriteIcon.isHidden = !item.favorites
        }

        if wrappered.isLocalItem && wrappered.fileSize < NumericConstants.fourGigabytes {
            cloudStatusImage.image = UIImage(named: "objectNotInCloud")
        } else {
            cloudStatusImage.image = UIImage()
        }
        
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitImage
        accessibilityLabel = wrappered.name
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        reset()
        
        isAlreadyConfigured = false
    }
    
    override func updating() {
        super.updating()
        self.backgroundColor = UIColor.white
    }
    
    override func setImage(image: UIImage?, animated: Bool) {
        imageView.contentMode = .scaleAspectFill
        if animated {
            imageView.layer.opacity = NumericConstants.numberCellDefaultOpacity
            imageView.image = image
            UIView.animate(withDuration: NumericConstants.setImageAnimationDuration, animations: {
                self.imageView.layer.opacity = NumericConstants.numberCellAnimateOpacity
            })
        } else {
            imageView.image = image
        }
        
        isAlreadyConfigured = true
    }
    
    override func setImage(with url: URL) {
        let cacheKey = url.byTrimmingQuery
        cellImageManager = CellImageManager.instance(by: cacheKey)
        uuid = cellImageManager?.uniqueId
        let imageSetBlock: CellImageManagerOperationsFinished = { [weak self] image, cached, shouldBeBlurred, uniqueId in
            DispatchQueue.toMain {
                guard let image = image, let uuid = self?.uuid, uuid == uniqueId else {
                    return
                }
                
                self?.setImage(image: image, animated: false)
            }
        }
        
        cellImageManager?.loadImage(thumbnailUrl: nil, url: url, completionBlock: imageSetBlock)
        
        isAlreadyConfigured = true
        
    }
    
    override func setImage(with metaData: BaseMetaData) {
        let cacheKey = metaData.mediumUrl?.byTrimmingQuery
        cellImageManager = CellImageManager.instance(by: cacheKey)
        uuid = cellImageManager?.uniqueId
        let imageSetBlock: CellImageManagerOperationsFinished = { [weak self] image, cached, shouldBeBlurred, uniqueId in
            DispatchQueue.toMain {
                guard let image = image, let uuid = self?.uuid, uuid == uniqueId else {
                    return
                }
                
                let needAnimate = !cached && (self?.imageView.image == nil)
                self?.setImage(image: image, animated: needAnimate)
            }
        }

        cellImageManager?.loadImage(thumbnailUrl: metaData.smalURl, url: metaData.mediumUrl, completionBlock: imageSetBlock)

        isAlreadyConfigured = true
    }

    override func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        selectionImageView.isHidden = !isSelectionActive
        selectionImageView.image = UIImage(named: isSelected ? "selected" : "notSelected")
        
        let selection = isSelectionActive && isSelected
        UIView.animate(withDuration: NumericConstants.animationDuration) { 
            self.selectionView.alpha = selection ? 1 : 0
        }
        
    }

    
    class func getCellSise() -> CGSize {
        return CGSize(width: 90.0, height: 90.0)
    }
    
    func setProgressForObject(progress: Float, blurOn: Bool = false) {
        DispatchQueue.main.async {
            self.visualEffectBlur.isHidden = !blurOn
        
            self.progressView.isHidden = false
            self.progressView.setProgress(progress, animated: false)
        }
    }
    
    func finishedUploadForObject() {
        DispatchQueue.main.async {
            self.visualEffectBlur.isHidden = true
            self.progressView.isHidden = true
            self.cloudStatusImage.image = UIImage(named: "objectInCloud")
        }
    }
    
    func cancelledUploadForObject() {
        DispatchQueue.main.async {
            self.visualEffectBlur.isHidden = true
            self.progressView.isHidden = true
        }
    }
    
    func cleanCell() {
        cancelImageLoading()
        
        DispatchQueue.main.async {
            self.visualEffectBlur.isHidden = true
            self.progressView.isHidden = true
        }
    }
    
    func finishedDownloadForObject() {
        progressView.isHidden = true
    }
    
    func resetCloudImage() {
        cloudStatusImage.image = UIImage()
    }
    
    private func cancelImageLoading() {
        imageView.sd_cancelCurrentImageLoad()
        cellImageManager?.cancelImageLoading()
    }
    
    private func reset() {
        cellImageManager = nil
        imageView.image = nil
        uuid = nil
        setAssetId(nil)
    }
    
    deinit {
        cancelImageLoading()
    }

}
