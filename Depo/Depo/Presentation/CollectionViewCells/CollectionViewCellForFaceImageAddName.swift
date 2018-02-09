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
        contentView.backgroundColor = .white
    }
    
    override func setSelection(isSelectionActive: Bool, isSelected: Bool) {
    }
    
    override func confireWithWrapperd(wrappedObj: BaseDataSourceItem) {
        guard let item = wrappedObj as? Item else{
            return
        }
        
        imageView.image = nil
        
        nameLabel.text = item.name
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        self.imageView.sd_cancelCurrentImageLoad()
        self.isAlreadyConfigured = false
    }
    
    override func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) { }
    
    override func setImage(image: UIImage?) {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.opacity = 0.1
        imageView.image = image
        UIView.animate(withDuration: 0.2, animations: {
            self.imageView.layer.opacity = 1.0
        })
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
            
            self.setImage(image: image)
        }
        
        isAlreadyConfigured = true
        self.backgroundColor = ColorConstants.fileGreedCellColor
    }
    
    class func getCellSise()->CGSize{
        return CGSize(width: 90.0, height: 90.0)
    }

}
