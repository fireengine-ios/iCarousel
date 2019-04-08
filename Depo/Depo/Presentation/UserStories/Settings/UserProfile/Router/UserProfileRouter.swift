//
//  UserProfileUserProfileRouter.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UserProfileRouter: UserProfileRouterInput {
    
    private let router = RouterVC()

    func needSendOTP(responce: SignUpSuccessResponse, userInfo: AccountInfoResponse, navigationController: UINavigationController, phoneNumber: String) {
        let controller = router.otpView(responce: responce, userInfo: userInfo, phoneNumber: phoneNumber)
        navigationController.pushViewController(controller, animated: true)
    }
    
    func goToChangePassword() {
        /// TODO: Make the screen open with a password change when it is ready
        let controller = UIViewController()
        router.pushViewController(viewController: controller)
    }
    
}
