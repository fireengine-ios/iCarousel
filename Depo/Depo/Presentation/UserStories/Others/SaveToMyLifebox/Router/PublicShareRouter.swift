//
//  PublicShareRouter.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

class PublicShareRouter: PublicShareRouterInput {
    
    private let router = RouterVC()
    
    func onSelect(item: WrapData) {
        let controller = router.publicSharedItemsInnerFolder(with: item)
        router.pushViewController(viewController: controller, animated: true)
    }
    
    func popToRoot() {
        router.popToRootViewController()
    }
}
