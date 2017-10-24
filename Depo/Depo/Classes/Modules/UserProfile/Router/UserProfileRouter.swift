//
//  UserProfileUserProfileRouter.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UserProfileRouter: UserProfileRouterInput {

    func needSendOTP(responce: SignUpSuccessResponse, userInfo: AccountInfoResponse, navigationController: UINavigationController){
        let router = RouterVC()
        let controller = router.otpView(responce: responce, userInfo: userInfo)
        navigationController.pushViewController(controller, animated: true)
    }
    
}
