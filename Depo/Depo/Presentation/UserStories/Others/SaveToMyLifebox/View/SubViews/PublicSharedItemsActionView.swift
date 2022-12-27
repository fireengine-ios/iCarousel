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
    
    @IBOutlet weak var saveToMyLifeboxButton: DarkBlueButton! {
        willSet {
            newValue.setTitle(localized(.publicShareSaveTitle), for:.normal)
        }
    }
    
    @IBOutlet weak var downloadButton: WhiteButton! {
        willSet {
            newValue.setTitle("   \(localized(.publicShareDownloadTitle))", for:.normal)
            newValue.setImage(Image.iconDownload.image.withRenderingMode(.alwaysOriginal), for: .normal)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBAction func saveToMyLifeboxButtonTapped(_ sender: UIButton) {
        delegate?.saveToMyLifeboxButtonDidTapped()
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIButton) {
        delegate?.downloadButtonDidTapped()
    }
}
