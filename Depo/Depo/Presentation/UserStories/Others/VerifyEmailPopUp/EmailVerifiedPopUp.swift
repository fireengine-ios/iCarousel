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
            newValue.backgroundColor = AppColor.secondaryBackground.color
            newValue.layer.cornerRadius = 15
            newValue.layer.shadowRadius = 15
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowOffset = .zero
            newValue.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFit
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 20)
            newValue.textAlignment = .center
            newValue.textColor = AppColor.label.color
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var continueButton: DarkBlueButton!
    
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
        view.backgroundColor = AppColor.popUpBackground.color
        
        contentView = popUpView
        
        imageView.image = image?.image
        titleLabel.text = message
        continueButton.setTitle(buttonTitle, for: .normal)
    }
    
    //MARK: IBAction
    @IBAction private func onContinueTap() {
        close(completion: buttonAction)
        
        isRecoveryNeedToOpen()
    }
    
    private func isRecoveryNeedToOpen() {
        if SingletonStorage.shared.isJustRegistered == nil || SingletonStorage.shared.isJustRegistered == false {

            SingletonStorage.shared.securityInfoIfNeeded { isNeed in
                if isNeed {
                    RouterVC().securityInfoViewController(fromSettings: false)
                }
            }
        }
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
