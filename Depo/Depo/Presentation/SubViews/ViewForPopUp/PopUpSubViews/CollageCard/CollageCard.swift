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
            titleLabel.font = .appFont(.medium, size: 16)
            titleLabel.textColor = AppColor.label.color
            titleLabel.text = TextConstants.homeCollageCardTitle
        }
    }
    
    @IBOutlet private weak var subTitleLabel: UILabel! {
        didSet {
            subTitleLabel.font = .appFont(.regular, size: 12)
            subTitleLabel.textColor = AppColor.label.color
            subTitleLabel.text = TextConstants.homeCollageCardSubTitle
        }
    }
    
    @IBOutlet private weak var shareButton: UIButton! {
        didSet {
            shareButton.titleLabel?.font = .appFont(.medium, size: 14)
            shareButton.setTitleColor(AppColor.label.color, for: .normal)
            shareButton.setTitle(TextConstants.tabBarShareLabel, for: .normal)
        }
    }
    
    @IBOutlet private weak var bottomButton: UIButton! {
        didSet {
            bottomButton.titleLabel?.font = .appFont(.medium, size: 14)
            bottomButton.setTitleColor(AppColor.label.color, for: .normal)
            bottomButton.setTitle(TextConstants.homeCollageCardButtonSaveCollage, for: .normal)
        }
    }
    
    @IBOutlet private weak var photoImageView: LoadingImageView!
    @IBOutlet private weak var photoButton: UIButton!

    private var item: WrapData?
    private let routerVC = RouterVC()
    
    private var cardType = CardActionType.save {
        didSet {
            switch cardType {
            case .save:
                bottomButton.setTitle(TextConstants.homeLikeFilterSavePhotoButton, for: .normal)
                shareButton.isHidden = true
            case .display:
                bottomButton.setTitle(TextConstants.homeLikeFilterViewPhoto, for: .normal)
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
        photoButton.accessibilityLabel = item?.name
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
    
    @IBAction private func shareButtonTapped(_ sender: UIButton) {
        guard let item = item else {
            assertionFailure()
            return
        }
        delegate?.share(item: item, type: .origin)
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
                    self?.refreshCardInfo { [weak self] refreshed in
                        if refreshed {
                            self?.cardType = .display
                        }
                    }
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

    private func refreshCardInfo(completion: @escaping BoolHandler) {
        homeCardsService.all { [weak self] result in
            switch result {
            case .success(let cards):
                let card = cards.first { $0.type == self?.cardObject?.type }
                if let card = card {
                    self?.set(object: card)
                    completion(true)
                }
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
                completion(false)
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
