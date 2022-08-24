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
    enum SyncStatus: Equatable {
        case notSynced
        case syncInQueue
        case syncing(value: CGFloat)
        case synced
        case syncFailed
        // no need  in clouds OR other staff
        case regular
        
        var isBleached: Bool { [.notSynced, .syncInQueue, .syncFailed].contains(self) }

        var icon: AppImage? {
            switch self {
            case .notSynced:
                return Image.iconSyncStatusNotSynced
            case .syncInQueue:
                return Image.iconSyncStatusQueued
            case .syncing, .regular:
                return nil
            case .synced:
                return Image.iconSyncStatusSynced
            case .syncFailed:
                return Image.iconSyncStatusFailed
            }
        }
   }

    @IBOutlet private weak var favoriteImageView: UIImageView! {
        willSet {
            newValue.accessibilityLabel = TextConstants.accessibilityFavorite
        }
    }
    
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var syncStatusImageView: UIImageView!
    @IBOutlet private weak var checkmarkImageView: UIImageView!
    
    @IBOutlet private weak var selectionStateView: UIView! {
        willSet {
            newValue.layer.borderWidth = 3
            newValue.layer.borderColor = AppColor.tint.cgColor
            newValue.alpha = 0
        }
    }
    
    @IBOutlet private weak var bleachView: UIView!

    @IBOutlet private weak var thumbnailBlurVisualEffectView: UIVisualEffectView! {
        willSet {
            newValue.alpha = 0.5
        }
    }

    @IBOutlet weak var videoPlayIcon: UIImageView! {
        willSet {
            newValue.image = Image.iconPlay.image
        }
    }
    
    @IBOutlet weak var videoDurationLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.whiteColor
            newValue.font = .appFont(.medium, size: 12)
        }
    }
    
    var filesDataSource: FilesDataSource?
    private(set) var trimmedLocalFileID: String?

    private var cellId = ""
    private var cellImageManager: CellImageManager?
    private var uuid: String?
    private var requestImageID: PHImageRequestID?
    private var isBlurred = false
    private var currentFileType = FileType.image
    
    private var progressLayer: CAShapeLayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbnailImageView.contentMode = .scaleAspectFill
        backgroundColor = ColorConstants.fileGreedCellColor
        
        isAccessibilityElement = true
        accessibilityTraits = .image
    }

    deinit {
        cancelImageLoading()
        cancelLocalRequest()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        selectionStateView.layer.borderColor = AppColor.tint.cgColor
    }

    // MARK: Utility Methods(Public)

    func setup(with mediaItem: MediaItem) {
        currentFileType = FileType(value: mediaItem.fileTypeValue)

        checkmarkImageView.isHidden = true

        accessibilityLabel = mediaItem.nameValue ?? ""
        favoriteImageView.isHidden = !mediaItem.favoritesValue

        if mediaItem.isLocalItemValue, mediaItem.fileSizeValue < NumericConstants.fourGigabytes {
            update(syncStatus: .notSynced)
        } else {
            update(syncStatus: .regular)
        }
        
        switch currentFileType {
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
    
    func didEndDisplay() {
        cancelImageLoading()
        layer.removeAllAnimations()
    }

    func update(syncStatus: SyncStatus) {
        syncStatusImageView.image = syncStatus.icon?.image

        if syncStatus.isBleached {
            bleachView.backgroundColor = AppColor.darkContentOverlay.color
        } else if currentFileType == .video {
            bleachView.backgroundColor = AppColor.lightContentOverlay.color
        } else {
            bleachView.backgroundColor = .clear
        }

        switch syncStatus {
        case .syncing(let value):
            runOrUpdateProgress(value: value)
        default:
            stopProgressing()
        }
    }
    
    // MARK: Utility Methods(Private)
    
    private func resetImage() {
        thumbnailImageView.image = nil
        isBlurred = false
        stopProgressing()
        cancelImageLoading()
        cancelLocalRequest()
    }
}

// MARK: - Cancelable

extension PhotoVideoCell {
    private func cancelLocalRequest() {
        if let requestID = requestImageID {
            filesDataSource?.cancelImageRequest(requestImageID: requestID)
            requestImageID = nil
        }
    }
    
    private func cancelImageLoading() {
        thumbnailImageView.sd_cancelCurrentImageLoad()
        cellImageManager?.cancelImageLoading()
    }
}

// MARK: - Selectable

extension PhotoVideoCell {
    func updateSelection(isSelectionMode: Bool, animated: Bool) {
        videoPlayIcon.isHidden = isSelectionMode || currentFileType != .video
        checkmarkImageView.isHidden = !isSelectionMode
        let selectionStateImage = isSelected ? Image.iconCheckmarkSelected : Image.iconCheckmarkNotSelected
        checkmarkImageView.image = selectionStateImage.image
        
        let selection = isSelectionMode && isSelected
        if animated {
            UIView.animate(withDuration: NumericConstants.animationDuration) {
                self.selectionStateView.alpha = selection ? 1 : 0
            }
        } else {
            selectionStateView.alpha = selection ? 1 : 0
        }
    }
}

// MARK: - ImageSettable

extension PhotoVideoCell {
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
        
        cellImageManager?.loadImage(thumbnailUrl: smalUrl, url: mediumUrl, isOwner: true, completionBlock: imageSetBlock)
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
}

// MARK: - Progressable

extension PhotoVideoCell {
    
    /// not working for cell update (become favorite)
    /// override func prepareForReuse() {}
    func setProgressForObject(progress: Float) {
        DispatchQueue.toMain {
            let value = CGFloat(progress)
            self.update(syncStatus: .syncing(value: value))
        }
    }
    
    private func runOrUpdateProgress(value: CGFloat) {
        addProgressIfNeeded()
        progressLayer?.strokeEnd = value
    }
    
    private func addProgressIfNeeded() {
        guard progressLayer == nil else {
            return
        }

        let layer = CircleProgressLayer(
            size: syncStatusImageView.bounds.size.applying(.init(scaleX: 0.8, y: 0.8)),
            lineWidth: 2,
            fillColor: .clear,
            strokeColor: .white
        )
        syncStatusImageView.layer.addSublayer(layer)
        progressLayer = layer
    }
    
    private func stopProgressing() {
        progressLayer?.removeFromSuperlayer()
        progressLayer = nil
    }
}

final class CircleProgressLayer: CAShapeLayer {
    /// top - 3 * pi / 2
    /// bottom - pi / 2
    /// left - pi
    /// right - 0 * pi OR 2 * pi
    static let startAngle = CGFloat.pi * 1.5
    static let endAngle = CGFloat.pi * 3.5
    static let anchorPoint = CGPoint(x: 0.5, y: 0.5)

    init(size: CGSize, lineWidth: CGFloat, fillColor: UIColor, strokeColor: UIColor) {
        super.init()
        configure(with: size, lineWidth: lineWidth, fillColor: fillColor, strokeColor: strokeColor)
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) { nil }
    
    private func configure(with size: CGSize, lineWidth: CGFloat, fillColor: UIColor, strokeColor: UIColor) {
        let center = size.height / 2
        let path = UIBezierPath(
            arcCenter: CGPoint(x: center, y: center),
            radius: center,
            startAngle: Self.startAngle,
            endAngle: Self.endAngle,
            clockwise: true
        ).cgPath
        self.path = path
        self.fillColor = fillColor.cgColor
        self.strokeColor = strokeColor.cgColor
        self.lineWidth = lineWidth
        anchorPoint = Self.anchorPoint
        frame = CGRect(origin: .zero, size: size)
    }
}
