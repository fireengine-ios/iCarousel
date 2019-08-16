//
//  EmailVerifiedPopUp.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 8/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class EmailVerifiedPopUp: UIViewController {
    
    private static let buttonHeight: CGFloat = 44
    
    @IBOutlet private var contentView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 4
            newValue.backgroundColor = .white
            
            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowRadius = 4
            newValue.layer.shadowColor = UIColor.black.cgColor
        }
    }
    
    @IBOutlet private var imageView: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFit
        }
    }
    
    @IBOutlet private var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private var continueButton: UIButton! {
        willSet {
            newValue.layer.cornerRadius = EmailVerifiedPopUp.buttonHeight * 0.5
            
            newValue.layer.borderColor = UIColor.lrTealish.cgColor
            newValue.layer.borderWidth = 1
            
            newValue.setBackgroundColor(.white, for: .normal)
            newValue.setBackgroundColor(.white, for: .selected)
            newValue.setTitleColor(UIColor.lrTealish, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
        }
    }
    
    private var image: PopUpImage?
    private var message: String?
    private var buttonTitle: String?
    private var buttonAction: VoidHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        view.backgroundColor = ColorConstants.popUpBackground
        
        imageView.image = image?.image
        titleLabel.text = message
        continueButton.setTitle(buttonTitle, for: .normal)
    }
    
    @IBAction private func onContinueTap() {
        dismiss(animated: true) {
            self.buttonAction?()
        }
    }
}

//MARK: - Init
extension EmailVerifiedPopUp {
    
    static func with(image: PopUpImage, message: String, buttonTitle: String, buttonAction: VoidHandler?) -> EmailVerifiedPopUp {
        let controller = EmailVerifiedPopUp()
        
        controller.image = image
        controller.message = message
        controller.buttonTitle = buttonTitle
        controller.buttonAction  = buttonAction
        
        return controller
    }
    
}
