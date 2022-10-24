//
//  ForYouCardsCollectionViewCell.swift
//  Depo
//
//  Created by Burak Donat on 15.10.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit
import SwiftyJSON

class ForYouCardsCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var bgView: UIView! {
        willSet {
            newValue.addRoundedShadows(cornerRadius: 15, shadowColor: AppColor.drawerShadow.cgColor, opacity: 0.3, radius: 4)
            newValue.backgroundColor = AppColor.secondaryBackground.color
        }
    }
    
    @IBOutlet private weak var cardTitleLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.medium, size: 12)
        }
    }
    
    @IBOutlet private weak var cardDescriptionLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 12)
        }
    }
    
    @IBOutlet private weak var cardThumbnailImage: LoadingImageView!
    
    @IBOutlet private weak var saveButton: UIButton! {
        willSet {
            newValue.setTitleColor(AppColor.label.color, for: .normal)
            newValue.setTitle("Save", for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 12)
        }
    }
    
    @IBOutlet private weak var shareButton: UIButton! {
        willSet {
            newValue.setTitleColor(AppColor.label.color, for: .normal)
            newValue.setTitle("Share", for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 12)
        }
    }
    
    @IBOutlet private weak var thumbnailView: UIView! {
        willSet {
            newValue.layer.borderWidth = 1
            newValue.layer.cornerRadius = 5
            newValue.layer.borderColor = AppColor.tint.cgColor
        }
    }
    
    @IBOutlet private weak var closeButton: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            newValue.setImage(Image.iconCancelBorder.image.withRenderingMode(.alwaysTemplate), for: .normal)
            newValue.tintColor = AppColor.label.color
        }
    }
        
    private var album: AlbumServiceResponse?
    private var albumItem: AlbumItem?
    private var item: WrapData?
    private var currentView: ForYouSections?
    private var cardType = CardActionType.save {
        didSet {
            switch cardType {
            case .save:
                switch currentView {
                case .albumCards:
                    saveButton.setTitle(TextConstants.homeAlbumCardBottomButtonSaveAlbum, for: .normal)
                    shareButton.isHidden = true
                case .collageCards, .animationCards:
                    saveButton.setTitle(TextConstants.homeLikeFilterSavePhotoButton, for: .normal)
                    shareButton.isHidden = true
                default:
                    break
                }
            case .display:
                switch currentView {
                case .albumCards:
                    saveButton.setTitle(TextConstants.homeAlbumCardBottomButtonViewAlbum, for: .normal)
                    shareButton.isHidden = false
                case .collageCards, .animationCards:
                    saveButton.setTitle(TextConstants.homeLikeFilterViewPhoto, for: .normal)
                    shareButton.isHidden = false
                default:
                    break
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction private func onCloseCard(_ sender: UIButton) {
    }
    
    func configure(with data: HomeCardResponse, currentView: ForYouSections) {
        self.currentView = currentView
        set(object: data)
        
        switch currentView {
        case .collageCards:
            cardTitleLabel.text = TextConstants.homeCollageCardTitle
            cardDescriptionLabel.text = TextConstants.homeCollageCardSubTitle
            cardDescriptionLabel.numberOfLines = 2
        case .albumCards:
            cardTitleLabel.text = TextConstants.homeAlbumCardTitle
            cardDescriptionLabel.numberOfLines = 3
            cardThumbnailImage.contentMode = .scaleAspectFill
        case .animationCards:
            cardTitleLabel.text = TextConstants.homeAnimationCardTitle
            cardDescriptionLabel.text = TextConstants.homeAnimationCardSubTitle
            cardDescriptionLabel.numberOfLines = 2
        default:
            break
        }
    }
    
    private func set(object: HomeCardResponse?) {
        if let details = object?.details {
            setDetail(details: details)
        }
        
        if object?.saved == true {
            cardType = .display
        } else {
            cardType = .save
        }
    }
    
    private func setDetail(details object: JSON) {
        if currentView == .albumCards {
            album = AlbumServiceResponse(withJSON: object)
            
            if let album = album {
                albumItem = AlbumItem(remote: album)
            }
            
            if let searchItem = album?.coverPhoto {
                let item = WrapData(remote: searchItem)
                
                debugLog("Album Card - start load image")
                cardThumbnailImage.loadImage(with: item)
            }
                    
            if let albumItem = albumItem, let albumName = albumItem.name {
                let imageCount = albumItem.imageCount ?? 0
                let videoCount = albumItem.videoCount ?? 0
                setupAlbumDescriptionWith(albumName: albumName, photosCount: imageCount + videoCount)
            }
        } else {
            let searchItem = SearchItemResponse(withJSON: object)
            let item = WrapData(remote: searchItem)
            item.syncStatus = .synced
            item.isLocalItem = false
            cardThumbnailImage.loadImage(with: item)
            self.item = item
        }
    }
    
    private func setupAlbumDescriptionWith(albumName: String, photosCount: Int) {
        let countString = "- \(photosCount) " + TextConstants.photos
        let countAttributes = [NSAttributedString.Key.foregroundColor: AppColor.label.color,
                               NSAttributedString.Key.font: UIFont.appFont(.regular, size: 12)]
        let attributedCount = NSAttributedString(string: countString, attributes: countAttributes)
        
        let fullName = "\"\(albumName)\""
        let nameAttributes = [NSAttributedString.Key.foregroundColor: AppColor.label.color,
                              NSAttributedString.Key.font: UIFont.appFont(.regular, size: 12)]
        
        let attributedName = NSMutableAttributedString(string: fullName, attributes: nameAttributes)
        attributedName.append(attributedCount)
        
        cardDescriptionLabel.text = "\(TextConstants.homeAlbumCardSubTitle)\n\(attributedName.string)"
    }
}
