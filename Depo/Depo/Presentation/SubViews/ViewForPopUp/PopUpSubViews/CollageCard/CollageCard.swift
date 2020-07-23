//
//  CollageCard.swift
//  Depo
//
//  Created by Oleg on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SwiftyJSON

final class CollageCard: BaseCardView {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
            titleLabel.textColor = ColorConstants.darkText
            titleLabel.text = TextConstants.homeCollageCardTitle
        }
    }
    
    @IBOutlet private weak var subTitleLabel: UILabel! {
        didSet {
            subTitleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
            subTitleLabel.textColor = ColorConstants.textGrayColor
            subTitleLabel.text = TextConstants.homeCollageCardSubTitle
        }
    }
    
    @IBOutlet private weak var bottomButton: UIButton! {
        didSet {
            bottomButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
            bottomButton.setTitleColor(ColorConstants.blueColor, for: .normal)
            bottomButton.setTitle(TextConstants.homeCollageCardButtonSaveCollage, for: .normal)
        }
    }
    
    @IBOutlet private weak var photoImageView: LoadingImageView!
    
    private var item: WrapData?
    private let routerVC = RouterVC()
    
    private var cardType = CardActionType.save {
        didSet {
            switch cardType {
            case .save:
                bottomButton.setTitle(TextConstants.homeLikeFilterSavePhotoButton, for: .normal)
            case .display:
                bottomButton.setTitle(TextConstants.homeLikeFilterViewPhoto, for: .normal)
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
        let searchItem = SearchItemResponse(withJSON: object)
        let item = WrapData(remote: searchItem)
        item.syncStatus = .synced
        item.isLocalItem = false
        self.item = item
        
    }
    
    override func viewWillShow() {
        debugLog("Collage Card - start load image")
        photoImageView.setLogs(enabled: true)
        photoImageView.loadImage(with: item)
    }
    
    override func viewDidEndShow() {
//        photoImageView.image = nil
        photoImageView.cancelLoadRequest()
    }
    
    @IBAction private func actionCloseButton(_ sender: UIButton) {
        deleteCard()
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWith(type: .collage, serverObject: cardObject)
    }
    
    @IBAction private func actionPhotoViewButton(_ sender: UIButton) {
        showPreview()
    }
    
    @IBAction private func actionBottomButton(_ sender: UIButton) {
        switch cardType {
        case .save:
            saveImage()
        case .display:
            showPhotoVideoDetail()
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
                    if error.isOutOfSpaceError {
                        self?.routerVC.showFullQuotaPopUp()
                    } else {
                        UIApplication.showErrorAlert(message: error.description)
                    }
                }
            }
        }
    }
    
    private func showPhotoVideoDetail() {
        
        guard let item = item else {
            return
        }
        
        homeCardsService.updateItem(uuid: item.uuid) { [weak self] responseResult in
            switch responseResult {
            case .success(let updatedItem):
                self?.item = updatedItem
                let detailModule = self?.routerVC.filesDetailModule(fileObject: item,
                                                              items: [item],
                                                              status: .active,
                                                              canLoadMoreItems: false,
                                                              moduleOutput: nil)
                
                guard let controller = detailModule?.controller else {
                    assertionFailure()
                    return
                }
                
                let nController = NavigationController(rootViewController: controller)
                self?.routerVC.presentViewController(controller: nController)
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
    
    private func showPreview() {
        guard let item = item else {
            return
        }
        
        let controller = PVViewerController.with(item: item)
        let navController = NavigationController(rootViewController: controller)
        routerVC.presentViewController(controller: navController)
    }
    
    override func spotlightHeight() -> CGFloat {
        return subTitleLabel.frame.maxY
    }
}
