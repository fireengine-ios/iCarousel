//
//  SaveToMyLifeboxActionView.swift
//  Lifebox
//
//  Created by Burak Donat on 10.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

protocol SaveToMyLifeboxActionViewDelegate: AnyObject {
    func downloadButtonDidTapped()
    func saveToMyLifeboxButtonDidTapped()
}

class SaveToMyLifeboxActionView: UIView, NibInit {
    
    weak var delegate: SaveToMyLifeboxActionViewDelegate?
    private var tokenStorage: TokenStorage = factory.resolve()
 
    @IBOutlet weak private var stackView: UIStackView! {
        willSet {
            newValue.distribution = .fillEqually
            newValue.spacing = 20
        }
    }
    
    @IBOutlet weak var saveToMyLifeboxButton: UIButton! {
        willSet {
            newValue.setTitle("Save To My Lifebox",for:.normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.setTitleColor(.white, for: .highlighted)
            newValue.layer.cornerRadius = 24
            newValue.backgroundColor = AppColor.darkBlueAndTealish.color
            newValue.adjustsFontSizeToFitWidth()
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 16)
        }
    }
    
    @IBOutlet weak var downloadButton: UIButton! {
        willSet {
            newValue.setTitle("Download",for:.normal)
            newValue.setTitleColor(ColorConstants.darkBlueColor, for: .normal)
            newValue.setTitleColor(ColorConstants.darkBlueColor, for: .highlighted)
            newValue.layer.cornerRadius = 24
            newValue.layer.borderColor = ColorConstants.navy.cgColor
            newValue.layer.borderWidth = 1
            newValue.backgroundColor = .white
            newValue.adjustsFontSizeToFitWidth()
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 16)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        if tokenStorage.accessToken != nil {
//            downloadButton.removeFromSuperview()
//        }
    }
    
    
    @IBAction func saveToMyLifeboxButtonTapped(_ sender: UIButton) {
        delegate?.saveToMyLifeboxButtonDidTapped()
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIButton) {
        delegate?.downloadButtonDidTapped()
    }
}
