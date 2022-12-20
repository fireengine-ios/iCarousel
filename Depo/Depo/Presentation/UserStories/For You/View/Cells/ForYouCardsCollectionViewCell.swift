//
//  ForYouCardsCollectionViewCell.swift
//  Depo
//
//  Created by Burak Donat on 15.10.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ForYouCardsCollectionViewCellDelegate: AnyObject {
    func displayAlbum(item: AlbumItem)
    func displayAnimation(item: WrapData)
    func displayCollage(item: WrapData)
    func onCloseCard(data: HomeCardResponse, section: ForYouSections)
    func showSavedAnimation(item: WrapData)
    func showSavedCollage(item: WrapData)
    func saveCard(data: HomeCardResponse, section: ForYouSections)
    func share(item: BaseDataSourceItem, type: CardShareType)
}

class ForYouCardsCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: ForYouCardsCollectionViewCellDelegate?

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
    @IBOutlet private weak var leftButton: UIButton! {
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
    private var cardObject: HomeCardResponse?
    private var cardType = CardActionType.save {
        didSet {
            switch cardType {
            case .save:
                switch currentView {
                case .albumCards:
                    leftButton.setTitle(TextConstants.homeAlbumCardBottomButtonSaveAlbum, for: .normal)
                    shareButton.isHidden = true
                case .collageCards, .animationCards:
                    leftButton.setTitle(TextConstants.homeLikeFilterSavePhotoButton, for: .normal)
                    shareButton.isHidden = true
                default:
                    break
                }
            case .display:
                switch currentView {
                case .albumCards:
                    leftButton.setTitle(TextConstants.homeAlbumCardBottomButtonViewAlbum, for: .normal)
                    shareButton.isHidden = false
                case .collageCards, .animationCards:
                    leftButton.setTitle(TextConstants.homeLikeFilterViewPhoto, for: .normal)
                    shareButton.isHidden = false
                default:
                    break
                }
            }
        }
    }

    @IBAction private func onCloseCard(_ sender: UIButton) {
        guard let data = cardObject, let section = currentView else { return }
        delegate?.onCloseCard(data: data, section: section)
    }
    
    @IBAction private func onShowDetail(_ sender: UIButton) {
        guard let currentView = currentView else { return }

        switch currentView {
        case .albumCards:
            displayAlbum()
        case .collageCards:
            displayCollage()
        case .animationCards:
            displayAnimation()
        default:
            return
        }
    }
    
    @IBAction func onLeftButton(_ sender: UIButton) {
        switch cardType {
        case .save:
            switch currentView {
            case .albumCards:
                saveAlbum()
            case .collageCards:
                saveCollage()
            case .animationCards:
                saveAnimation()
            default:
                break
            }
        case .display:
            switch currentView {
            case .albumCards:
                displayAlbum()
            case .collageCards:
                showSavedCollage()
            case .animationCards:
                showSavedAnimation()
            default:
                break
            }
        }
    }
    
    @IBAction func onShareButton(_ sender: UIButton) {
        switch currentView {
        case .albumCards:
            guard let albumItem = albumItem else { return }
            delegate?.share(item: albumItem, type: .link)
        case .collageCards, .animationCards:
            guard let item = item else { return }
            delegate?.share(item: item, type: .origin)
        default:
            return
        }
    }
    
    func configure(with data: HomeCardResponse, currentView: ForYouSections) {
        self.currentView = currentView
        self.cardObject = data
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
        } else if currentView == .animationCards {
            let searchItem = SearchItemResponse(withJSON: object)
            let item = WrapData(remote: searchItem)
            item.syncStatus = .synced
            item.isLocalItem = false
            cardThumbnailImage.loadImageIncludingGif(with: item)
            self.item = item
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
    
    private func displayAlbum() {
        guard let albumItem = albumItem else { return }
        delegate?.displayAlbum(item: albumItem)
    }
    
    private func displayAnimation() {
        guard let item = item else { return }
        delegate?.displayAnimation(item: item)
    }
    
    private func displayCollage() {
        guard let item = item else { return }
        delegate?.displayCollage(item: item)
    }
    
    private func showSavedAnimation() {
        guard let item = item else { return }
        delegate?.showSavedAnimation(item: item)
    }
    
    private func showSavedCollage() {
        guard let item = item else { return }
        delegate?.showSavedCollage(item: item)
    }
    
    private func saveAlbum() {
        saveCard()
        self.cardType = .display
    }
    
    private func saveAnimation() {
        saveCard()
        self.cardType = .display
    }
    
    private func saveCollage() {
        saveCard()
        self.cardType = .display
    }
    
    private func saveCard() {
        guard let data = cardObject, let section = currentView else { return }
        delegate?.saveCard(data: data, section: section)
    }
}
