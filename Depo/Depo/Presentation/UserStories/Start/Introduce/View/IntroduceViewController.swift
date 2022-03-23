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

class IntroduceViewController: ViewController, IntroduceViewInput {

    // MARK: Properties
    var output: IntroduceViewOutput!
    
    // MARK: IBOutlets
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
            newValue.text = "or"
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 15)
            newValue.textColor = .white
        }
    }
    
    @IBOutlet private weak var signInWithGoogleButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle("Sign in with Google", for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.backgroundColor = .white
            newValue.setTitleColor(ColorConstants.billoGray, for: .normal)
            newValue.adjustsFontSizeToFitWidth()
            newValue.setImage(UIImage(named: "googleLogin"), for: .normal)
            newValue.moveImageLeftTextCenter()
        }
    }
    
    @IBOutlet weak var signInWithAppleButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle("Sign in with Apple", for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.backgroundColor = .white
            newValue.setTitleColor(ColorConstants.billoGray, for: .normal)
            newValue.adjustsFontSizeToFitWidth()
            newValue.setImage(UIImage(named: "appleLogin"), for: .normal)
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
    }
    
    func configurateView() {
        hidenNavigationBarStyle()
        backButtonForNavigationItem(title: TextConstants.backTitle)
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
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            if let error = error {
                print(error)
                return
            }
            
            if let idToken = user?.authentication.idToken, let email = user?.profile?.email {
                let user = GoogleUser(idToken: idToken, email: email)
                self.output.onContinueWithGoogle(with: user)
            } else {
                return
            }
        }
    }
    
}
