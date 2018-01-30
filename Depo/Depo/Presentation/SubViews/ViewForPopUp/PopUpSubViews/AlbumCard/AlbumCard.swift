//
//  AlbumCard.swift
//  Depo
//
//  Created by Oleg on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SwiftyJSON

final class AlbumCard: BaseView {

    private lazy var filesDataSource = FilesDataSource()
    private lazy var homeCardsService: HomeCardsService = factory.resolve()
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = ColorConstants.darkText
            titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
            titleLabel.text = TextConstants.homeAlbumCardTitle
        }
    }
    
    @IBOutlet private weak var subTitleLabel: UILabel! {
        didSet {
            subTitleLabel.textColor = ColorConstants.textGrayColor
            subTitleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
            subTitleLabel.text = TextConstants.homeAlbumCardSubTitle
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.textColor = ColorConstants.textGrayColor
            descriptionLabel.font = UIFont.TurkcellSaturaDemFont(size: 14)
        }
    }
    
    @IBOutlet private weak var bottomButton: UIButton! {
        didSet {
            bottomButton.setTitleColor(ColorConstants.blueColor, for: .normal)
            bottomButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
            bottomButton.setTitle(TextConstants.homeAlbumCardBottomButtonSaveAlbum, for: .normal)
        }
    }
    
    @IBOutlet private weak var previewImageView: LoadingImageView!

    private var album: AlbumServiceResponse?
    private var albumItem: AlbumItem?
    
    /// MAYBE WILL BE NEED
    ///private var albumPhotos: [WrapData]?
    
    private var cardType = CardActionType.save {
        didSet {
            switch cardType {
            case .save:
                bottomButton.setTitle(TextConstants.homeAlbumCardBottomButtonSaveAlbum, for: .normal)
            case .display:
                bottomButton.setTitle(TextConstants.homeAlbumCardBottomButtonViewAlbum, for: .normal)
            }
        }
    }
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        
        if let details = object?.details {
            set(details: details)
        }
    }
    
    private func set(details object: JSON) {
        album = AlbumServiceResponse(withJSON: object)
        ///album?.name
        
        if let album = album {
            albumItem = AlbumItem(remote: album)
        }
        
        if let searchItem = album?.coverPhoto {
            let item = WrapData(remote: searchItem)
            previewImageView.loadImageForItem(object: item)
        }
        
        let photosJson = object[AlbumDetailJsonKey.albumDetailFiles].array
        
        if let albumName = albumItem?.name, let photosCount = photosJson?.count {
            setupAlbumDescriptionWith(albumName: albumName, photosCount: photosCount)
        }
        
        /// MAYBE WILL BE NEED
        //albumPhotos = photosJson?.map {
        //    let searchItem = SearchItemResponse(withJSON: $0)
        //    return WrapData(remote: searchItem)
        //}
    }
    
    private func setupAlbumDescriptionWith(albumName: String, photosCount: Int) {
        let countString = "- \(photosCount) " + TextConstants.photos
        let countAttributes = [NSAttributedStringKey.foregroundColor: ColorConstants.darkBorder,
                               NSAttributedStringKey.font: UIFont.TurkcellSaturaRegFont(size: 14)]
        let attributedCount = NSAttributedString(string: countString, attributes: countAttributes)
        
        let fullName = "\"\(albumName)\""
        let nameAttributes = [NSAttributedStringKey.foregroundColor: ColorConstants.textGrayColor,
                              NSAttributedStringKey.font: UIFont.TurkcellSaturaDemFont(size: 14)]
        
        let attributedName = NSMutableAttributedString(string: fullName, attributes: nameAttributes)
        attributedName.append(attributedCount)
        
        descriptionLabel.attributedText = attributedName
    }
    
    @IBAction private func actionCloseButton(_ sender: UIButton){
        deleteCard()
    }
    
    private func deleteCard() {
        guard let id = cardObject?.id else {
            return
        }
        homeCardsService.delete(with: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    CardsManager.default.stopOperationWithType(type: .albumCard)
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction private func actionAlbumViewButton(_ sender: UIButton) {
        showAlbum()
    }
    
    private func showAlbum() {
        guard let albumItem = albumItem else { return }
        let router = RouterVC()
        let albumVC = router.albumDetailController(album: albumItem, type: .Grid, moduleOutput: nil)
        router.pushViewController(viewController: albumVC)
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
                    UIApplication.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
}
