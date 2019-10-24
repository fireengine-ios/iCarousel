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
            newValue.font = UIFont.PoppinsBoldFont(size: 20)
            newValue.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var subtitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.introSubTitle
            newValue.textColor = ColorConstants.darkBlueColor
            newValue.font = UIFont.SFProRegularFont(size: 15)
            newValue.textAlignment = .center
            newValue.numberOfLines = 3
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var createAccountButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.introCreateAccountButton, for: .normal)
            newValue.setTitleColor(ColorConstants.darkBlueColor, for: .normal)
            newValue.layer.borderColor = ColorConstants.darkBlueColor.cgColor
            newValue.layer.borderWidth = 2
            newValue.insets = UIEdgeInsets(top: 5, left: 45, bottom: 5, right: 45)
        }
    }
    
    @IBOutlet private weak var loginButton: UIButton! {
        willSet {
            let attributedTitle = NSAttributedString(string: TextConstants.introLoginButton,
                                                     attributes:  [.foregroundColor : ColorConstants.billoGray,
                                                                   .underlineStyle : NSUnderlineStyle.styleSingle.rawValue,
                                                                   .font : UIFont.SFProSemiboldFont(size: 13)])
            newValue.setAttributedTitle(attributedTitle, for: .normal)
            newValue.isOpaque = true
        }
    }

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurateView()
        output.viewIsReady()
        MenloworksAppEvents.onTutorial()
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
