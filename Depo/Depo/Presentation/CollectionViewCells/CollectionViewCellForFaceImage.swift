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
        nameLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
    }
    
    override func confireWithWrapperd(wrappedObj: BaseDataSourceItem) {
        guard let item = wrappedObj as? Item else{
            return
        }
        
        visibleImageView.isHidden = true
        transperentView.alpha = 0
        
        if (isAlreadyConfigured){
            return
        }
        
        imageView.image = nil
        
        nameLabel.text = item.name

        if let peopleItem = wrappedObj as? PeopleItem,
            let isVisible = peopleItem.responseObject.visible,
            isVisible == false{
            visibleImageView.isHidden = isVisible
            transperentView.alpha = 0.4
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        self.imageView.sd_cancelCurrentImageLoad()
        self.isAlreadyConfigured = false
    }
    
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
