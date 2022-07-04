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
    @IBOutlet private weak var visibleImageView: UIImageView!
    @IBOutlet private weak var hiddenItemsView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = AppColor.background.color
        nameLabel.font = .appFont(.medium, size: 14)
        nameLabel.textColor = AppColor.label.color
    }
    
    override func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        isCellSelectionEnabled = isSelectionActive
        
        if isSelectionActive {
            visibleImageView.isHidden = !isCellSelected
            hiddenItemsView.isHidden = !isCellSelected
            isCellSelected = !isCellSelected
            
        }
        
    }
    
    override func configureWithWrapper(wrappedObj: BaseDataSourceItem) {
        imageView.layer.cornerRadius = ((wrappedObj as? PeopleItem) != nil) ? imageView.frame.height * 0.5 : 0
        hiddenItemsView.layer.cornerRadius = hiddenItemsView.frame.height * 0.5

        guard let item = wrappedObj as? Item else {
            return
        }

        if (isAlreadyConfigured) {
            return
        }
        
        visibleImageView.isHidden = !isCellSelected
        hiddenItemsView.isHidden = !isCellSelected
        
        imageView.image = nil
        
        nameLabel.text = item.name
        
        if let peopleItem = wrappedObj as? PeopleItem,
            let isVisible = peopleItem.responseObject.visible,
            let isDemo = peopleItem.responseObject.isDemo {
            isCellSelected = isVisible
            
            if !isVisible {
                visibleImageView.isHidden = isVisible
                hiddenItemsView.isHidden = isVisible
            }
            
            visibleImageView.isHidden = isCellSelected || isDemo
            hiddenItemsView.isHidden = isCellSelected || isDemo
        }

        isAccessibilityElement = true
        accessibilityTraits = .button

        if let placeItem = item as? PlacesItem, placeItem.isMapItemPlaceholder {
            setImage(image: UIImage(named: "map-grid-icon"), animated: true)
            nameLabel.text = localized(.placesMapTitle)
            accessibilityLabel = localized(.placesMapTitle)
        } else {
            accessibilityLabel = item.name
        }
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
        imageView.backgroundColor = ColorConstants.fileGreedCellColor
    }
    
    override func setImage(with url: URL) {
        imageView.contentMode = .scaleAspectFill
        imageView.sd_setImage(with: url, placeholderImage: nil, options: [.avoidAutoSetImage]) { [weak self] image, error, cacheType, url in
            guard error == nil else {
                print("SD_WebImage_setImage error: \(error!.description)")
                return
            }
            
            self?.setImage(image: image, animated: true)
        }
        
        isAlreadyConfigured = true
        imageView.backgroundColor = ColorConstants.fileGreedCellColor
    }
    
    class func getCellSise() -> CGSize {
        return CGSize(width: 90.0, height: 90.0)
    }
    
    override func cleanCell() {
        imageView.image = nil
        imageView.sd_cancelCurrentImageLoad()
    }
    
}
