//
//  UserProfileUserProfileRouter.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UserProfileRouter: UserProfileRouterInput {

    private let router = RouterVC()

    func needSendOTP(response: SignUpSuccessResponse, userInfo: AccountInfoResponse, navigationController: UINavigationController, phoneNumber: String) {
        let controller = router.otpView(response: response, userInfo: userInfo, phoneNumber: phoneNumber)
        navigationController.pushViewController(controller, animated: true)
    }
    
    func goToChangePassword() {
        let controller = ChangePasswordController.initFromNib()
        router.pushViewController(viewController: controller)
    }
    
    func goToSetSecretQuestion(selectedQuestion: String?, delegate: SetSecurityQuestionViewControllerDelegate) {
        let controller = SetSecurityQuestionViewController.initFromNib()
        controller.configureWith(selectedQuestion: selectedQuestion, delegate: delegate)
        router.pushViewController(viewController: controller)
    }
}
