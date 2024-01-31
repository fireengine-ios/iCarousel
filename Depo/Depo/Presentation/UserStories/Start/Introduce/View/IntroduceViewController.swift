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
import AuthenticationServices

class IntroduceViewController: BaseViewController {

    // MARK: Properties
    private lazy var appleGoogleService = AppleGoogleLoginService()
    var output: IntroduceViewOutput!
    var user: AppleGoogleUser?
    
    // MARK: IBOutlets
    @IBOutlet private weak var welcomeViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var startUsingLifeBoxButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.itroViewGoToRegisterButtonText, for: .normal)
            newValue.titleLabel?.font = UIFont.appFont(.medium, size: 14.0)
            newValue.backgroundColor = .clear
            newValue.setTitleColor(AppColor.label.color, for: .normal)
            newValue.insets = UIEdgeInsets(topBottom: 0, rightLeft: 12)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var haveAccountButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.introViewGoToLoginButtonText, for: .normal)
            newValue.titleLabel?.font = UIFont.appFont(.medium, size: 16.0)
            newValue.backgroundColor = ColorConstants.darkBlueColor
            newValue.setTitleColor(ColorConstants.whiteColor, for: .normal)
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
            newValue.font = UIFont.appFont(.regular, size: 15.0)
            newValue.textColor = AppColor.label.color
        }
    }
    
    @IBOutlet weak var logoTitleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 20)
            newValue.textColor = AppColor.label.color
            newValue.text = TextConstants.NotLocalized.appNameLowercased
            newValue.textAlignment = .center
        }
    }
    
    
    @IBOutlet private weak var signInWithGoogleButton: RoundedInsetsButton! {
        willSet {
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.label.cgColor
            newValue.layer.cornerRadius = newValue.frame.height * 0.5
            newValue.setTitle(localized(.connectWithGoogle), for: .normal)
            newValue.titleLabel?.font = .appFont(.regular, size: 14)
            newValue.backgroundColor = .white
            newValue.setTitleColor(AppColor.appleGoogleLoginLabel.color, for: .normal)
            newValue.adjustsFontSizeToFitWidth()
            newValue.setImage(UIImage(named: "googleLogo"), for: .normal)
            newValue.moveImageLeftTextCenter()
        }
    }
    
    @IBOutlet weak var signInWithAppleButton: RoundedInsetsButton! {
        willSet {
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.label.cgColor
            newValue.layer.cornerRadius = newValue.frame.height * 0.5
            newValue.setTitle(localized(.connectWithApple), for: .normal)
            newValue.titleLabel?.font = .appFont(.regular, size: 14)
            newValue.backgroundColor = .white
            newValue.setTitleColor(AppColor.appleGoogleLoginLabel.color, for: .normal)
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
            newValue.font = .appFont(.medium, size: 20)
            newValue.textColor = AppColor.label.color
            newValue.minimumScaleFactor = 0.5
            newValue.adjustsFontSizeToFitWidth = true
            newValue.text = TextConstants.welcome1Info
            newValue.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var welcomeBottomLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.font = .appFont(.regular, size: 15.0)
            newValue.textColor = AppColor.label.color
            newValue.minimumScaleFactor = 0.5
            newValue.adjustsFontSizeToFitWidth = true
            newValue.text = TextConstants.welcome1SubInfo
            newValue.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var gradientView: UIView! {
        willSet {
            newValue.alpha = 0.15
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRemoteConfig),
            name: .firebaseRemoteConfigInitialFetchComplete,
            object: nil
        )

    }
    
    func configurateView() {
        navigationBarHidden = true
        gradientView.addGradient(firstColor: AppColor.landingGradientStart.cgColor,
                                 secondColor: AppColor.landingGradientFinish.cgColor)
    }
    
    @objc private func handleRemoteConfig() {
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

        orLabel.isHidden = signInWithAppleButton.isHidden && signInWithGoogleButton.isHidden

        if !signInWithAppleButton.isHidden && !signInWithGoogleButton.isHidden {
            if Device.isIphoneSmall {
                welcomeViewTopConstraint.constant = 30
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        gradientView.addGradient(firstColor: AppColor.landingGradientStart.cgColor,
                                 secondColor: AppColor.landingGradientFinish.cgColor)
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
        let config = GIDConfiguration(clientID: clientID, serverClientID: Credentials.googleServerClientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            if error != nil {
                return
            }
            
            if let idToken = user?.authentication.idToken, let email = user?.profile?.email {
                let user = AppleGoogleUser(idToken: idToken, email: email, type: .google)
                self.user = user
                self.output.onSignInWithAppleGoogle(with: user)
            }
        }
    }
    
    @available(iOS 13.0, *)
    @IBAction func onContinueWithApple(_ sender: Any) {
        let controller = appleGoogleService.getAppleAuthorizationController()
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
}

@available(iOS 13.0, *)
extension IntroduceViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credentials = authorization.credential as? ASAuthorizationAppleIDCredential {
            appleGoogleService.getAppleCredentials(with: credentials) { user in
                guard let user = user else { return }
                self.user = user
                self.output.onSignInWithAppleGoogle(with: user)
            } fail: { error in
                debugLog(error)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        debugLog("Apple auth didCompleteWithError: \(error.localizedDescription)")
    }
}

@available(iOS 13.0, *)
extension IntroduceViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

extension IntroduceViewController: IntroduceViewInput {
    func showGoogleLoginPopup(with user: AppleGoogleUser) {
        let description = user.type == .google ? localized(.googleUserExistBody) : localized(.appleUserExistBody)
        let message = String(format: description, user.email)
        let title = user.email
        
        let popUp = PopUpController.withDark(title: title,
                                         message: message,
                                         image: .none,
                                         buttonTitle: TextConstants.nextTitle) { vc in
                                         vc.close {
                                             self.onNextButton()
                                         }
        }
        popUp.open()
    }
    
    func signUpRequiredMessage(for user: AppleGoogleUser) {
        let popUp = PopUpController.with(title: nil,
                                         message: TextConstants.loginScreenNeedSignUpError,
                                         image: .logout,
                                         firstButtonTitle: TextConstants.registerTitle,
                                         secondButtonTitle:TextConstants.cancel,
                                         firstAction: { [weak self] vc in
                                            DispatchQueue.toMain { [weak self] in
                                                self?.dismiss(animated: false, completion: {
                                                    self?.output.goToSignUpWithApple(for: user)
                                                })
                                            }
                                        }, secondAction: { vc in
                                            DispatchQueue.toMain { [weak self] in
                                                self?.dismiss(animated: false)
                                            }
                                        })
        popUp.open()
    }
}

extension IntroduceViewController {
    func onNextButton() {
        dismiss(animated: true)
        guard let user = user else { return }
        output.goToLogin(with: user)
    }
}
