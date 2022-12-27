//
//  ForYouFaceImageTableViewCell.swift
//  Depo
//
//  Created by Burak Donat on 27.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

protocol ForYouFaceImageTableViewCellDelegae: AnyObject {
    func onFaceImageButton()
}

class ForYouFaceImageTableViewCell: UITableViewCell {
    
    weak var delegate: ForYouFaceImageTableViewCellDelegae?

    @IBOutlet private weak var cellView: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.forYouFaceImageBackground.color.withAlphaComponent(0.6)
            newValue.layer.cornerRadius = 16
        }
    }
    
    @IBOutlet private weak var peopleImageView: UIImageView! {
        willSet {
            newValue.image = Image.forYouPeople.image
            newValue.alpha = 0.5
        }
    }
    
    @IBOutlet private weak var peopleScanImageView: UIImageView! {
        willSet {
            newValue.image = Image.popupProfileScan.image
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 12)
            newValue.numberOfLines = 2
            newValue.textAlignment = .center
            newValue.text = TextConstants.faceRecognitionShort
        }
    }
    
    @IBOutlet private weak var faceImageButton: RoundedButton! {
        willSet {
            newValue.backgroundColor = AppColor.forYouButton.color
            newValue.setTitle(TextConstants.faceImageEnable, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    @IBAction func onFaceImageButton(_ sender: RoundedButton) {
        delegate?.onFaceImageButton()
    }
    
}
