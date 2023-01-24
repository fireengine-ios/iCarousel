//
//  MovieCard.swift
//  Depo
//
//  Created by Oleg on 27.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SwiftyJSON

final class MovieCard: BaseCardView {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = .appFont(.medium, size: 16)
            titleLabel.textColor = AppColor.label.color
            titleLabel.text = TextConstants.homeMovieCardTitle
        }
    }
    
    @IBOutlet private weak var subTitleLabel: UILabel! {
        didSet {
            subTitleLabel.font = .appFont(.medium, size: 14)
            subTitleLabel.textColor = AppColor.label.color
            subTitleLabel.text = TextConstants.homeMovieCardSubTitle
        }
    }
    
    @IBOutlet private weak var bottomButton: UIButton! {
        didSet {
            bottomButton.titleLabel?.font = .appFont(.bold, size: 14)
            bottomButton.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
            bottomButton.setTitle(TextConstants.homeMovieCardSaveButton, for: .normal)
        }
    }
    
    @IBOutlet private weak var shareButton: UIButton!  {
        didSet {
            shareButton.titleLabel?.font = .appFont(.bold, size: 14)
            shareButton.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
            shareButton.setTitle(TextConstants.tabBarShareLabel, for: .normal)
        }
    }
    
    @IBOutlet private weak var durationLabel: UILabel! {
        didSet {
            durationLabel.textColor = ColorConstants.whiteColor
            durationLabel.font = .appFont(.medium, size: 14)
        }
    }
    
    @IBOutlet private weak var videoPreviewImageView: LoadingImageView!
    
    private var item: WrapData?
    private let routerVC = RouterVC()
    
    private var cardType = CardActionType.save {
        didSet {
            switch cardType {
            case .save:
                bottomButton.setTitle(TextConstants.homeMovieCardSaveButton, for: .normal)
                shareButton.isHidden = true
            case .display:
                bottomButton.setTitle(TextConstants.homeMovieCardViewButton, for: .normal)
                shareButton.isHidden = false
            }
        }
    }
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    override func configurateView() {
        super.configurateView()
        ItemOperationManager.default.startUpdateView(view: self)
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
    }
    
    override func viewWillShow() {
        debugLog("Movie Card - start load image")
        videoPreviewImageView.setLogs(enabled: true)
        videoPreviewImageView.loadImage(with: item)
    }
    
    @IBAction private func actionCloseButton(_ sender: UIButton) {
        deleteCard()
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWith(type: .movieCard, serverObject: cardObject)
    }
    
    @IBAction private func actionVideoViewButton(_ sender: UIButton) {
        showPhotoVideoDetail()
    }
    
    @IBAction private func shareButtonTapped(_ sender: UIButton) {
        guard let item = item else {
            assertionFailure()
            return
        }
        delegate?.share(item: item, type: .origin)
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
        debugLog("movie card open video")
        guard let item = item else {
            return
        }
        
        let status: ItemStatus
        if item.status.isContained(in: [.hidden, .trashed]) {
            status = item.status
        } else {
            status = .active
        }

        let detailModule = routerVC.filesDetailModule(fileObject: item,
                                                      items: [item],
                                                      status: status,
                                                      canLoadMoreItems: false,
                                                      moduleOutput: nil)

        let nController = NavigationController(rootViewController: detailModule.controller)
        routerVC.presentViewController(controller: nController)
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

extension MovieCard: ItemOperationManagerViewProtocol {
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        return object === self
    }
    
    func didHideItems(_ items: [WrapData]) {
        deleteCardIfNeeded(items: items)
    }
    
    func didMoveToTrashItems(_ items: [Item]) {
        deleteCardIfNeeded(items: items) 
    }
    
    private func deleteCardIfNeeded(items: [WrapData]) {
        guard let uuid = item?.uuid else {
            return
        }
        
        if items.first(where: { $0.uuid == uuid }) != nil {
            CardsManager.default.stopOperationWith(type: .movieCard, serverObject: cardObject)
        }
    }
}
