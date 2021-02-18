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

enum PopUpVisualStyle {
    case normal
    case lbLogin

    var nibName: String {
        switch self {
        case .normal: return "PopUpController"
        case .lbLogin: return "LoginPopupViewController"
        }
    }
}

//MARK: - PopUpButtonHandler
typealias PopUpButtonHandler = (_: PopUpController) -> Void

final class PopUpController: BasePopUpController {

    //MARK: IBOutlet
    @IBOutlet private weak var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = 10
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowRadius = 10
            containerView.layer.shadowOpacity = 0.5
            containerView.layer.shadowOffset = .zero
        }
    }

    @IBOutlet private weak var buttonsView: UIView! {
        didSet {
            buttonsView.layer.masksToBounds = true
        }
    }

    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = popUpStyle == .normal ? ColorConstants.confirmationPopupTitle : ColorConstants.loginPopupMainTitleColor
            titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 16)
        }
    }

    @IBOutlet private weak var messageLabel: UILabel! {
        didSet {
            messageLabel.textColor = popUpStyle == .normal ? ColorConstants.confirmationPopupMessage : ColorConstants.loginPopupDescriptionColor
            messageLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
        }
    }

    @IBOutlet private weak var firstButton: InsetsButton!
    @IBOutlet private weak var secondButton: InsetsButton!
    @IBOutlet private weak var oneButton: UIButton!

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

    private var popUpStyle: PopUpVisualStyle = .normal

    lazy var firstAction: PopUpButtonHandler = { vc in
        vc.hideSpinnerIncludeNavigationBar()
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

        contentView = containerView

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
            setup(oneButton, filled: true)
            oneButton.setTitle(singleButtonTitle, for: .normal)

            firstButton.isHidden = true
            secondButton.isHidden = true
            oneButton.isHidden = false

        case .twin:
            setup(firstButton, filled: false)
            setup(secondButton, filled: true)
            firstButton.setTitle(firstButtonTitle, for: .normal)
            secondButton.setTitle(secondButtonTitle, for: .normal)

            firstButton.isHidden = false
            secondButton.isHidden = false
            oneButton.isHidden = true
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
    private func setup(_ button: UIButton, filled: Bool) {
        guard popUpStyle == .normal else { return }

        let titleColor = filled ? UIColor.white : ColorConstants.confirmationPopupButtonDark
        let titleColorHigh = filled ? titleColor.lighter(by: 30) : titleColor.darker(by: 30)
        let backgroundColor = filled ? ColorConstants.confirmationPopupButton : UIColor.white
        let borderColor = filled ? ColorConstants.confirmationPopupButton.cgColor : ColorConstants.confirmationPopupButtonDark.cgColor

        button.isExclusiveTouch = true
        button.setTitleColor(titleColor, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(titleColorHigh, for: .highlighted)
        button.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        button.layer.borderColor = borderColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 5
        button.adjustsFontSizeToFitWidth()

        let inset: CGFloat = 2
        (button as? InsetsButton)?.insets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
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
    static func with(errorMessage: String, visualStyle: PopUpVisualStyle = .normal) -> PopUpController {
        return with(title: TextConstants.errorAlert, message: errorMessage, image: .error, buttonTitle: TextConstants.ok, visualStyle: visualStyle)
    }

    static func with(title: String?, message: String?,
                     image: PopUpImage, buttonTitle: String,
                     action: PopUpButtonHandler? = nil, visualStyle: PopUpVisualStyle = .normal) -> PopUpController {

        let vc = controllerWith(title: title, message: message, image: image, visualStyle: visualStyle)
        vc.buttonState = .single

        if let action = action {
            vc.singleAction = action
        }
        vc.singleButtonTitle = buttonTitle

        return vc
    }

    static func with(title: String?, attributedMessage: NSAttributedString?,
                     image: PopUpImage, buttonTitle: String,
                     action: PopUpButtonHandler? = nil, visualStyle: PopUpVisualStyle = .normal) -> PopUpController {

        let vc = controllerWith(title: title, attributedMessage: attributedMessage, image: image, visualStyle: visualStyle)
        vc.buttonState = .single

        if let action = action {
            vc.singleAction = action
        }
        vc.singleButtonTitle = buttonTitle

        return vc
    }

    static func with(title: String?, message: String?,
                     image: PopUpImage, firstButtonTitle: String,
                     secondButtonTitle: String, firstUrl: URL? = nil,
                     secondUrl: URL? = nil, firstAction: PopUpButtonHandler? = nil,
                     secondAction: PopUpButtonHandler? = nil, visualStyle: PopUpVisualStyle = .normal) -> PopUpController {

        let vc = controllerWith(title: title, message: message, image: image, firstUrl: firstUrl, secondUrl: secondUrl, visualStyle: visualStyle)
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

    static func with(title: String?, attributedMessage: NSAttributedString?,
                     image: PopUpImage, firstButtonTitle: String,
                     secondButtonTitle: String, firstUrl: URL? = nil,
                     secondUrl: URL? = nil, firstAction: PopUpButtonHandler? = nil,
                     secondAction: PopUpButtonHandler? = nil, visualStyle: PopUpVisualStyle = .normal) -> PopUpController {

        let vc = controllerWith(title: title, attributedMessage: attributedMessage, image: image, firstUrl: firstUrl, secondUrl: secondUrl, visualStyle: visualStyle)
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

    private static func controllerWith(title: String?, attributedMessage: NSAttributedString?,
                                       image: PopUpImage, firstUrl: URL? = nil,
                                       secondUrl: URL? = nil, visualStyle: PopUpVisualStyle = .normal) -> PopUpController {
        let vc = PopUpController(nibName: visualStyle.nibName, bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen

        vc.alertTitle = title
        vc.attributedAlertMessage = attributedMessage
        vc.popUpImage = image
        vc.firstUrl = firstUrl
        vc.secondUrl = secondUrl

        return vc
    }


    private static func controllerWith(title: String?, message: String?,
                                       image: PopUpImage, firstUrl: URL? = nil,
                                       secondUrl: URL? = nil, visualStyle: PopUpVisualStyle = .normal) -> PopUpController {
        let vc = PopUpController(nibName: visualStyle.nibName, bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen

        vc.alertTitle = title
        vc.alertMessage = message
        vc.popUpImage = image
        vc.firstUrl = firstUrl
        vc.secondUrl = secondUrl
        vc.popUpStyle = visualStyle

        return vc
    }
}
