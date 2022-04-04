//
//  IntroduceViewController.swift
//  lifedrive
//
//  Created by Andrei Novikau on 10/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class IntroduceViewController: ViewController, IntroduceViewInput {

    var output: IntroduceViewOutput!
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.introTitle
            newValue.textColor = ColorConstants.billoDarkBlue
            if Device.isIpad {
                newValue.font = UIFont.TurkcellSaturaBolFont(size: 27)
            } else {
                newValue.font = UIFont.TurkcellSaturaBolFont(size: 20)//UIFont.PoppinsBoldFont(size: 20)
            }
            
            newValue.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var subtitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.introSubTitle
            newValue.textColor = AppColor.marineTwoAndWhite.color
            if Device.isIpad {
                newValue.font = UIFont.TurkcellSaturaRegFont(size: 22)
            } else {
                newValue.font = UIFont.TurkcellSaturaRegFont(size: 15)//UIFont.SFProRegularFont(size: 15)
            }
            
            newValue.textAlignment = .center
            newValue.numberOfLines = 3
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var createAccountButton: RoundedInsetsButton! {
        willSet {

            newValue.backgroundColor = AppColor.darkBlueAndBilloBlue.color
            newValue.setTitle(TextConstants.itroViewGoToRegisterButtonText, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
            newValue.setTitleColor(.white, for: .normal)
            newValue.insets = UIEdgeInsets(top: 5, left: 45, bottom: 5, right: 45)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var haveAccountLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.alreadyHaveAccountTitle
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 12)
            newValue.textColor = AppColor.billoGrayAndWhite.color
        }
    }
    
    @IBOutlet private weak var loginButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.introViewGoToLoginButtonText, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
            newValue.layer.borderColor = AppColor.darkBlueAndBilloBlue.color?.cgColor
            newValue.layer.borderWidth = 1
            newValue.setTitleColor(AppColor.darkBlueAndBilloBlue.color, for: .normal)
            newValue.adjustsFontSizeToFitWidth()
        }
    }

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurateView()
        output.viewIsReady()
    }
    
    func configurateView() {
        navigationBarHidden = true
        backButtonForNavigationItem(title: TextConstants.backTitle)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }

    // MARK: - IntroduceViewInput
    func setupInitialState(models: [IntroduceModel]) { }
    
    // MARK: - Actions
    
    @IBAction func onCreateAccount(_ sender: UIButton) {
        output.onStartUsingLifeBox()
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        output.onLoginButton()
    }
}
