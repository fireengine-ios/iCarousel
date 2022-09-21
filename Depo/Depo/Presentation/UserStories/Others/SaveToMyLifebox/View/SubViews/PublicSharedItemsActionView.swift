//
//  PublicSharedItemsActionView.swift
//  Lifebox
//
//  Created by Burak Donat on 10.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

protocol PublicSharedItemsActionViewDelegate: AnyObject {
    func downloadButtonDidTapped()
    func saveToMyLifeboxButtonDidTapped()
}

class PublicSharedItemsActionView: UIView, NibInit {
    
    weak var delegate: PublicSharedItemsActionViewDelegate?
 
    @IBOutlet weak private var stackView: UIStackView! {
        willSet {
            newValue.distribution = .fillEqually
            newValue.spacing = 20
        }
    }
    
    @IBOutlet weak var saveToMyLifeboxButton: UIButton! {
        willSet {
            newValue.setTitle(localized(.publicShareSaveTitle), for:.normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.setTitleColor(UIColor.white.darker(by: 30), for: .highlighted)
            newValue.layer.cornerRadius = 24
            newValue.backgroundColor = ColorConstants.navy
            newValue.adjustsFontSizeToFitWidth()
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
        }
    }
    
    @IBOutlet weak var downloadButton: UIButton! {
        willSet {
            newValue.setTitle("   \(localized(.publicShareDownloadTitle))", for:.normal)
            newValue.setImage(Image.iconDownload.image, for: .normal)
            newValue.setTitleColor(ColorConstants.darkBlueColor, for: .normal)
            newValue.setTitleColor(ColorConstants.darkBlueColor.darker(by: 30), for: .highlighted)
            newValue.layer.cornerRadius = 24
            newValue.layer.borderColor = ColorConstants.navy.cgColor
            newValue.layer.borderWidth = 1
            newValue.backgroundColor = UIColor.white
            newValue.adjustsFontSizeToFitWidth()
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
        }
    }
    
    @IBAction func saveToMyLifeboxButtonTapped(_ sender: UIButton) {
        delegate?.saveToMyLifeboxButtonDidTapped()
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIButton) {
        delegate?.downloadButtonDidTapped()
    }
}
