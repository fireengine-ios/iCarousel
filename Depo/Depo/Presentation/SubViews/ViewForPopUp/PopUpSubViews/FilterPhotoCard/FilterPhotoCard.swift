//
//  FilterPhotoCard.swift
//  Depo
//
//  Created by Bondar Yaroslav on 1/24/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

enum CardActionType {
    case save
    case display
}

final class FilterPhotoCard: BaseView {
    
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
            bottomButton.isExclusiveTouch = true
            bottomButton.setTitleColor(ColorConstants.blueColor, for: .normal)
            bottomButton.setTitleColor(ColorConstants.blueColor.darker(), for: .highlighted)
            bottomButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        }
    }
    
    @IBOutlet private weak var photoImageView: UIImageView! {
        didSet {
//            set(image: #imageLiteral(resourceName: "dogFilterImage"))
            set(image: #imageLiteral(resourceName: "Background"))
        }
    }
    
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
    
    private func set(image: UIImage) {
        cardType = .display
//        cardType = .save
        let oldieFilterColor = UIColor(red: 1, green: 230.0/255.0, blue: 0, alpha: 0.4)
        photoImageView.image = image.grayScaleImage?.mask(with: oldieFilterColor)
    }
    
    private func saveToDevice(image: UIImage) {
        bottomButton.isEnabled = false
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saved(image:error:contextInfo:)), nil)
    }
    
    @objc private func saved(image: UIImage, error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            self.bottomButton.isEnabled = true
            if let error = error {
                UIApplication.showErrorAlert(message: error.localizedDescription)
            } else {
                self.cardType = .display
            }
        }
    }
    
    @IBAction private func actionCloseButton(){
        /// will be need to add to the Type enum
        //CardsManager.default.stopOperationWithType(type: .)
    }
    
    @IBAction private func actionBottomButton(_ sender: UIButton) {
        guard let image = photoImageView.image else {
            return
        }
        
        switch cardType {
        case .save:
            saveToDevice(image: image)
        case .display:
            let vc = PVViewerController.initFromNib()
            vc.image = image
            RouterVC().pushViewController(viewController: vc)
//            let controller = PhotoVideoDetailModuleInitializer.initializeViewController(with: <#T##String#>, selectedItem: <#T##Item#>, allItems: <#T##[Item]#>, hideActionButtons: <#T##Bool#>)
//
//            let controller = PhotoVideoDetailModuleInitializer.initializeViewController(with: "PhotoVideoDetailViewController",
//                                                                                        selectedItem: fileObject,
//                                                                                        allItems: items)
//            let c = controller as! PhotoVideoDetailViewController
            break
        }
    }
}
