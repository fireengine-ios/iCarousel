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
    @IBOutlet private weak var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = 5
            
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowRadius = 10
            containerView.layer.shadowOpacity = 0.5
            containerView.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet private weak var buttonsView: UIView! {
        didSet {
            buttonsView.layer.cornerRadius = 5
            buttonsView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = ColorConstants.darkBlueColor
            titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 20)
        }
    }
    
    @IBOutlet private weak var messageLabel: UILabel! {
        didSet {
            messageLabel.textColor = ColorConstants.lightText
            messageLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        }
    }
    
    @IBOutlet private weak var firstButton: InsetsButton!
    @IBOutlet private weak var secondButton: InsetsButton!
    @IBOutlet private weak var singleButton: InsetsButton!
    
    @IBOutlet private weak var darkView: UIView!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondIconImageView: UIImageView!
    
    @IBOutlet weak var noneImageConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    private var buttonState: PopUpButtonState = .twin
    private var popUpImage: PopUpImage = .none
    
    private var alertTitle: String?
    private var alertMessage: String?
    private var attributedAlertMessage: NSAttributedString?
    
    private var firstButtonTitle = ""
    private var secondButtonTitle = ""
    private var singleButtonTitle = ""
    
    private var firstUrl: URL?
    private var secondUrl: URL?
    
    lazy var firstAction: PopUpButtonHandler = { vc in
        vc.close()
    }
    lazy var secondAction: PopUpButtonHandler = { vc in
        vc.close()
    }
    lazy var singleAction: PopUpButtonHandler = { vc in
        vc.close()
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
            setup(singleButton)
            singleButton.setTitle(singleButtonTitle, for: .normal)
            
            firstButton.isHidden = true
            secondButton.isHidden = true
            singleButton.isHidden = false
            
        case .twin:
            setup(firstButton)
            setup(secondButton)
            firstButton.setTitle(firstButtonTitle, for: .normal)
            secondButton.setTitle(secondButtonTitle, for: .normal)
            
            firstButton.isHidden = false
            secondButton.isHidden = false
            singleButton.isHidden = true
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
    
    private func setup(_ button: InsetsButton) {
        button.isExclusiveTouch = true
        button.setTitleColor(ColorConstants.blueColor, for: .normal)
        button.setTitleColor(ColorConstants.blueColor.darker(by: 30), for: .highlighted)
        button.setBackgroundColor(ColorConstants.blueColor, for: .highlighted)
        button.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
        button.layer.borderColor = ColorConstants.blueColor.cgColor
        button.layer.borderWidth = 1
        button.adjustsFontSizeToFitWidth()
        
        let inset: CGFloat = 2
        button.insets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    //MARK: IBAction
    @IBAction func actionFirstButton(_ sender: UIButton) {
        firstAction(self)
    }
    
    @IBAction func actionSecondButton(_ sender: UIButton) {
        secondAction(self)
    }
    
    @IBAction func actionSingleButton(_ sender: UIButton) {
        singleAction(self)
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
            vc.singleAction = action
        }
        vc.singleButtonTitle = buttonTitle
        
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
