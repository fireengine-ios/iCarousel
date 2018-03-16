//
//  UserProfileUserProfileRouter.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UserProfileRouter: UserProfileRouterInput {

    func needSendOTP(responce: SignUpSuccessResponse, userInfo: AccountInfoResponse, navigationController: UINavigationController, phoneNumber: String) {
        let router = RouterVC()
        let controller = router.otpView(responce: responce, userInfo: userInfo, phoneNumber: phoneNumber)
        navigationController.pushViewController(controller, animated: true)
    }
    
}
