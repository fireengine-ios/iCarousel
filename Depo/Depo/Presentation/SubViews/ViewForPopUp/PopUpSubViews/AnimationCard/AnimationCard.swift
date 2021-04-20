//
//  AnimationCard.swift
//  Depo
//
//  Created by Oleg on 04.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SwiftyJSON

class AnimationCard: BaseCardView {

    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
            titleLabel.textColor = ColorConstants.darkText
            titleLabel.text = TextConstants.homeAnimationCardTitle
        }
    }
    
    @IBOutlet private weak var subTitleLabel: UILabel! {
        didSet {
            subTitleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
            subTitleLabel.textColor = ColorConstants.textGrayColor
            subTitleLabel.text = TextConstants.homeAnimationCardSubTitle
        }
    }
    
    @IBOutlet private weak var bottomButton: UIButton! {
        didSet {
            bottomButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
            bottomButton.setTitleColor(ColorConstants.blueColor, for: .normal)
            bottomButton.setTitle(TextConstants.homeAnimationCardButtonSaveCollage, for: .normal)
        }
    }
    
    @IBOutlet private weak var shareButton: UIButton!  {
        didSet {
            shareButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
            shareButton.setTitleColor(ColorConstants.blueColor, for: .normal)
            shareButton.setTitle(TextConstants.tabBarShareLabel, for: .normal)
        }
    }
    
    @IBOutlet private weak var photoImageView: LoadingImageView!
    
    private var item: WrapData?
    
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
    
    
    private func set(details object: JSON) {
        let searchItem = SearchItemResponse(withJSON: object)
        let item = WrapData(remote: searchItem)
        item.syncStatus = .synced
        item.isLocalItem = false
        self.item = item
    }
    
    override func viewWillShow() {
        debugLog("Animation Card - start load image")
        photoImageView.setLogs(enabled: true)
        photoImageView.loadImageData(with: item?.tmpDownloadUrl)
    }
    
    @IBAction private func actionCloseButton(_ sender: UIButton) {
        deleteCard()
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWith(type: .collage, serverObject: cardObject)
    }
    
    @IBAction private func actionPhotoViewButton(_ sender: UIButton) {
        guard let item = item else {
            return
        }
        
        let vc = PVViewerController.with(item: item)
        let nController = UINavigationController(rootViewController: vc)
        RouterVC().presentViewController(controller: nController)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomSpace : CGFloat = 0.0
        let h = bottomButton.frame.origin.y + bottomButton.frame.size.height + bottomSpace
        if calculatedH != h{
            calculatedH = h
            layoutIfNeeded()
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
                        RouterVC().showFullQuotaPopUp()
                    } else {
                        UIApplication.showErrorAlert(message: error.description)
                    }
                }
            }
        }
    }
    
    private func showPhotoVideoDetail() {
        guard let item = item else { return }
        
        let router = RouterVC()
        let detailModule = router.filesDetailModule(fileObject: item,
                                                    items: [item],
                                                    status: .active,
                                                    canLoadMoreItems: false,
                                                    moduleOutput: nil)

        let nController = NavigationController(rootViewController: detailModule.controller)
        router.presentViewController(controller: nController)
    }

    override func spotlightHeight() -> CGFloat {
        return subTitleLabel.frame.maxY
    }
}
