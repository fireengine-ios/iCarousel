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
    
    func onSelect(item: WrapData, items: [WrapData]) {
        let detailModule = self.router.filesDetailPublicSharedItemModule(fileObject: item,
                                                                         items: items,
                                                                         status: item.status,
                                                                         canLoadMoreItems: true,
                                                                         moduleOutput: nil)
        
        let nController = NavigationController(rootViewController: detailModule.controller)
        self.router.presentViewController(controller: nController)
    }
    
    func popToRoot() {
        router.popToRootViewController()
    }
    
    func navigateToOnboarding() {
        let onboarding = router.onboardingScreen
        router.setNavigationController(controller: onboarding)
    }
    
    func navigateToAllFiles() {
        router.openTabBarItem(index: .documents, segmentIndex: 0)
    }
}
