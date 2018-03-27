//
//  CollectionViewCellForFaceImage.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class CollectionViewCellForFaceImage: BaseCollectionViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activity: UIActivityIndicatorView!
    @IBOutlet private weak var selectionView: UIView!
    @IBOutlet private weak var visibleImageView: UIImageView!
    @IBOutlet private weak var transperentView: UIView!
        
    override func awakeFromNib() {
        super.awakeFromNib()

        nameLabel.textColor = ColorConstants.whiteColor
        nameLabel.font = UIFont.TurkcellSaturaBolFont(size: 14)
    }
    
    override func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        isCellSelectionEnabled = isSelectionActive
        
        if isSelectionActive {
            visibleImageView.isHidden = !isCellSelected
            transperentView.alpha = isCellSelected ? NumericConstants.faceImageCellTransperentAlpha : 0
            isCellSelected = !isCellSelected
        }
        
    }
    
    override func confireWithWrapperd(wrappedObj: BaseDataSourceItem) {
        guard let item = wrappedObj as? Item else {
            return
        }
        
        if (isAlreadyConfigured) {
            return
        }
        
        visibleImageView.isHidden = !isCellSelected
        transperentView.alpha = isCellSelected ? NumericConstants.faceImageCellTransperentAlpha : 0
        
        imageView.image = nil
        
        if let thing = wrappedObj as? ThingsItem {
            nameLabel.text = thing.responseObject.code
        } else {
            nameLabel.text = item.name
        }
        
        if let peopleItem = wrappedObj as? PeopleItem,
            let isVisible = peopleItem.responseObject.visible {
            isCellSelected = isVisible
            
            if !isVisible {
                visibleImageView.isHidden = isVisible
                transperentView.alpha = NumericConstants.faceImageCellTransperentAlpha
            }
            
            visibleImageView.isHidden = isCellSelected
            transperentView.alpha = !isCellSelected ? NumericConstants.faceImageCellTransperentAlpha : 0
        }
        
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitImage
        accessibilityLabel = item.name
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        imageView.sd_cancelCurrentImageLoad()
        isAlreadyConfigured = false
    }
    
    override func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) { }
    
    override func setImage(image: UIImage?, animated: Bool) {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.opacity = NumericConstants.numberCellDefaultOpacity
        imageView.image = image
        if animated {
            UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
                self.imageView.layer.opacity = NumericConstants.numberCellAnimateOpacity
            })
        } else {
            imageView.layer.opacity = NumericConstants.numberCellAnimateOpacity
        }
        
        isAlreadyConfigured = true
        backgroundColor = ColorConstants.fileGreedCellColor
    }
    
    override func setImage(with url: URL) {
        imageView.contentMode = .scaleAspectFill
        imageView.sd_setImage(with: url, placeholderImage: nil, options: [.avoidAutoSetImage]) { [weak self] image, error, cacheType, url in
            guard error == nil else {
                print("SD_WebImage_setImage error: \(error!.localizedDescription)")
                return
            }
            
            self?.setImage(image: image, animated: true)
        }
        
        isAlreadyConfigured = true
        backgroundColor = ColorConstants.fileGreedCellColor
    }
    
    class func getCellSise() -> CGSize {
        return CGSize(width: 90.0, height: 90.0)
    }
    
}
