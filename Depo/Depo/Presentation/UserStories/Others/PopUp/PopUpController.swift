//
//  PopUpController.swift
//  PopUp
//
//  Created by Bondar Yaroslav on 12/12/17.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import UIKit

typealias PopUpButtonHandler = (_: PopUpController) -> Void

enum PopUpButtonState {
    case single
    case twin
}

final class PopUpController: UIViewController {

    // MARK: - Static
    
    static func with(title: String?, message: String?, image: PopUpImage, buttonTitle: String, action: PopUpButtonHandler? = nil) -> PopUpController {

        let vc = controllerWith(title: title, message: message, image: image)
        vc.buttonState = .single
        
        if let action = action {
            vc.singleAction = action
        }
        vc.singleButtonTitle = buttonTitle

        return vc
    }
    
    static func with(title: String?, message: String?, image: PopUpImage, firstButtonTitle: String, secondButtonTitle: String, firstAction: PopUpButtonHandler? = nil, secondAction: PopUpButtonHandler? = nil) -> PopUpController {
        
        let vc = controllerWith(title: title, message: message, image: image)
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
    
    private static func controllerWith(title: String?, message: String?, image: PopUpImage) -> PopUpController {
        let vc = PopUpController(nibName: "PopUpController", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen

        vc.alertTitle = title
        vc.alertMessage = message
        vc.popUpImage = image

        return vc
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var shadowView: UIView! {
        didSet {
            shadowView.layer.cornerRadius = 5
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowRadius = 10
            shadowView.layer.shadowOpacity = 0.5
            shadowView.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet private weak var containerView: UIView! {
        didSet {
            containerView.layer.masksToBounds = true
            containerView.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = ColorConstants.darcBlueColor
            titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 20)
        }
    }
    
    @IBOutlet private weak var messageLabel: UILabel! {
        didSet {
            messageLabel.textColor = ColorConstants.lightText
            messageLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        }
    }
    
    @IBOutlet private weak var firstButton: UIButton!
    @IBOutlet private weak var secondButton: UIButton!
    @IBOutlet private weak var singleButton: UIButton!
    
    @IBOutlet private weak var darkView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var noneImageConstraint: NSLayoutConstraint!
    
    
    // MARK: - Properties
    
    private var buttonState: PopUpButtonState = .twin
    private var popUpImage: PopUpImage = .none
    
    private var alertTitle: String?
    private var alertMessage: String?
    
    private var firstButtonTitle = ""
    private var secondButtonTitle = ""
    private var singleButtonTitle = ""
    
    lazy var firstAction: PopUpButtonHandler = { vc in
        vc.close()
    }
    lazy var secondAction: PopUpButtonHandler = { vc in
        vc.close()
    }
    lazy var singleAction: PopUpButtonHandler = { vc in
        vc.close()
    }
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        setupButtonState()
        setupPopUpImage()
        
        titleLabel.text = alertTitle
        messageLabel.text = alertMessage
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
        iconImageView.image = popUpImage.image
        if case PopUpImage.none = popUpImage {
            noneImageConstraint.constant = 20
        }
    }
    
    private func setup(_ button: UIButton) {
        button.isExclusiveTouch = true
        button.setTitleColor(ColorConstants.blueColor, for: .normal)
        button.setTitleColor(ColorConstants.blueColor.darker(by: 30), for: .highlighted)
        button.setBackgroundColor(ColorConstants.blueColor.darker(by: 10), for: .highlighted)
        button.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
        button.layer.borderColor = ColorConstants.blueColor.cgColor
        button.layer.borderWidth = 1
    }
    
    // MARK: - Animation
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        open()
    }
    
    private var isShown = false
    private func open() {
        if isShown {
            return
        }
        isShown = true
        shadowView.transform = NumericConstants.scaleTransform
        containerView.transform = NumericConstants.scaleTransform
        view.alpha = 0
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.view.alpha = 1
            self.shadowView.transform = .identity
            self.containerView.transform = .identity
        }
    }
    
    func close(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
            self.shadowView.transform = NumericConstants.scaleTransform
            self.containerView.transform = NumericConstants.scaleTransform
        }) { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    // MARK: - IBAction
    
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
