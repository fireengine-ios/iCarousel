//
//  CollageCard.swift
//  Depo
//
//  Created by Oleg on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SwiftyJSON

final class CollageCard: BaseView {
    
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
    }
    
    
    private func set(details object: JSON) {
        let searchItem = SearchItemResponse(withJSON: object)
        let item = WrapData(remote: searchItem)
        item.syncStatus = .synced
        item.isLocalItem = false
        self.item = item
        photoImageView.loadImageForItem(object: item)
    }
    
    @IBAction private func actionCloseButton(_ sender: UIButton){
        deleteCard()
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWithType(type: .collage)
    }
    
    @IBAction private func actionPhotoViewButton(_ sender: UIButton) {
        guard let image = photoImageView.image else { return }
        
        let vc = PVViewerController.initFromNib()
        vc.image = image
        RouterVC().pushViewController(viewController: vc)
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
                    UIApplication.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showPhotoVideoDetail() {
        guard let item = item else { return }
        
        let controller = PhotoVideoDetailModuleInitializer.initializeViewController(with: "PhotoVideoDetailViewController", selectedItem: item, allItems: [item])
        
        controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        RouterVC().pushViewController(viewController: controller)
    }
}
