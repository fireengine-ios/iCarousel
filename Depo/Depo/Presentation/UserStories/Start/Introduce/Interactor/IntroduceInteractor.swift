//
//  IntroduceIntroduceInteractor.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class IntroduceInteractor: IntroduceInteractorInput {
    
    private let analyticsManager: AnalyticsService = factory.resolve()
    private lazy var authenticationService = AuthenticationService()
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    weak var output: IntroduceInteractorOutput!
    var loginScreen: LoginViewController?

    func trackScreen(pageNum: Int) {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.WelcomePage(pageNum: pageNum))
        analyticsManager.logScreen(screen: .welcomePage(pageNum))
    }
    
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.LiveCollectRememberScreen())
        analyticsManager.logScreen(screen: .liveCollectRemember)
    }
    
    func signInWithGoogle(with user: GoogleUser) {
        output.asyncOperationStarted()
        
        authenticationService.googleLogin(user: SignInWithGoogleParameters(idToken: user.idToken)) { json in
            if let errorCode = json["errorCode"] as? Int {
                if errorCode == 4101 {
                    self.output.signUpRequired(for: user)
                } else if errorCode == 4102 {
                    self.output.passwordLoginRequired(for: user)
                }
            }
        } success: { [weak self] headers in
            guard let self = self else { return }
            self.loginScreen = RouterVC().loginWithHeaders(user: user, headers: headers) as? LoginViewController
            self.loginScreen?.output.continueWithGoogleLogin()
        } fail: { error in
            self.output.continueWithGoogleFailed()
        } twoFactorAuth: { response in
            self.tokenStorage.isRememberMe = true
            self.output?.showTwoFactorAuthViewController(response: response)
        }
    }
}

