//
//  SuccessfullHidePopUp.swift
//  Depo
//
//  Created by Konstantin Studilin on 16/12/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit


final class SuccessfullHidePopUp: BasePopUpController {
    
    static func with(action: SelfReturningHandler<SuccessfullHidePopUp>?) -> SuccessfullHidePopUp {
        let vc = customizedController()
        
        if let customAction = action {
            vc.actionHandler = customAction
        }
        
        return vc
    }
    
    private static func customizedController() -> SuccessfullHidePopUp {
        let vc = SuccessfullHidePopUp(nibName: "SuccessfullHidePopUp", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        
        vc.popupImage = PopUpImage.success
        vc.message = TextConstants.hideSuccessPopupMessage
        vc.buttonTitle = TextConstants.hideSuccessPopupButtonTitle
        vc.demoImage = UIImage(named: "smartAlbumsDummy")
        
        return vc
    }
    

    //MARK: IBOutlets
    @IBOutlet private weak var containerView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
            
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowRadius = 10
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet private weak var cornerCloseButton: UIButton!
    @IBOutlet private weak var topIcon: UIImageView!
    
    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.darkBlueColor
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 18)
        }
    }
    
    @IBOutlet private weak var actionButton: UIButton! {
        willSet {
            newValue.setTitleColor(ColorConstants.blueColor, for: .normal)
            newValue.setTitleColor(ColorConstants.blueColor.darker(by: 30), for: .highlighted)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 14)
        }
    }
    
    @IBOutlet private weak var bottomImage: UIImageView!
    
    
    //MARK: Properties
    private lazy var actionHandler: SelfReturningHandler<SuccessfullHidePopUp> = { vc in
        vc.close()
    }
    
    private var popupImage: PopUpImage?
    private var message: String?
    private var buttonTitle: String?
    private var demoImage: UIImage?
    
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    private func setup() {
        contentView = containerView
        
        topIcon.image = popupImage?.image
        messageLabel.text = message
        actionButton.setTitle(buttonTitle, for: .normal)
        bottomImage.image = demoImage
    }
    
    
    //MARK: IBActions
    
    @IBAction private func closePopUp(_ sender: UIButton) {
        close()
    }
    
    @IBAction private func handleAction(_ sender: UIButton) {
        actionHandler(self)
    }
}
