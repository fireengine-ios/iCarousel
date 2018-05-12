//
//  LargeFullOfQuotaPopUp.swift
//  Depo
//
//  Created by Oleg on 11.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

enum LargeFullOfQuotaPopUpType{
    case LargeFullOfQuotaPopUpType80
    case LargeFullOfQuotaPopUpType90
    case LargeFullOfQuotaPopUpType100
}

class LargeFullOfQuotaPopUp: UIViewController {
    
    static func popUp(type: LargeFullOfQuotaPopUpType) -> LargeFullOfQuotaPopUp {
        let controller = LargeFullOfQuotaPopUp(nibName: "LargeFullOfQuotaPopUp", bundle: nil)
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        controller.viewType = type
        return controller
    }
    
    var viewType: LargeFullOfQuotaPopUpType = .LargeFullOfQuotaPopUpType100
    
    private static func textForTitle(type: LargeFullOfQuotaPopUpType) -> String {
        switch type {
        case .LargeFullOfQuotaPopUpType80:
            return TextConstants.lifeboxLargePopUpTitle80
        case .LargeFullOfQuotaPopUpType90:
            return TextConstants.lifeboxLargePopUpTitle90
        case .LargeFullOfQuotaPopUpType100:
            return TextConstants.lifeboxLargePopUpTitle100
        }
    }
    
    @IBOutlet private weak var shadowView: UIView! {
        didSet {
            shadowView.layer.cornerRadius = 5
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowRadius = 10
            shadowView.layer.shadowOpacity = 0.5
            shadowView.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet private weak var bacgroundViewForImage: UIView!
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = ColorConstants.whiteColor
            titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 28)
        }
    }
    
    @IBOutlet private weak var subTitleLabel: UILabel! {
        didSet {
            subTitleLabel.textColor = ColorConstants.whiteColor
            subTitleLabel.font = UIFont.TurkcellSaturaDemFont(size: 18)
            subTitleLabel.text = TextConstants.lifeboxLargePopUpSubTitle
        }
    }
    
    @IBOutlet private weak var containerView: UIView! {
        didSet {
            containerView.layer.masksToBounds = true
            containerView.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet private weak var expandButton: BlueButtonWithWhiteText! {
        didSet {
            expandButton.setTitle(TextConstants.lifeboxLargePopUpExpandButtonTitle, for: .normal)
            expandButton.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var skipButton: UIButton! {
        didSet {
            skipButton.setTitle(TextConstants.lifeboxLargePopUpSkipButtonTitle, for: .normal)
            skipButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 22)
            skipButton.setTitleColor(ColorConstants.grayTabBarButtonsColor, for: .normal)
            skipButton.adjustsFontSizeToFitWidth()
        }
    }
    
    // MARK: - Animation
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        open()
        titleLabel.text = LargeFullOfQuotaPopUp.textForTitle(type: viewType)
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
    
    @IBAction func onSkipButton() {
        close()
    }
    
    @IBAction func onExpandButton() {
        let viewController = RouterVC().packages
        RouterVC().pushViewController(viewController: viewController)
        close()
    }
    
}
