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
        
        if object?.saved == true {
            cardType = .display
        }else {
            cardType = .save
        }
    }
    
    
    private func set(details object: JSON) {
        let searchItem = SearchItemResponse(withJSON: object)
        let item = WrapData(remote: searchItem)
        durationLabel.text = item.duration
        item.syncStatus = .synced
        item.isLocalItem = false
        self.item = item
        videoPreviewImageView.loadImage(with: item, isOriginalImage: true)
    }
    
    @IBAction private func actionCloseButton(_ sender: UIButton) {
        deleteCard()
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWithType(type: .movieCard, serverObject: cardObject)
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
                    UIApplication.showErrorAlert(message: error.description)
                }
            }
        }
    }
    
    private func showPhotoVideoDetail(hideActions: Bool) {
        debugLog("movie card open video")
        guard let item = item else {
            return
        }
        
        let controller = PhotoVideoDetailModuleInitializer.initializeViewController(with: "PhotoVideoDetailViewController", selectedItem: item, allItems: [item], hideActions: hideActions)
        controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let nController = NavigationController(rootViewController: controller)
        RouterVC().presentViewController(controller: nController)
    }
    
    override func spotlightHeight() -> CGFloat {
        return subTitleLabel.frame.maxY
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
    
}
