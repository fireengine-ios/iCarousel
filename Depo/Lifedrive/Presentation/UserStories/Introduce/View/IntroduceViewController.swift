//
//  IntroduceViewController.swift
//  lifedrive
//
//  Created by Andrei Novikau on 10/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseCore

final class IntroduceViewController: ViewController {

    var output: IntroduceViewOutput!
    var user: GoogleUser?
    
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
    
    @IBOutlet private weak var orLabel: UILabel! {
        willSet {
            newValue.text = localized(.onboardingButtonOr)
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 12)
            newValue.textColor = AppColor.billoGrayAndWhite.color
        }
    }
    
    @IBOutlet private weak var signInWithGoogleButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(localized(.connectWithGoogle), for: .normal)
            newValue.setTitleColor(AppColor.billoGrayAndWhite.color, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.adjustsFontSizeToFitWidth()
            newValue.setImage(UIImage(named: "googleLogo"), for: .normal)
            newValue.moveImageLeftTextCenter()
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.layer.borderColor = AppColor.darkBlueAndBilloBlue.color?.cgColor
            newValue.layer.borderWidth = 1
        }
    }
    
    @IBOutlet private weak var signInWithAppleButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(localized(.connectWithApple), for: .normal)
            newValue.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            newValue.setTitleColor(AppColor.primaryBackground.color, for: .normal)
            newValue.adjustsFontSizeToFitWidth()
            newValue.setImage(UIImage(named: "appleLogo")?.withRenderingMode(.alwaysTemplate), for: .normal)
            newValue.tintColor = AppColor.primaryBackground.color
            newValue.moveImageLeftTextCenter()
            newValue.backgroundColor = AppColor.blackColor.color
        }
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurateView()
        output.viewIsReady()
        handleRemoteConfig()
    }
    
    func configurateView() {
        hidenNavigationBarStyle()
        backButtonForNavigationItem(title: TextConstants.backTitle)
        
        if #unavailable(iOS 13, *) {
            signInWithAppleButton.isHidden = true
        }
    }
    
    private func handleRemoteConfig() {
        signInWithAppleButton.isHidden = !FirebaseRemoteConfig.shared.appleLoginEnabled
        signInWithGoogleButton.isHidden = !FirebaseRemoteConfig.shared.googleLoginEnabled
        
        if signInWithAppleButton.isHidden && signInWithGoogleButton.isHidden {
            orLabel.isHidden = true
        }
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
    
    // MARK: - Actions
    @IBAction func onCreateAccount(_ sender: UIButton) {
        output.onStartUsingLifeBox()
    }
    
    @IBAction func onSignInWithGoogle(_ sender: Any) {
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
    
    @IBAction func onSignInWithApple(_ sender: Any) {
        //TODO -Apple login will be implemented
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        output.onLoginButton()
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
