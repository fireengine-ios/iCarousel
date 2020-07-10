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
            newValue.textColor = ColorConstants.darkBlueColor
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
            let font: UIFont
            if Device.isIpad {
                font = UIFont.TurkcellSaturaBolFont(size: 27)
            } else {
                font = UIFont.TurkcellSaturaBolFont(size: 18)
            }
            let attributedTitle = NSAttributedString(string: TextConstants.introCreateAccountButton,
                                                     attributes:  [.foregroundColor : ColorConstants.darkBlueColor,
                                                                   .underlineStyle : NSUnderlineStyle.styleNone.rawValue,
                                                                   .font : font])
            newValue.setAttributedTitle(attributedTitle, for: .normal)
            newValue.layer.borderColor = ColorConstants.darkBlueColor.cgColor
            newValue.layer.borderWidth = 2
            newValue.insets = UIEdgeInsets(top: 5, left: 45, bottom: 5, right: 45)
        }
    }
    
    @IBOutlet private weak var loginButton: UIButton! {
        willSet {
            let font: UIFont
            if Device.isIpad {
                font = UIFont.TurkcellSaturaMedFont(size: 20)
            } else {
                font = UIFont.TurkcellSaturaMedFont(size: 13)
            }
            let attributedTitle = NSAttributedString(string: TextConstants.introLoginButton,
                                                     attributes:  [.foregroundColor : ColorConstants.billoGray,
                                                                   .underlineStyle : NSUnderlineStyle.styleSingle.rawValue,
                                                                   .font : font]) //UIFont.SFProSemiboldFont(size: 13)
            newValue.setAttributedTitle(attributedTitle, for: .normal)
            newValue.isOpaque = true
        }
    }

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurateView()
        output.viewIsReady()
    }
    
    func configurateView() {
        hidenNavigationBarStyle()
        backButtonForNavigationItem(title: TextConstants.backTitle)
    }

    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
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
