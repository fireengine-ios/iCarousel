//
//  SmallFullOfQuotaPopUp.swift
//  PopUp
//
//  Created by Bondar Yaroslav on 12/12/17.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import UIKit

final class SmallFullOfQuotaPopUp: ViewController {

    // MARK: - Static
    
    static func popUp() -> SmallFullOfQuotaPopUp {
        let vc = SmallFullOfQuotaPopUp(nibName: "SmallFullOfQuotaPopUp", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen

        vc.alertTitle = TextConstants.fullQuotaSmallPopUpTitle
        vc.alertMessage = TextConstants.fullQuotaSmallPopUpSubTitle
        vc.checkBoxTitle = TextConstants.fullQuotaSmallPopUpCheckBoxText
        vc.popUpImage = .error
        
        vc.firstButtonTitle = TextConstants.fullQuotaSmallPopUpFistButtonTitle
        vc.secondButtonTitle = TextConstants.fullQuotaSmallPopUpSecondButtonTitle
        
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
    
    @IBOutlet private weak var checkBoxlabel: UILabel! {
        didSet {
            checkBoxlabel.textColor = ColorConstants.lightText
            checkBoxlabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        }
    }
    
    @IBOutlet private weak var firstButton: UIButton!
    @IBOutlet private weak var secondButton: UIButton!
    
    @IBOutlet private weak var darkView: UIView!
    @IBOutlet weak var firstImageView: UIImageView!
    
    @IBOutlet weak var noneImageConstraint: NSLayoutConstraint!
    
    
    // MARK: - Properties
    
    private var popUpImage: PopUpImage = .none
    
    private var alertTitle: String?
    private var alertMessage: String?
    
    private var firstButtonTitle = ""
    private var secondButtonTitle = ""
    private var checkBoxTitle = ""
    
    lazy var firstAction: PopUpButtonHandler = { vc in
        vc.close()
    }
    lazy var secondAction: PopUpButtonHandler = { vc in
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
        checkBoxlabel.text = checkBoxTitle
    }
    
    private func setupButtonState() {
        setup(firstButton)
        setup(secondButton)
        firstButton.setTitle(firstButtonTitle, for: .normal)
        secondButton.setTitle(secondButtonTitle, for: .normal)
        
        firstButton.isHidden = false
        secondButton.isHidden = false
    }
    
    private func setupPopUpImage() {
        firstImageView.image = popUpImage.image
    }
    
    private func setup(_ button: UIButton) {
        button.isExclusiveTouch = true
        button.setTitleColor(ColorConstants.blueColor, for: .normal)
        button.setTitleColor(ColorConstants.blueColor.darker(by: 30), for: .highlighted)
        button.setBackgroundColor(ColorConstants.blueColor, for: .highlighted)
        button.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
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
    
    func close(completion: VoidHandler? = nil) {
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
        close()
    }
    
    @IBAction func actionSecondButton(_ sender: UIButton) {
        close()
    }
    
}
