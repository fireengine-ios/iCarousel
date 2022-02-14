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
        router.openTabBarItem(index: .home)
    }
    
    func presentFullQuotaPopup() {
        router.showFullQuotaPopUp()
    }
    
    func openFilesToSave(with url: URL) {
        DispatchQueue.main.async {
            let documentController = UIDocumentPickerViewController(url: url, in: .exportToService)
            documentController.delegate = self
            self.router.presentViewController(controller: documentController)
        }
    }
    
    func showDownloadCompletePopup(isSuccess: Bool, message: String) {
        isSuccess ? UIApplication.showSuccessAlert(message: message, closed: nil) : UIApplication.showErrorAlert(message: message)
    }
}

extension PublicShareRouter: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        showDownloadCompletePopup(isSuccess: true, message: TextConstants.popUpDownloadComplete)
     }
}
