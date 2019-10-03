//
//  EmailVerifiedPopUp.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 8/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class EmailVerifiedPopUp: BasePopUpController {
    
    //MARK: IBOutlet
    @IBOutlet private weak var popUpView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 4
            newValue.backgroundColor = .white
            
            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowRadius = 4
            newValue.layer.shadowColor = UIColor.black.cgColor
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFit
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var continueButton: RoundedButton! {
        willSet {
            newValue.layer.borderColor = UIColor.lrTealish.cgColor
            newValue.layer.borderWidth = 1
            
            newValue.setBackgroundColor(.white, for: .normal)
            newValue.setBackgroundColor(.white, for: .selected)
            newValue.setTitleColor(UIColor.lrTealish, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
        }
    }
    
    //MARK: Properties
    private var image: PopUpImage?
    private var message: String?
    private var buttonTitle: String?
    private var buttonAction: VoidHandler?
    
    private var isShown = false

    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    //MARK: Utility Method
    private func setup() {
        view.backgroundColor = ColorConstants.popUpBackground
        
        contentView = popUpView
        
        imageView.image = image?.image
        titleLabel.text = message
        continueButton.setTitle(buttonTitle, for: .normal)
    }
    
    //MARK: IBAction
    @IBAction private func onContinueTap() {
        close(completion: buttonAction)
    }
}

//MARK: - Init
extension EmailVerifiedPopUp {
    
    static func with(image: PopUpImage, message: String, buttonTitle: String, buttonAction: VoidHandler? = nil) -> EmailVerifiedPopUp {
        let controller = EmailVerifiedPopUp()
        
        controller.image = image
        controller.message = message
        controller.buttonTitle = buttonTitle
        controller.buttonAction  = buttonAction
        
        return controller
    }
    
}
