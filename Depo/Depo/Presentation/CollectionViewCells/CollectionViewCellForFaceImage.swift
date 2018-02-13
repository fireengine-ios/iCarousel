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
        // Initialization code
        nameLabel.textColor = ColorConstants.whiteColor
        nameLabel.font = UIFont.TurkcellSaturaBolFont(size: 14)
    }
    
    override func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        if (isSelectionActive) {
            visibleImageView.isHidden = !visibleImageView.isHidden
            
            transperentView.alpha = transperentView.alpha > 0 ? 0 : NumericConstants.faceImageCellTransperentAlpha
        }
    }
    
    override func confireWithWrapperd(wrappedObj: BaseDataSourceItem) {
        guard let item = wrappedObj as? Item else{
            return
        }
        
        visibleImageView.isHidden = true
        transperentView.alpha = 0
        
        if (isAlreadyConfigured) {
            return
        }
        
        imageView.image = nil
        
        nameLabel.text = item.name

        if let peopleItem = wrappedObj as? PeopleItem,
            let isVisible = peopleItem.responseObject.visible,
            !isVisible {
            visibleImageView.isHidden = isVisible
            transperentView.alpha = NumericConstants.faceImageCellTransperentAlpha
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        self.imageView.sd_cancelCurrentImageLoad()
        self.isAlreadyConfigured = false
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
        
        backgroundColor = ColorConstants.fileGreedCellColor
        
        isAlreadyConfigured = true
    }
    
    override func setImage(with url: URL) {
        self.imageView.contentMode = .center
        imageView.sd_setImage(with: url, placeholderImage: nil, options: [.avoidAutoSetImage]) {[weak self] (image, error, cacheType, url) in
            guard let `self` = self else {
                return
            }
            
            guard error == nil else {
                print("SD_WebImage_setImage error: \(error!.localizedDescription)")
                return
            }
            
            self.setImage(image: image, animated: true)
        }
        
        isAlreadyConfigured = true
        self.backgroundColor = ColorConstants.fileGreedCellColor
    }
    
    class func getCellSise()->CGSize{
        return CGSize(width: 90.0, height: 90.0)
    }
    
}
