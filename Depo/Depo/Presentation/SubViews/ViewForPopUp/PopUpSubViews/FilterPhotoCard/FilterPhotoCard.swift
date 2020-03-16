//
//  FilterPhotoCard.swift
//  Depo
//
//  Created by Bondar Yaroslav on 1/24/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SwiftyJSON

final class FilterPhotoCard: BaseCardView {
    
    private lazy var imageManager = ImageManager()
    private lazy var filesDataSource = FilesDataSource()
    private var originalItem: WrapData?
    
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
            DispatchQueue.toMain {
                switch self.cardType {
                case .save:
                    self.bottomButton.setTitle(TextConstants.homeLikeFilterSavePhotoButton, for: .normal)
                case .display:
                    self.bottomButton.setTitle(TextConstants.homeLikeFilterViewPhoto, for: .normal)
                }
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
        originalItem = item
        /// check DB here
        
    }
    
    override func viewWillShow() {
        guard let originalItem = originalItem else {
            return
        }
        bottomButton.isHidden = true
        DispatchQueue.toBackground {
            MediaItemOperationsService.shared.getLocalFilteredItem(remoteOriginalItem: originalItem) { [weak self] localSavedItem in
                guard let `self` = self else {
                    return
                }
                if let savedItem = localSavedItem {
                    self.loadImage(from: savedItem, isSaved: true)
                } else {
                    self.loadImage(from: originalItem, isSaved: false)
                }
            }
        }
    }
    
    override func viewDidEndShow() {
//        photoImageView.image = nil
        photoImageView.cancelLoadRequest()
    }

    
    private func loadImage(from item: WrapData, isSaved: Bool) {
        filesDataSource.getImage(for: item, isOriginal: true) { [weak self] image in
            DispatchQueue.main.async {
                guard let image = image else { return }
                self?.set(image: image, isSaved: isSaved)
            }
        }
    }
    
    private func set(image: UIImage, isSaved: Bool) {
        photoImageView.image = image
        if isSaved {
            cardType = .display
            bottomButton.isHidden = false
            return
        }
        
        photoImageView.startAnimating()
        
        MaskService.shared.generateImageWithMask(image: image) { [weak self] (image) in
            DispatchQueue.toMain {
                self?.bottomButton.isHidden = false
                self?.cardType = .save
                self?.photoImageView.stopAnimating()
                self?.photoImageView.image = image
            }
        }
    }
    
    @IBAction private func actionCloseButton(_ sender: UIButton) {
        deleteCard()
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWith(type: .stylizedPhoto, serverObject: cardObject)
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
        let nController = NavigationController(rootViewController: vc)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomSpace : CGFloat = 0.0
        let h = bottomButton.frame.origin.y + bottomButton.frame.size.height + bottomSpace
        if calculatedH != h{
            calculatedH = h
            layoutIfNeeded()
        }
    }
    
    private func getLastImageAssetAndShowImage() {
        imageManager.getLastImageAsset { [weak self] result in
            switch result {
            case .success(let asset):
                self?.showPhotoVideoDetail(with: asset)
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
    
    private func showPhotoVideoDetail(with asset: PHAsset) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return
        }
        DispatchQueue.global().async {
            let item = WrapData(asset: asset)
            
            let router = RouterVC()
            let detailModule = router.filesDetailModule(fileObject: item,
                                                        items: [item],
                                                        status: .active,
                                                        canLoadMoreItems: false,
                                                        moduleOutput: nil)

            let nController = NavigationController(rootViewController: detailModule.controller)
            
            DispatchQueue.main.async {
                router.presentViewController(controller: nController)
            }
        }
    }
    
    private func saveToDevice(image: UIImage) {
        guard let originalItemUnwraped = originalItem else {
            return
        }
        
//        bottomButton.isEnabled = false
        LocalMediaStorage.default.saveFilteredImage(filteredImage: image, originalImage: originalItemUnwraped, success: { [weak self] in
            self?.cardType = .display
        }, fail: { _ in
            ///PH access popup
            LocalMediaStorage.default.askPermissionForPhotoFramework(redirectToSettings: true, completion: { granted,_  in
                debugPrint("granted \(granted)")
                ///For now nothing
            })
        })
        
    }
    
    override func spotlightHeight() -> CGFloat {
        return titleLabel.frame.maxY
    }
}
