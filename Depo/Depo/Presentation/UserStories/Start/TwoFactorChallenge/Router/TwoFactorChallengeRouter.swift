//
//  TwoFactorChallengeRouter.swift
//  Depo
//
//  Created by Raman Harhun on 8/27/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class TwoFactorChallengeRouter: PhoneVerificationRouter {
    
    override func goAutoSync() {
        ///RouterVC's present make no effect
        UIApplication.topController()?.present(router.synchronyseScreen, animated: true, completion: nil)
    }
}
