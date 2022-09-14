//
//  PopUpController.swift
//  PopUp
//
//  Created by Bondar Yaroslav on 12/12/17.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import UIKit

//MARK: - PopUpButtonState
enum PopUpButtonState {
    case single
    case twin
}

//MARK: - PopUpButtonHandler
typealias PopUpButtonHandler = (_: PopUpController) -> Void

final class PopUpController: BasePopUpController {
    
    //MARK: IBOutlet

    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondIconImageView: UIImageView!

    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = .appFont(.medium, size: 20)
        }
    }
    
    @IBOutlet private weak var messageLabel: UILabel! {
        didSet {
            messageLabel.textColor = AppColor.popUpMessage.color
            messageLabel.font = .appFont(.regular, size: 16)
        }
    }
    
    @IBOutlet private weak var firstButton: RoundedInsetsButton!
    @IBOutlet private weak var secondButton: RoundedInsetsButton!

    @IBOutlet weak var noneImageConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    private var buttonState: PopUpButtonState = .twin
    private var popUpImage: PopUpImage = .none
    
    private var alertTitle: String?
    private var alertMessage: String?
    private var attributedAlertMessage: NSAttributedString?
    
    private var firstButtonTitle = ""
    private var secondButtonTitle = ""

    private var firstUrl: URL?
    private var secondUrl: URL?
    
    lazy var firstAction: PopUpButtonHandler = { vc in
        vc.hideSpinnerIncludeNavigationBar()
        vc.dismiss(animated: true)
    }
    lazy var secondAction: PopUpButtonHandler = { vc in
        vc.dismiss(animated: true)
    }
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    //MARK: Utility Methods
    private func setupView() {
        setupButtonState()
        setupPopUpImage()
        setupTitleColor()

        titleLabel.text = alertTitle
        if let attributedMessage = attributedAlertMessage {
            messageLabel.attributedText = attributedMessage
        } else {
            messageLabel.text = alertMessage
        }
    }
    
    private func setupButtonState() {
        switch buttonState {
        case .single:
            setup(firstButton)
            firstButton.setTitle(firstButtonTitle, for: .normal)
            
            firstButton.isHidden = false
            secondButton.isHidden = true

        case .twin:
            setup(firstButton)
            setup(secondButton)
            firstButton.setTitle(firstButtonTitle, for: .normal)
            secondButton.setTitle(secondButtonTitle, for: .normal)
            
            firstButton.isHidden = false
            secondButton.isHidden = false
        }
    }
    
    private func setupPopUpImage() {
        if let url = firstUrl {
            firstImageView.sd_setImage(with: url, placeholderImage: UIImage())
            
        } else {
            firstImageView.image = popUpImage.image
        }
        
        
        if case PopUpImage.none = popUpImage {
            noneImageConstraint.constant = 20
        }
        
        if let url = secondUrl {
            secondIconImageView.sd_setImage(with: url, placeholderImage: UIImage())
            secondIconImageView.isHidden = false
        }
    }

    private func setupTitleColor() {
        switch popUpImage {
        case .error:
            titleLabel.textColor = AppColor.popUpTitleError.color
        default:
            titleLabel.textColor = AppColor.popUpTitle.color
        }
    }
    
    private func setup(_ button: InsetsButton) {
        
        if button == firstButton {
            button.setBackgroundColor(AppColor.popUpButtonNormal.color, for: .normal)
            button.setBackgroundColor(AppColor.tint.color, for: .highlighted)
            button.setTitleColor(.white, for: .normal)
            button.setTitleColor(AppColor.whiteAndLrTealish.color.darker(by: 30.0), for: .highlighted)
        } else {
            button.setBackgroundColor(AppColor.popUpButtonCancel.color, for: .normal)
            button.setBackgroundColor(AppColor.tint.color.darker(by: 30), for: .highlighted)
            button.setTitleColor(.white, for: .normal)
            button.setTitleColor(AppColor.whiteAndLrTealish.color.darker(by: 30.0), for: .highlighted)
        }
        
        button.isExclusiveTouch = true
        button.titleLabel?.font = .appFont(.medium, size: 18)

        button.adjustsFontSizeToFitWidth()
        button.clipsToBounds = true
        
        let inset: CGFloat = 2
        button.insets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        button.layer.cornerRadius = button.frame.height / 2
    }
    
    //MARK: IBAction
    @IBAction func actionFirstButton(_ sender: UIButton) {
        firstAction(self)
    }
    
    @IBAction func actionSecondButton(_ sender: UIButton) {
        secondAction(self)
    }
}

// MARK: - Init
extension PopUpController {
    static func with(errorMessage: String) -> PopUpController {
        return with(title: TextConstants.errorAlert, message: errorMessage, image: .error, buttonTitle: TextConstants.ok)
    }
    
    static func with(title: String?, message: String?, image: PopUpImage, buttonTitle: String, action: PopUpButtonHandler? = nil) -> PopUpController {
        
        let vc = controllerWith(title: title, message: message, image: image)
        vc.buttonState = .single
        
        if let action = action {
            vc.firstAction = action
        }
        vc.firstButtonTitle = buttonTitle
        
        return vc
    }
    
    static func with(title: String?, attributedMessage: NSAttributedString?, image: PopUpImage, buttonTitle: String, action: PopUpButtonHandler? = nil) -> PopUpController {
        
        let vc = controllerWith(title: title, attributedMessage: attributedMessage, image: image)
        vc.buttonState = .single
        
        if let action = action {
            vc.firstAction = action
        }
        vc.firstButtonTitle = buttonTitle

        return vc
    }
    
    static func with(title: String?, message: String?, image: PopUpImage, firstButtonTitle: String, secondButtonTitle: String, firstUrl: URL? = nil, secondUrl: URL? = nil, firstAction: PopUpButtonHandler? = nil, secondAction: PopUpButtonHandler? = nil) -> PopUpController {
        
        let vc = controllerWith(title: title, message: message, image: image, firstUrl: firstUrl, secondUrl: secondUrl)
        vc.buttonState = .twin
        
        if let firstAction = firstAction {
            vc.firstAction = firstAction
        }
        if let secondAction = secondAction {
            vc.secondAction = secondAction
        }
        
        vc.firstButtonTitle = firstButtonTitle
        vc.secondButtonTitle = secondButtonTitle
        
        return vc
    }
    
    static func with(title: String?, attributedMessage: NSAttributedString?, image: PopUpImage, firstButtonTitle: String, secondButtonTitle: String, firstUrl: URL? = nil, secondUrl: URL? = nil, firstAction: PopUpButtonHandler? = nil, secondAction: PopUpButtonHandler? = nil) -> PopUpController {
        
        let vc = controllerWith(title: title, attributedMessage: attributedMessage, image: image, firstUrl: firstUrl, secondUrl: secondUrl)
        vc.buttonState = .twin
        
        if let firstAction = firstAction {
            vc.firstAction = firstAction
        }
        if let secondAction = secondAction {
            vc.secondAction = secondAction
        }
        
        vc.firstButtonTitle = firstButtonTitle
        vc.secondButtonTitle = secondButtonTitle
        
        return vc
    }
    
    private static func controllerWith(title: String?, attributedMessage: NSAttributedString?, image: PopUpImage, firstUrl: URL? = nil, secondUrl: URL? = nil) -> PopUpController {
        let vc = PopUpController(nibName: "PopUpController", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        
        vc.alertTitle = title
        vc.attributedAlertMessage = attributedMessage
        vc.popUpImage = image
        vc.firstUrl = firstUrl
        vc.secondUrl = secondUrl
        
        return vc
    }
    
    
    private static func controllerWith(title: String?, message: String?, image: PopUpImage, firstUrl: URL? = nil, secondUrl: URL? = nil) -> PopUpController {
        let vc = PopUpController(nibName: "PopUpController", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        
        vc.alertTitle = title
        vc.alertMessage = message
        vc.popUpImage = image
        vc.firstUrl = firstUrl
        vc.secondUrl = secondUrl
        
        return vc
    }
}
