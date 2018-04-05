//
//  FilterPhotoCard.swift
//  Depo
//
//  Created by Bondar Yaroslav on 1/24/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SwiftyJSON

final class FilterPhotoCard: BaseView {
    
    private lazy var imageManager = ImageManager()
    private lazy var filesDataSource = FilesDataSource()
    
    @IBOutlet private weak var headerLabel: UILabel! {
        didSet {
            headerLabel.text = TextConstants.homeLikeFilterHeader
            headerLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
            headerLabel.textColor = ColorConstants.darkText
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = TextConstants.homeLikeFilterTitle
            titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
            titleLabel.textColor = ColorConstants.textGrayColor
        }
    }
    
    @IBOutlet private weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.text = TextConstants.homeLikeFilterSubTitle
            subtitleLabel.font = UIFont.TurkcellSaturaRegFont(size: 12)
            subtitleLabel.textColor = ColorConstants.textGrayColor
        }
    }
    
    @IBOutlet private weak var bottomButton: UIButton! {
        didSet {
            bottomButton.setTitle(TextConstants.homeLikeFilterSavePhotoButton, for: .normal)
            bottomButton.setTitleColor(ColorConstants.blueColor, for: .normal)
            bottomButton.setTitleColor(ColorConstants.blueColor.darker(), for: .highlighted)
            bottomButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        }
    }
    
    @IBOutlet private weak var photoImageView: LoadingImageView!
    
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
        loadImage(from: item)
    }
    
    private func loadImage(from item: WrapData) {
        filesDataSource.getImage(for: item, isOriginal: true) { [weak self] image in
            DispatchQueue.main.async {
                guard let image = image else { return }
                self?.set(image: image)
            }
        }
    }
    
    private func set(image: UIImage) {
        cardType = .save
        photoImageView.image = image.grayScaleImage?.mask(with: ColorConstants.oldieFilterColor)
    }
    
    @IBAction private func actionCloseButton(_ sender: UIButton) {
        deleteCard()
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWithType(type: .stylizedPhoto)
    }
    
    @IBAction private func actionPhotoViewButton(_ sender: UIButton) {
        switch cardType {
        case .save:
            displayNotSavedPhoto()
        case .display:
            getLastImageAssetAndShowImage()
        }
    }
    
    private func displayNotSavedPhoto() {
        guard let image = photoImageView.image else { return }
        let vc = PVViewerController.initFromNib()
        vc.image = image
        let nController = UINavigationController(rootViewController: vc)
        RouterVC().presentViewController(controller: nController)
    }

    
    @IBAction private func actionBottomButton(_ sender: UIButton) {
        guard let image = photoImageView.image else { return }
        
        switch cardType {
        case .save:
            saveToDevice(image: image)
        case .display:
            getLastImageAssetAndShowImage()
        }
    }
    
    private func getLastImageAssetAndShowImage() {
        imageManager.getLastImageAsset { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let asset):
                    self?.showPhotoVideoDetail(with: asset)
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.description)
                }
            }
        }
    }
    
    private func showPhotoVideoDetail(with asset: PHAsset) {
        let item = WrapData(asset: asset)
        
        let controller = PhotoVideoDetailModuleInitializer.initializeViewController(with: "PhotoVideoDetailViewController", selectedItem: item, allItems: [item])
        controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let nController = UINavigationController(rootViewController: controller)
        RouterVC().presentViewController(controller: nController)
    }
    
    private func saveToDevice(image: UIImage) {
        bottomButton.isEnabled = false
        
        imageManager.saveToDevice(image: image) { [weak self] result in
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
}
