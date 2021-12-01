//
//  CollectionViewCellForFaceImageAddName.swift
//  Depo
//
//  Created by Harhun Brothers on 07.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class CollectionViewCellForFaceImageAddName: BaseCollectionViewCell {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel.font = UIFont.TurkcellSaturaMedFont(size: 14)
        contentView.backgroundColor = AppColor.primaryBackground.color
    }
    
    override func configureWithWrapper(wrappedObj: BaseDataSourceItem) {
        guard let item = wrappedObj as? Item else {
            return
        }
        
        imageView.image = nil
        
        nameLabel.text = item.name
        
        isAccessibilityElement = true
        accessibilityTraits = .image
        accessibilityLabel = item.name
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
        imageView.sd_setImage(with: url, placeholderImage: nil, options: [.avoidAutoSetImage]) {[weak self] image, error, cacheType, url in
            guard let `self` = self else {
                return
            }
            
            guard error == nil else {
                print("SD_WebImage_setImage error: \(error!.description)")
                return
            }
            
            self.setImage(image: image, animated: true)
        }
        
        isAlreadyConfigured = true
        self.backgroundColor = ColorConstants.fileGreedCellColor
    }
    
    class func getCellSise() -> CGSize {
        return CGSize(width: 90.0, height: 90.0)
    }
    
    override func cleanCell() {
        imageView.image = nil
        imageView.sd_cancelCurrentImageLoad()
    }

}
