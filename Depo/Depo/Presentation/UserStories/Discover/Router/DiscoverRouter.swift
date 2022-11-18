//
//  DiscoverRouter.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class DiscoverRouter: DiscoverRouterInput {
    private let router = RouterVC()
    weak var presenter: DiscoverPresenter!
    
    func navigate(for view: HomeCardTypes) {
        switch view {
        case .paycell:
            let payCell = router.paycellCampaign()
            router.pushViewController(viewController: payCell)
        case .invitation:
            let invitation = router.invitationController()
            router.pushViewController(viewController: invitation)
        default:
            break
        }
    }
    
}
