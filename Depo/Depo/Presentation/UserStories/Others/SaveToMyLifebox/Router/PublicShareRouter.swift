//
//  PublicShareRouter.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

class PublicShareRouter: NSObject, PublicShareRouterInput {
    
    private let player: MediaPlayer = factory.resolve()
    private let tokenStorage: TokenStorage = factory.resolve()
    private let router = RouterVC()
    
    func onSelect(item: WrapData, itemCount: Int) {
        let controller = router.publicSharedItemsInnerFolder(with: item, itemCount: itemCount)
        router.pushViewController(viewController: controller, animated: true)
    }
    
    func onSelect(item: WrapData, items: [WrapData]) {
        let isLoggedIn = tokenStorage.accessToken != nil
        
        if item.fileType == .audio && isLoggedIn {
            let audioItems = items.filter { $0.fileType == .audio }
            player.play(list: audioItems, startAt: audioItems.firstIndex(of: item) ?? 0)
        } else {
            let items = isLoggedIn ? items.filter { $0.fileType != .audio } : items
            let detailModule = self.router.filesDetailPublicSharedItemModule(fileObject: item,
                                                                             items: items,
                                                                             status: item.status,
                                                                             canLoadMoreItems: true,
                                                                             moduleOutput: nil)
            
            let nController = NavigationController(rootViewController: detailModule.controller)
            self.router.presentViewController(controller: nController)
        }
    }
    
    func popToRoot() {
        router.popToRootViewController()
    }
    
    func popViewController() {
        router.popViewController()
    }
    
    func navigateToOnboarding() {
        let onboarding = router.onboardingScreen
        router.setNavigationController(controller: onboarding)
    }
    
    func navigateToAllFiles() {
        router.openTabBarItem(index: .documents, segmentIndex: 0)
    }
    
    func navigateToHomeScreen() {
        router.openTabBarItem(index: .gallery)
    }
    
    func presentFullQuotaPopup() {
        router.showFullQuotaPopUp()
    }
    
    func openFilesToSave(with url: URL, documentControllerDelegate: UIDocumentPickerDelegate) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { ///waited for popups in main thread to dismiss
            let documentController = UIDocumentPickerViewController(url: url, in: .exportToService)
            documentController.delegate = documentControllerDelegate
            self.router.presentViewController(controller: documentController)
        }
    }
}
