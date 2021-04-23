//
//  UploadGalleryAssetPickerCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 29.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class UploadGalleryAssetPickerCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
            newValue.backgroundColor = .clear
        }
    }
    
    @IBOutlet private weak var selectionIcon: UIImageView! {
        willSet {
            newValue.image = UIImage(named: "selected-unchecked")
            newValue.contentMode = .scaleAspectFit
            newValue.backgroundColor = .clear
        }
    }
    
    private lazy var selectionLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.withAlphaComponent(0.5).cgColor
        layer.borderColor = ColorConstants.separator.color.cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true
        return layer
    }()
    
    private var thumbnailProvider: FilesDataSource?
    private var assetId: String?
    private var requestId: PHImageRequestID?
    
    
    //MARK: Override
    
    override var isSelected: Bool {
        didSet {
            selectionLayer.isHidden = !isSelected
            selectionIcon.image = isSelected ? UIImage(named: "selected-checked") : UIImage(named: "selected-unchecked")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        addSelectionLayer()
        bringSubview(toFront: selectionIcon)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        selectionLayer.isHidden = true
        imageView.image = nil
        assetId = nil
        requestId = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectionLayer.frame = bounds
    }
    
    //MARK: Public
    func set(thumbnailProvider: FilesDataSource) {
        self.thumbnailProvider = thumbnailProvider
    }
    
    func setup(with asset: PHAsset) {
        
        selectionLayer.isHidden = !isSelected
        selectionIcon.image = isSelected ? UIImage(named: "selected-checked") : UIImage(named: "selected-unchecked")
        
        guard asset.localIdentifier != assetId else {
            return
        }
        
        assetId = asset.localIdentifier
        
        thumbnailProvider?.getAssetThumbnail(asset: asset) { [weak self] requestId in
            self?.requestId = requestId
            
        } completion: { [weak self] image in
            DispatchQueue.main.async {
                guard self?.assetId == asset.localIdentifier else {
                    return
                }
                
                self?.imageView.image = image
            }
        }
    }
    
    func onDidEndDisplaying() {
        guard let requestId = requestId else {
            return
        }
        
        thumbnailProvider?.cancelImageRequest(requestImageID: requestId)
    }
    
    //MARK: Private
    private func addSelectionLayer() {
        selectionLayer.isHidden = true
        layer.addSublayer(selectionLayer)
    }
}
