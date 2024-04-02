//
//  RaffleRouter.swift
//  Depo
//
//  Created by Ozan Salman on 26.03.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

class RaffleRouter: RaffleRouterInput {

    let router = RouterVC()
    
    func goToRaffleSummary(statusResponse: RaffleStatusResponse?) {
        let vc = router.raffleSummary(statusResponse: statusResponse)
        router.pushViewController(viewController: vc, animated: false)
    }
    
}
