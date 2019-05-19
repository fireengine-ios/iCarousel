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
    func onLongPressBegan(at cell: PhotoVideoCell)
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
    
    @IBOutlet weak var videoPlayIcon: UIImageView!
    
    @IBOutlet weak var videoDurationLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.whiteColor
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 16)
        }
    }
    
    
    weak var delegate: PhotoVideoCellDelegate?
    private var cellId = ""
    var filesDataSource: FilesDataSource?
    private var cellImageManager: CellImageManager?
    private var uuid: String?
    private(set) var trimmedLocalFileID: String?
    
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
        
        switch wraped.fileType {
        case .video:
            videoDurationLabel.text = wraped.duration
            videoPlayIcon.isHidden = false
            videoDurationLabel.isHidden = false
        default:
            videoPlayIcon.isHidden = true
            videoDurationLabel.isHidden = true
        }
        
        switch wraped.patchToPreview {
        case .localMediaContent(let local):
            cellId = local.asset.localIdentifier
            
            filesDataSource?.getAssetThumbnail(asset: local.asset) { [weak self] image in
                DispatchQueue.main.async {
                    if self?.cellId == local.asset.localIdentifier, let image = image {
                        self?.setImage(image: image, animated:  false)
                    }
                }
            }
            
        case .remoteUrl(_):
            if let meta = wraped.metaData {
                setImage(smalUrl: meta.smalURl, mediumUrl: meta.mediumUrl)
            }
        }
    }
    
    func setup(with mediaItem: MediaItem) {
        /// reset all except thumbnail and cellId
        reset()
        
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
            print("--- cellImageManagerUniqueId")
            return
        }
        
        if let assetIdentifier = assetIdentifier {
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
                
                self.filesDataSource?.getAssetThumbnail(asset: asset) { [weak self] image in
                    DispatchQueue.main.async {
                        if self?.cellId == asset.localIdentifier, let image = image {
                            self?.setImage(image: image, animated:  false)
                        }
                    }
                }
            }
        } else if let metadata = mediaItem.metadata {
            setImage(smalUrl: URL(string: metadata.smalURl ?? ""),
                     mediumUrl: URL(string: metadata.mediumUrl ?? ""))
        }
        
        
    }
    
    private func setImage(smalUrl: URL?, mediumUrl: URL?) {
        let cacheKey = mediumUrl?.byTrimmingQuery
        cellImageManager = CellImageManager.instance(by: cacheKey)
        
        guard uuid != cellImageManager?.uniqueId else {
            print("--- cellImageManagerUniqueId")
            return
        }
        
        uuid = cellImageManager?.uniqueId
        resetImage()
        
        let imageSetBlock: CellImageManagerOperationsFinished = { [weak self] image, cached, uniqueId in
            DispatchQueue.toMain {
                guard let image = image, let uuid = self?.uuid, uuid == uniqueId else {
                    return
                }
                
                let needAnimate = !cached && (self?.thumbnailImageView.image == nil)
                self?.setImage(image: image, animated: needAnimate)
            }
        }
        
        cellImageManager?.loadImage(thumbnailUrl: smalUrl, url: mediumUrl, completionBlock: imageSetBlock)
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
            if let delegate = delegate {
                delegate.onLongPressBegan(at: self)
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

    /// not working for cell update (become favorite)
    /// override func prepareForReuse() {}
    
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
    
    private func reset() {
        cellImageManager = nil
        favoriteImageView.isHidden = true
        checkmarkImageView.isHidden = true
        uuid = nil
        trimmedLocalFileID = nil
    }
    
    private func resetImage() {
        thumbnailImageView.image = nil
        cancelImageLoading()
        cancelledUploadForObject()
    }

    deinit {
        cancelImageLoading()
    }
}
