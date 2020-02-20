//
//  PhotoVideoCell.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/17/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage


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
    
    @IBOutlet private weak var opacityBlurVisualEffectView: UIVisualEffectView! {
        willSet {
            newValue.tintColor = ColorConstants.blueColor
            newValue.alpha = 0.75
        }
    }

    @IBOutlet private weak var thumbnailBlurVisualEffectView: UIVisualEffectView! {
        willSet {
            newValue.alpha = 0.5
        }
    }

    @IBOutlet weak var videoPlayIcon: UIImageView!
    
    @IBOutlet weak var videoDurationLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.whiteColor
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 16)
        }
    }
    
    private var cellId = ""
    var filesDataSource: FilesDataSource?
    private var cellImageManager: CellImageManager?
    private var uuid: String?
    private(set) var trimmedLocalFileID: String?
    private var requestImageID: PHImageRequestID?
    private var isBlurred = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbnailImageView.contentMode = .scaleAspectFill
        backgroundColor = ColorConstants.fileGreedCellColor
        
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitImage
    }

    
    func setup(with mediaItem: MediaItem) {
        checkmarkImageView.isHidden = true
        
        accessibilityLabel = mediaItem.nameValue ?? ""
        favoriteImageView.isHidden = !mediaItem.favoritesValue
        
        if mediaItem.isLocalItemValue, mediaItem.fileSizeValue < NumericConstants.fourGigabytes {
            cloudStatusImageView.image = UIImage(named: "objectNotInCloud")
        } else {
            cloudStatusImageView.image = nil
        }
        
        let fileType = FileType(value: mediaItem.fileTypeValue)
        switch fileType {
        case .video:
            videoDurationLabel.text = WrapData.getDuration(duration: mediaItem.metadata?.duration)
            videoPlayIcon.isHidden = false
            videoDurationLabel.isHidden = false
        default:
            videoPlayIcon.isHidden = true
            videoDurationLabel.isHidden = true
        }
        
        trimmedLocalFileID = mediaItem.trimmedLocalFileID
        
        let assetIdentifier = mediaItem.isLocalItemValue ? mediaItem.localFileID : mediaItem.relatedLocal?.localFileID
        
        guard cellId != assetIdentifier else {
            /// image will not be loaded
            return
        }
        
        if let assetIdentifier = assetIdentifier {
            uuid = nil
            cellId = assetIdentifier
            resetImage()
            
            FilesDataSource.cacheQueue.async { [weak self] in
                guard
                    let self = self,
                    self.cellId == assetIdentifier,
                    let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject
                else {
                    return
                }
                self.filesDataSource?.getAssetThumbnail(asset: asset, requestID: { [weak self] requestID in
                    DispatchQueue.main.async {
                        self?.requestImageID = requestID
                    }
                }, completion: { [weak self] image in
                    DispatchQueue.main.async {
                        if self?.cellId == asset.localIdentifier, let image = image {
                            self?.setImage(image: image, shouldBeBlurred: false, animated: false)
                        }
                    }
                })
            }
        } else if let smallURL = mediaItem.metadata?.smalURl, let mediumURL = mediaItem.metadata?.mediumUrl {
            cellId = ""
            setImage(smalUrl: URL(string: smallURL), mediumUrl: URL(string: mediumURL))
        } else {
            /// nothing to show (missing dates)
            uuid = nil
            cellId = ""
            thumbnailImageView.image = nil
            isBlurred = false
        }
        
    }
    
    private func setImage(smalUrl: URL?, mediumUrl: URL?) {
        let cacheKey = mediumUrl?.byTrimmingQuery
        cellImageManager = CellImageManager.instance(by: cacheKey)
        
        if uuid == cellImageManager?.uniqueId,
            thumbnailImageView.image != nil,
            !isBlurred
        {
            /// image will not be loaded
            return
        }
        
        uuid = cellImageManager?.uniqueId

        resetImage()
        
        let imageSetBlock: CellImageManagerOperationsFinished = { [weak self] image, cached, shouldBeBlurred, uniqueId in
            DispatchQueue.toMain {
                guard let image = image, let uuid = self?.uuid, uuid == uniqueId else {
                    return
                }
                
                let needAnimate = !cached && (self?.thumbnailImageView.image == nil)
                self?.setImage(image: image, shouldBeBlurred: shouldBeBlurred, animated: needAnimate)
            }
        }
        
        cellImageManager?.loadImage(thumbnailUrl: smalUrl, url: mediumUrl, completionBlock: imageSetBlock)
    }
    
    private func setImage(image: UIImage, shouldBeBlurred: Bool, animated: Bool) {
        if animated {
            thumbnailImageView.layer.opacity = NumericConstants.numberCellDefaultOpacity
            thumbnailImageView.image = image
            UIView.animate(withDuration: 0.2) {
                self.thumbnailImageView.layer.opacity = NumericConstants.numberCellAnimateOpacity
            }
        } else {
            thumbnailImageView.image = image
        }
        thumbnailBlurVisualEffectView.isHidden = !shouldBeBlurred
        isBlurred = shouldBeBlurred
    }
    
    func updateSelection(isSelectionMode: Bool, animated: Bool) {
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

    /// not working for cell update (become favorite)
    /// override func prepareForReuse() {}
    
    func setProgressForObject(progress: Float, blurOn: Bool = false) {
        DispatchQueue.toMain {
            self.opacityBlurVisualEffectView.isHidden = !blurOn
            self.progressView.isHidden = false
            self.progressView.setProgress(progress, animated: false)
        }
    }
    
    func finishedUploadForObject() {
        DispatchQueue.toMain {
            self.opacityBlurVisualEffectView.isHidden = true
            self.progressView.isHidden = true
            self.cloudStatusImageView.image = UIImage(named: "objectInCloud")
        }
    }
    
    func cancelledUploadForObject() {
        DispatchQueue.toMain {
            self.opacityBlurVisualEffectView.isHidden = true
            self.progressView.isHidden = true
        }
    }
    
    func resetCloudImage() {
        cloudStatusImageView.image = nil
    }
    
    func showCloudImage() {
        cloudStatusImageView.image = UIImage(named: "objectNotInCloud")
    }
    
    func didEndDisplay() {
        cancelImageLoading()
        layer.removeAllAnimations()
    }
    
    private func cancelImageLoading() {
        thumbnailImageView.sd_cancelCurrentImageLoad()
        cellImageManager?.cancelImageLoading()
    }
    
    private func resetImage() {
        thumbnailImageView.image = nil
        isBlurred = false
        cancelImageLoading()
        cancelledUploadForObject()
        cancelLocalRequest()
    }
    
    private func cancelLocalRequest() {
        if let requestID = requestImageID {
            filesDataSource?.cancelImageRequest(requestImageID: requestID)
            requestImageID = nil
        }
    }

    deinit {
        cancelImageLoading()
        cancelLocalRequest()
    }
}
