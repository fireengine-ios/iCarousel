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
            newValue.layer.borderColor = ColorConstants.darcBlueColor.cgColor
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLongPressRecognizer()
        
        thumbnailImageView.contentMode = .scaleAspectFill
        backgroundColor = ColorConstants.fileGreedCellColor
    }
    
    private func setupLongPressRecognizer() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
        longPressRecognizer.minimumPressDuration = BaseCollectionViewCell.durationOfSelection
        longPressRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(longPressRecognizer)
    }
    
    func setup(with wraped: WrapData) {
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
            
        default:
            break
        }
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
        
        thumbnailImageView.image = nil
        thumbnailImageView.sd_cancelCurrentImageLoad()
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
}
