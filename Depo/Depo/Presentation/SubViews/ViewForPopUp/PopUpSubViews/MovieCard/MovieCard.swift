//
//  MovieCard.swift
//  Depo
//
//  Created by Oleg on 27.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SwiftyJSON

final class MovieCard: BaseView {
    
    private lazy var imageManager = ImageManager()
    private lazy var filesDataSource = FilesDataSource()
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
            titleLabel.textColor = ColorConstants.darkText
            titleLabel.text = TextConstants.homeMovieCardTitle
        }
    }
    
    @IBOutlet private weak var subTitleLabel: UILabel! {
        didSet {
            subTitleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
            subTitleLabel.textColor = ColorConstants.textGrayColor
            subTitleLabel.text = TextConstants.homeMovieCardSubTitle
        }
    }
    
    @IBOutlet private weak var bottomButton: UIButton! {
        didSet {
            bottomButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
            bottomButton.setTitleColor(ColorConstants.blueColor, for: .normal)
            bottomButton.setTitle(TextConstants.homeMovieCardSaveButton, for: .normal)
        }
    }
    
    @IBOutlet private weak var durationLabel: UILabel! {
        didSet {
            durationLabel.textColor = ColorConstants.whiteColor
            durationLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
        }
    }
    
    @IBOutlet private weak var videoPreviewImageView: LoadingImageView!
    
    private var item: WrapData?
    
    private var cardType = CardActionType.save {
        didSet {
            switch cardType {
            case .save:
                bottomButton.setTitle(TextConstants.homeMovieCardSaveButton, for: .normal)
            case .display:
                bottomButton.setTitle(TextConstants.homeMovieCardViewButton, for: .normal)
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
        let searchItem = SearchItemResponse(withJSON: object)
        let item = WrapData(remote: searchItem)
        durationLabel.text = item.duration
        item.syncStatus = .synced
        item.isLocalItem = false
        self.item = item
        loadImage(from: item)
    }
    
    private func loadImage(from item: WrapData) {
        filesDataSource.getImage(patch: item.patchToPreview) { [weak self] image in
            DispatchQueue.main.async {
                if let image = image {
                    self?.set(image: image)
                } else {
                    UIApplication.showErrorAlert(message: TextConstants.getImageError)
                }
            }
        }
    }
    
    private func set(image: UIImage) {
        cardType = .save
        videoPreviewImageView.image = image
    }
    
    @IBAction private func actionCloseButton(_ sender: UIButton){
        deleteCard()
    }
    
    override func deleteCard() {
        CardsManager.default.stopOperationWithType(type: .movieCard)
        super.deleteCard()
    }
    
    @IBAction private func actionVideoViewButton(_ sender: UIButton) {
        showPhotoVideoDetail(hideActions: true)
    }
    
    @IBAction private func actionBottomButton(_ sender: UIButton) {
        switch cardType {
        case .save:
            saveImage()
        case .display:
            showPhotoVideoDetail(hideActions: false)
        }
    }
    
    private func saveImage() {
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
    
    private func showPhotoVideoDetail(hideActions: Bool) {
        guard let item = item else { return }
        
        let controller = PhotoVideoDetailModuleInitializer.initializeViewController(with: "PhotoVideoDetailViewController", selectedItem: item, allItems: [item], hideActions: hideActions)
        
        controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        RouterVC().pushViewController(viewController: controller)
    }
}
