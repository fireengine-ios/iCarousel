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
            bottomButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        }
    }
    
    @IBOutlet private weak var drawingView: ACEDrawingView!
    
    var cardType = CardActionType.save {
        didSet {
            switch cardType {
            case .save:
                bottomButton.setTitle(TextConstants.homeLikeFilterSavePhotoButton, for: .normal)
            case .display:
                bottomButton.setTitle(TextConstants.homeLikeFilterViewPhoto, for: .normal)
            }
        }
    }
    
    /// not working
    func set(image: UIImage) {
        cardType = .save
        
//        let color = UIColor(red: 1, green: 230.0/255.0, blue: 0, alpha: 0.6)
        
//        drawingView.bgImageView.contentMode = .scaleAspectFill
//        drawingView.bgImageView.image = image
        
        drawingView.loadImage(image)
//        drawingView.originalImageUndo(FilterEffect)
//        drawingView.addUndo(forOtherEffects: image, for: FilterEffect, forFrameImage: nil, for: drawingView.transform)
//        drawingView.loadImage(image)
    }
    
    func getFilteredImage() -> UIImage {
        return UIImage()
    }
    
    private func saveToDevice(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saved(image:error:contextInfo:)), nil)
    }
    
    @objc private func saved(image: UIImage, error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            if let error = error {
                UIApplication.showErrorAlert(message: error.localizedDescription)
            } else {
                self.cardType = .display
            }
        }
    }
    
    @IBAction func actionCloseButton(){
        /// will be need to add to the Type enum
        //CardsManager.default.stopOperationWithType(type: .)
    }
    
    @IBAction func actionBottomButton(_ sender: UIButton) {
        switch cardType {
        case .save:
            ///saveToDevice(image: )
            break
        case .display:
            break
        }
    }
}
