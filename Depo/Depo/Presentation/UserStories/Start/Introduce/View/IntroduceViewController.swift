//
//  IntroduceIntroduceViewController.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import WidgetKit
import GoogleSignIn
import FirebaseCore

class IntroduceViewController: ViewController {

    // MARK: Properties
    var output: IntroduceViewOutput!
    var user: GoogleUser?
    
    // MARK: IBOutlets
    @IBOutlet private weak var welcomeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var startUsingLifeBoxButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.itroViewGoToRegisterButtonText, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.backgroundColor = AppColor.marineTwoAndTealish.color
            newValue.setTitleColor(.white, for: .normal)
            newValue.insets = UIEdgeInsets(topBottom: 0, rightLeft: 12)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var haveAccountButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.introViewGoToLoginButtonText, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.backgroundColor = .white
            newValue.setTitleColor(ColorConstants.marineTwo, for: .normal)
            newValue.insets = UIEdgeInsets(topBottom: 0, rightLeft: 12)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var haveAccountLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.alreadyHaveAccountTitle
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 15)
            newValue.textColor = .white
        }
    }
    
    @IBOutlet private weak var orLabel: UILabel! {
        willSet {
            newValue.text = localized(.onboardingButtonOr)
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 15)
            newValue.textColor = .white
        }
    }
    
    @IBOutlet private weak var signInWithGoogleButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(localized(.connectWithGoogle), for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.backgroundColor = .white
            newValue.setTitleColor(ColorConstants.billoGray, for: .normal)
            newValue.adjustsFontSizeToFitWidth()
            newValue.setImage(UIImage(named: "googleLogo"), for: .normal)
            newValue.moveImageLeftTextCenter()
        }
    }
    
    @IBOutlet weak var signInWithAppleButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(localized(.connectWithApple), for: .normal)
            newValue.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            newValue.backgroundColor = .white
            newValue.setTitleColor(UIColor.black, for: .normal)
            newValue.adjustsFontSizeToFitWidth()
            newValue.setImage(UIImage(named: "appleLogo"), for: .normal)
            newValue.moveImageLeftTextCenter()
        }
    }
    
    @IBOutlet private weak var welcomView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet private weak var welcomeTopLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.font = UIFont.TurkcellSaturaBolFont(size: Device.isIpad ? 28 : 22)
            newValue.textColor = ColorConstants.whiteColor
            newValue.minimumScaleFactor = 0.5
            newValue.adjustsFontSizeToFitWidth = true
            newValue.text = TextConstants.welcome1Info
        }
    }
    
    @IBOutlet private weak var welcomeBottomLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.font = UIFont.TurkcellSaturaMedFont(size: Device.isIpad ? 24 : 16)
            newValue.textColor = ColorConstants.whiteColor
            newValue.minimumScaleFactor = 0.5
            newValue.adjustsFontSizeToFitWidth = true
            newValue.text = TextConstants.welcome1SubInfo
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        } 

        configurateView()
        output.viewIsReady()
        handleRemoteConfig()
    }
    
    func configurateView() {
        hidenNavigationBarStyle()
        backButtonForNavigationItem(title: TextConstants.backTitle)
    }
    
    private func handleRemoteConfig() {
        if #available(iOS 13, *) { } else {
            signInWithAppleButton.isHidden = true
            signInWithGoogleButton.isHidden = true
            orLabel.isHidden = true
            return
        }
        
        signInWithAppleButton.isHidden = !FirebaseRemoteConfig.shared.appleLoginEnabled
        signInWithGoogleButton.isHidden = !FirebaseRemoteConfig.shared.googleLoginEnabled
        
        if signInWithAppleButton.isHidden {
            signInWithGoogleButton.isHidden = true
        }
        
        if signInWithAppleButton.isHidden && signInWithGoogleButton.isHidden {
            orLabel.isHidden = true
        }
        
        if !signInWithAppleButton.isHidden && !signInWithGoogleButton.isHidden {
            if Device.isIphoneSmall {
                welcomeViewHeightConstraint.constant = 174
            }
        }
    }

    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
    // MARK: Actions
    
    @IBAction func onStartUsingLifeBoxButton() {
        output.onStartUsingLifeBox()
    }
    
    @IBAction func onHaveAccountButton() {
        output.onLoginButton()
    }
    
    @IBAction func onContinueWithGoogle(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID, serverClientID: Keys.googleServerClientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            if error != nil {
                return
            }
            
            if let idToken = user?.authentication.idToken, let email = user?.profile?.email {
                let user = GoogleUser(idToken: idToken, email: email)
                self.user = user
                self.output.onContinueWithGoogle(with: user)
            }
        }
    }
    
}

extension IntroduceViewController: IntroduceViewInput {
    func showGoogleLoginPopup(with user: GoogleUser) {
        let popUp = RouterVC().loginWithGooglePopup
        popUp.email = user.email
        popUp.delegate = self
        present(popUp, animated: true)
    }
}

extension IntroduceViewController: LoginWithGooglePopupDelegate {
    func onNextButton() {
        dismiss(animated: true)
        guard let user = user else { return }
        output.goToLogin(with: user)
    }
}
