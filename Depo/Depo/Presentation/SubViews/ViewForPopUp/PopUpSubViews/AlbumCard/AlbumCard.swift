//
//  AlbumCard.swift
//  Depo
//
//  Created by Oleg on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SwiftyJSON

final class AlbumCard: BaseCardView {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = .appFont(.medium, size: 16)
            titleLabel.textColor = AppColor.label.color
            titleLabel.text = TextConstants.homeAlbumCardTitle
        }
    }
    
    @IBOutlet private weak var subTitleLabel: UILabel! {
        didSet {
            subTitleLabel.font = .appFont(.regular, size: 12)
            subTitleLabel.textColor = AppColor.label.color
            subTitleLabel.text = TextConstants.homeAlbumCardSubTitle
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.isHidden = true
            descriptionLabel.textColor = ColorConstants.textGrayColor
            descriptionLabel.font = UIFont.TurkcellSaturaDemFont(size: 14)
        }
    }
    
    @IBOutlet private weak var bottomButton: UIButton! {
        didSet {
            bottomButton.titleLabel?.font = .appFont(.medium, size: 14)
            bottomButton.setTitleColor(AppColor.label.color, for: .normal)
            bottomButton.setTitle(TextConstants.homeAlbumCardBottomButtonSaveAlbum, for: .normal)
        }
    }
    
    @IBOutlet private weak var shareButton: UIButton!  {
        didSet {
            shareButton.titleLabel?.font = .appFont(.medium, size: 14)
            shareButton.setTitleColor(AppColor.label.color, for: .normal)
            shareButton.setTitle(TextConstants.tabBarShareLabel, for: .normal)
        }
    }
    
    @IBOutlet private weak var previewImageView: LoadingImageView!

    private var album: AlbumServiceResponse?
    private var albumItem: AlbumItem?
    private var routerVC = RouterVC()
    
    /// MAYBE WILL BE NEED
    ///private var albumPhotos: [WrapData]?
    
    private var cardType = CardActionType.save {
        didSet {
            switch cardType {
            case .save:
                bottomButton.setTitle(TextConstants.homeAlbumCardBottomButtonSaveAlbum, for: .normal)
                shareButton.isHidden = true
            case .display:
                bottomButton.setTitle(TextConstants.homeAlbumCardBottomButtonViewAlbum, for: .normal)
                shareButton.isHidden = false
            }
        }
    }
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        
        if let details = object?.details {
            set(details: details)
        }
        
        if object?.saved == true {
            cardType = .display
        }else {
            cardType = .save
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomSpace : CGFloat = 0.0
        let h = bottomButton.frame.origin.y + bottomButton.frame.size.height + bottomSpace
        if calculatedH != h{
            calculatedH = h
            layoutIfNeeded()
        }
    }
    
    private func set(details object: JSON) {
        album = AlbumServiceResponse(withJSON: object)
        
        if let album = album {
            albumItem = AlbumItem(remote: album)
        }
                
        if let albumItem = albumItem, let albumName = albumItem.name {
            let imageCount = albumItem.imageCount ?? 0
            let videoCount = albumItem.videoCount ?? 0
            setupAlbumDescriptionWith(albumName: albumName, photosCount: imageCount + videoCount)
        }
        
        /// MAYBE WILL BE NEED
        //albumPhotos = photosJson?.map {
        //    let searchItem = SearchItemResponse(withJSON: $0)
        //    return WrapData(remote: searchItem)
        //}
    }
    
    override func viewWillShow() {
        if let album = album {
            albumItem = AlbumItem(remote: album)
        }
        
        if let searchItem = album?.coverPhoto {
            let item = WrapData(remote: searchItem)
            
            debugLog("Album Card - start load image")
            previewImageView.setLogs(enabled: true)
            previewImageView.loadImage(with: item)
        }
    }
    
    override func viewDidEndShow() {
//        previewImageView.image = nil
        previewImageView.cancelLoadRequest()
    }
    
    private func setupAlbumDescriptionWith(albumName: String, photosCount: Int) {
        let countString = "- \(photosCount) " + TextConstants.photos
        let countAttributes = [NSAttributedString.Key.foregroundColor: ColorConstants.darkBorder,
                               NSAttributedString.Key.font: UIFont.TurkcellSaturaRegFont(size: 14)]
        let attributedCount = NSAttributedString(string: countString, attributes: countAttributes)
        
        let fullName = "\"\(albumName)\""
        let nameAttributes = [NSAttributedString.Key.foregroundColor: ColorConstants.textGrayColor,
                              NSAttributedString.Key.font: UIFont.TurkcellSaturaDemFont(size: 14)]
        
        let attributedName = NSMutableAttributedString(string: fullName, attributes: nameAttributes)
        attributedName.append(attributedCount)
        
        descriptionLabel.attributedText = attributedName
    }
    
    @IBAction private func actionCloseButton(_ sender: UIButton) {
        deleteCard()
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWith(type: .albumCard, serverObject: cardObject)
    }
    
    @IBAction private func actionAlbumViewButton(_ sender: UIButton) {
        showAlbum()
    }
    
    @IBAction private func shareButtonTapped(_ sender: UIButton) {
        guard let item = albumItem else {
            assertionFailure()
            return
        }
        delegate?.share(item: item, type: .link)
    }
    
    private func showAlbum() {
        guard let albumItem = albumItem else { return }
        let albumVC = routerVC.albumDetailController(album: albumItem, type: .List, status: .active, moduleOutput: nil)
        routerVC.pushViewController(viewController: albumVC)
    }
    
    @IBAction private func actionBottomButton(_ sender: UIButton) {
        switch cardType {
        case .save:
            saveAlbum()
        case .display:
            showAlbum()
        }
    }
    
    private func saveAlbum() {
        guard let id = cardObject?.id else {
            return
        }
        bottomButton.isEnabled = false
        homeCardsService.save(with: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.bottomButton.isEnabled = true
                
                switch result {
                case .success(_):
                    self?.cardType = .display
                case .failed(let error):
                    if error.isOutOfSpaceError {
                        self?.routerVC.showFullQuotaPopUp()
                    } else {
                        UIApplication.showErrorAlert(message: error.description)
                    }
                }
            }
        }
    }
    
    override func spotlightHeight() -> CGFloat {
        return descriptionLabel.frame.maxY
    }
}
