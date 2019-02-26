//
//  PhotoVideoCell.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/17/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

protocol PhotoVideoCellDelegate: class {
    func photoVideoCellOnLongPressBegan(at indexPath: IndexPath)
}

final class PhotoVideoCell: UICollectionViewCell {

    @IBOutlet private weak var favoriteImageView: UIImageView! {
        willSet {
            newValue.accessibilityLabel = TextConstants.accessibilityFavorite
        }
    }
    
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var cloudStatusImageView: UIImageView!
    @IBOutlet private weak var checkmarkImageView: UIImageView!
    
    @IBOutlet private weak var selectionStateView: UIView! {
        willSet {
            newValue.layer.borderWidth = 3
            newValue.layer.borderColor = ColorConstants.darkBlueColor.cgColor
            newValue.alpha = 0
        }
    }
    
    @IBOutlet private weak var progressView: UIProgressView! {
        willSet {
            newValue.tintColor = ColorConstants.blueColor
        }
    }
    
    @IBOutlet private weak var blurVisualEffectView: UIVisualEffectView! {
        willSet {
            newValue.tintColor = ColorConstants.blueColor
            newValue.alpha = 0.75
        }
    }
    
    weak var delegate: PhotoVideoCellDelegate?
    var indexPath: IndexPath?
    private var cellId = ""
    private lazy var filesDataSource = FilesDataSource()
    private var cellImageManager: CellImageManager?
    private var uuid: String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLongPressRecognizer()
        
        thumbnailImageView.contentMode = .scaleAspectFill
        backgroundColor = ColorConstants.fileGreedCellColor
        
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitImage
    }
    
    private func setupLongPressRecognizer() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
        longPressRecognizer.minimumPressDuration = BaseCollectionViewCell.durationOfSelection
        longPressRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(longPressRecognizer)
    }
    
    func setup(with wraped: WrapData) {
        
        accessibilityLabel = wraped.name
        favoriteImageView.isHidden = !wraped.favorites
        
        if wraped.isLocalItem, wraped.fileSize < NumericConstants.fourGigabytes {
            cloudStatusImageView.image = UIImage(named: "objectNotInCloud")
        } else {
            cloudStatusImageView.image = nil
        }
        
        switch wraped.patchToPreview {
        case .localMediaContent(let local):
            cellId = local.asset.localIdentifier
            filesDataSource.getAssetThumbnail(asset: local.asset) { [weak self] image in
                DispatchQueue.main.async {
                    if self?.cellId == local.asset.localIdentifier, let image = image {
                        self?.setImage(image: image, animated:  false)
                    }
                }
            }
        case let .remoteUrl(url):
            if url != nil, let meta = wraped.metaData {
                setImage(with: meta)
            }
        }
    }
    
    private func setImage(with metaData: BaseMetaData) {
        let cacheKey = metaData.mediumUrl?.byTrimmingQuery
        cellImageManager = CellImageManager.instance(by: cacheKey)
        uuid = cellImageManager?.uniqueId
        let imageSetBlock: CellImageManagerOperationsFinished = { [weak self] image, cached, uniqueId in
            DispatchQueue.toMain {
                guard let image = image, let uuid = self?.uuid, uuid == uniqueId else {
                    return
                }
                
                let needAnimate = !cached && (self?.thumbnailImageView.image == nil)
                self?.setImage(image: image, animated: needAnimate)
            }
        }
        
        cellImageManager?.loadImage(thumbnailUrl: metaData.smalURl, url: metaData.mediumUrl, completionBlock: imageSetBlock)
    }
    
    private func setImage(image: UIImage, animated: Bool) {
        if animated {
            thumbnailImageView.layer.opacity = NumericConstants.numberCellDefaultOpacity
            thumbnailImageView.image = image
            UIView.animate(withDuration: 0.2) {
                self.thumbnailImageView.layer.opacity = NumericConstants.numberCellAnimateOpacity
            }
        } else {
            thumbnailImageView.image = image
        }
    }
    
    private func setImage(with url: URL) {
        thumbnailImageView.sd_setImage(with: url, placeholderImage: nil, options:[.queryDiskSync, .avoidAutoSetImage]) { [weak self] image, error, cacheType, url in
            
            guard let `self` = self, let image = image else {
                return
            }
            
            let shouldAnimate = (cacheType == .none)
            self.setImage(image: image, animated: shouldAnimate)
        }
    }
    
    @objc private func onLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            
            set(isSelected: true, isSelectionMode: true, animated: true)
            if let delegate = delegate, let indexPath = indexPath {
                delegate.photoVideoCellOnLongPressBegan(at: indexPath)
            }
        }
    }
    
    func set(isSelected: Bool, isSelectionMode: Bool, animated: Bool) {
        checkmarkImageView.isHidden = !isSelectionMode
        checkmarkImageView.image = UIImage(named: isSelected ? "selected" : "notSelected")
        
        let selection = isSelectionMode && isSelected
        if animated {
            UIView.animate(withDuration: NumericConstants.animationDuration) { 
                self.selectionStateView.alpha = selection ? 1 : 0
            }
        } else {
            selectionStateView.alpha = selection ? 1 : 0
        }
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        cancelImageLoading()
        cancelledUploadForObject()
        reset()
    }
    
    func setProgressForObject(progress: Float, blurOn: Bool = false) {
        DispatchQueue.toMain {
            self.blurVisualEffectView.isHidden = !blurOn
            self.progressView.isHidden = false
            self.progressView.setProgress(progress, animated: false)
        }
    }
    
    func finishedUploadForObject() {
        DispatchQueue.toMain {
            self.blurVisualEffectView.isHidden = true
            self.progressView.isHidden = true
            self.cloudStatusImageView.image = UIImage(named: "objectInCloud")
        }
    }
    
    func cancelledUploadForObject() {
        DispatchQueue.toMain {
            self.blurVisualEffectView.isHidden = true
            self.progressView.isHidden = true
        }
    }
    
    func resetCloudImage() {
        cloudStatusImageView.image = nil
    }
    
    func didEndDisplay() {
        cancelImageLoading()
    }
    
    private func cancelImageLoading() {
        thumbnailImageView.sd_cancelCurrentImageLoad()
        cellImageManager?.cancelImageLoading()
    }
    
    private func reset() {
        cellImageManager = nil
        thumbnailImageView.image = nil
        favoriteImageView.isHidden = true
        checkmarkImageView.isHidden = true
        uuid = nil
        indexPath = nil
        cellId = ""
    }

    deinit {
        cancelImageLoading()
    }
}
