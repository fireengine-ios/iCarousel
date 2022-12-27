//
//  TabBarConfigurator.swift
//  Depo
//
//  Created by Andrei Novikau on 22.12.20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

enum TabScreenIndex: Int {
    case gallery = 0
    case forYou = 1
    case contactsSync = 2
    case documents = 3
    case discover = 4
}

enum TabBarItem: CaseIterable {
    case gallery
    case forYou
    case contacts
    case allFiles
    case discover
    
    var title: String {
        switch self {
        case .forYou:
            return localized(.tabBarForYouTitle)
        case .gallery:
            return TextConstants.tabBarItemGalleryLabel
        case .contacts:
            return TextConstants.tabBarItemContactsLabel
        case .allFiles:
            return TextConstants.tabBarItemAllFilesLabel
        case .discover:
            return localized(.tabBarDiscoverTitle)
        }
    }
    
    var image: UIImage? {
        switch self {
        case .forYou:
            return TabBarImage.forYou.image
        case .gallery:
            return TabBarImage.gallery.image
        case .contacts:
            return TabBarImage.contacts.image
        case .allFiles:
            return TabBarImage.files.image
        case .discover:
            return TabBarImage.discover.image
        }
    }

    var selectedImage: UIImage? {
        switch self {
        case .forYou:
            return TabBarImage.forYouSelected.image
        case .gallery:
            return TabBarImage.gallerySelected.image
        case .contacts:
            return TabBarImage.contactsSelected.image
        case .allFiles:
            return TabBarImage.filesSelected.image
        case .discover:
            return TabBarImage.discoverSelected.image
        }
    }
    
    var accessibilityLabel: String {
        switch self {
        case .forYou:
            return localized(.tabBarForYouTitle)
        case .gallery:
            return TextConstants.accessibilityPhotosVideos
        case .contacts:
            return TextConstants.periodicContactsSync
        case .allFiles:
            return TextConstants.homeButtonAllFiles
        case .discover:
            return TextConstants.tabBarItemAllFilesLabel
        }
    }
}

final class TabBarConfigurator {
    
    static func generateControllers(router: RouterVC) -> [UINavigationController] {
        guard let syncContactsVC = router.syncContacts as? ContactSyncViewController else {
            assertionFailure()
            return []
        }
        syncContactsVC.setTabBar(isVisible: true)
        syncContactsVC.navigationBarHidden = true
        
        let list: [HeaderContainingViewController.ChildViewController] = [
            router.gallery(),
            router.forYou(),
            syncContactsVC,
            router.segmentedFiles,
            router.discover()
            
        ]
        return list.map {
            let headerContaining = HeaderContainingViewController(child: $0)
            return NavigationController(rootViewController: headerContaining)
        }
    }
}

// TODO: Facelift. remove when implementing discover page
private class EmptyViewController: UIViewController, HeaderContainingViewControllerChild {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
