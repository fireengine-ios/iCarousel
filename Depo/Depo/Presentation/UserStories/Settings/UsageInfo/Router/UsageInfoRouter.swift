//
//  UsageInfoRouter.swift
//  Depo
//
//  Created by Maksim Rahleev on 12.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class UsageInfoRouter {
    
}

// MARK: - UsageInfoRouterInput
extension UsageInfoRouter: UsageInfoRouterInput {
    func showPackages(navVC: UINavigationController?) {
        RouterVC().pushViewController(viewController: RouterVC().myStorage(usageStorage: nil))
    }
}
