//
//  CollectionViewCellForPhoto.swift
//  Depo
//
//  Created by Oleg on 01.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import SDWebImage
import Photos

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionView.layer.borderWidth = CollectionViewCellForPhoto.borderW
        selectionView.layer.borderColor = ColorConstants.darcBlueColor.cgColor
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
    
    override func confireWithWrapperd(wrappedObj: BaseDataSourceItem) {
        guard let wrappered = wrappedObj as? WrapData else {
            return
        }
        
        if (isAlreadyConfigured) {
            return
        }
        
        progressView.isHidden = true
        
        if let item = wrappedObj as? Item {
            favoriteIcon.isHidden = !item.favorites
        }
        
        imageView.image = nil

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
        
        self.imageView.image = nil
        self.imageView.sd_cancelCurrentImageLoad()
        self.isAlreadyConfigured = false
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
            UIView.animate(withDuration: 0.2, animations: {
                self.imageView.layer.opacity = NumericConstants.numberCellAnimateOpacity
            })
        } else {
            imageView.image = image
        }
        
        backgroundColor = ColorConstants.fileGreedCellColor
        
        isAlreadyConfigured = true
    }

    override func setImage(with url: URL) {
        self.imageView.contentMode = .center
        let dateStart = Date()
        imageView.sd_setImage(with: url, placeholderImage: nil, options: [.avoidAutoSetImage]) {[weak self] image, error, cacheType, url in
            guard let `self` = self else {
                return
            }
            
            guard error == nil else {
                print("SD_WebImage_setImage error: \(error!.description)")
                return
            }
            
            let isImageLoadedNotQuickly = dateStart.timeIntervalSinceNow < -0.2
            self.setImage(image: image, animated: isImageLoadedNotQuickly)
        }
        
        isAlreadyConfigured = true
        self.backgroundColor = ColorConstants.fileGreedCellColor
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
        visualEffectBlur.isHidden = !blurOn
        
        progressView.isHidden = false
        progressView.setProgress(progress, animated: false)
    }
    
    func finishedUploadForObject() {
        DispatchQueue.main.async {
            self.visualEffectBlur.isHidden = true
            self.progressView.isHidden = true
            self.cloudStatusImage.image = UIImage(named: "objectInCloud")
        }
    }
    
    func finishedDownloadForObject() {
        progressView.isHidden = true
    }
    
    func resetCloudImage() {
        cloudStatusImage.image = UIImage()
    }

}
