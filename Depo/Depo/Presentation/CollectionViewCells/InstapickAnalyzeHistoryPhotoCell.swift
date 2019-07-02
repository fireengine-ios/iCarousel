//
//  InstapickAnalyzeHistoryPhotoCell.swift
//  Depo
//
//  Created by Andrei Novikau on 1/10/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstapickAnalyzeHistoryPhotoCell: BaseCollectionViewCell {
    
    static let underPhotoOffset: CGFloat = 28
    
    @IBOutlet private weak var imageView: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
            newValue.backgroundColor = UIColor.clear
            newValue.layer.masksToBounds = true
            newValue.layer.borderColor = UIColor.lrTealish.cgColor
            newValue.layer.borderWidth = 1
            newValue.alpha = 1
        }
    }
    
    @IBOutlet private weak var selectionImageView: UIImageView!
    
    @IBOutlet private weak var rankView: UIView! {
        willSet {
            newValue.clipsToBounds = true
            newValue.backgroundColor = UIColor.lrTealish
        }
    }
    
    @IBOutlet private weak var rankLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.font = UIFont.TurkcellSaturaBolFont(size: Device.isIpad ? 14 : 12)
        }
    }
    
    @IBOutlet private weak var countLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.lightText
            newValue.font = UIFont.TurkcellSaturaDemFont(size: Device.isIpad ? 16 : 14)
        }
    }
    
    @IBOutlet weak var pictureNotFoundStackView: UIStackView! {
        willSet {
            newValue.spacing = 5
            newValue.axis = .vertical
            newValue.alignment = .center
            
            newValue.isHidden = true
        }
    }
    
    @IBOutlet weak var pictureNotFoundImageView: UIImageView! {
        willSet {
            newValue.image = UIImage(named: "instaPickPicture")
            newValue.contentMode = .scaleAspectFit
        }
    }
    
    @IBOutlet weak var pictureNotFoundLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 10)
            newValue.text = TextConstants.instaPickPictureNotFoundLabel
            newValue.textColor = ColorConstants.darkBlueColor
            newValue.textAlignment = .center
            newValue.numberOfLines = 2
            
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var selectionImageWidth: NSLayoutConstraint!
    @IBOutlet private weak var rankViewWidth: NSLayoutConstraint!

    private var cellImageManager: CellImageManager?
    private var uuid: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .white
        selectionImageWidth.constant = Device.isIpad ? 22 : 15
        rankViewWidth.constant = Device.isIpad ? 26 : 24
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.bounds.height * 0.5
        rankView.layer.cornerRadius = rankView.bounds.height * 0.5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        reset()
        isAlreadyConfigured = false
    }
    
    override func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        selectionImageView.isHidden = !isSelectionActive
        selectionImageView.image = UIImage(named: isSelected ? "selected" : "notSelected")
        imageView.alpha = isSelected && isSelectionActive ? 0.5 : 1
    }
    
    func setup(with item: InstapickAnalyze) {
        rankLabel.text = "\(item.rank)"
        
        let countText = String(format: TextConstants.analyzeHistoryPhotosCount, item.photoCount ?? 0)
        countLabel.text = countText
        
        if let metadata = item.fileInfo?.metadata {
            setImage(with: metadata, identifier: item.requestIdentifier)
        } else {
            ///DispatchQueue.main.async uses to avoid "square" circles
            DispatchQueue.main.async {
                self.pictureNotFoundStackView.isHidden = false
                self.setImage(image: UIImage(named: "instaPickImageNotFound"), animated: false)
            }
        }
    }

    func setImage(with metaData: BaseMetaData, identifier: String) {
        //url is not unique key for analyze items
        let cacheKey = metaData.mediumUrl?.byTrimmingQuery?.appendingPathComponent(identifier)
        cellImageManager = CellImageManager.instance(by: cacheKey)
        uuid = cellImageManager?.uniqueId
        let imageSetBlock: CellImageManagerOperationsFinished = { [weak self] image, cached, shouldBeBlurred, uniqueId in
            guard  let `self` = self else {
                return
            }
            
            DispatchQueue.toMain {
                guard let image = image, let uuid = self.uuid, uuid == uniqueId else {
                    self.pictureNotFoundStackView.isHidden = false
                    self.setImage(image: UIImage(named: "instaPickImageNotFound"), animated: false)
                    return
                }
                
                self.pictureNotFoundStackView.isHidden = true
                let needAnimate = !cached && (self.imageView.image == nil)
                self.setImage(image: image, animated: needAnimate)
            }
        }
        
        cellImageManager?.loadImage(thumbnailUrl: metaData.smalURl, url: metaData.mediumUrl, completionBlock: imageSetBlock)
        
        isAlreadyConfigured = true
    }
    
    override func setImage(image: UIImage?, animated: Bool) {
        if animated {
            imageView.layer.opacity = NumericConstants.numberCellDefaultOpacity
            imageView.image = image
            UIView.animate(withDuration: NumericConstants.setImageAnimationDuration, animations: {
                self.imageView.layer.opacity = NumericConstants.numberCellAnimateOpacity
            })
        } else {
            imageView.image = image
        }

        backgroundColor = ColorConstants.fileGreedCellColor
        
        isAlreadyConfigured = true
    }
    
    private func reset() {
        cellImageManager = nil
        imageView.image = nil
        uuid = nil
    }
    
    deinit {
        cellImageManager?.cancelImageLoading()
    }
}
