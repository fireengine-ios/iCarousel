//
//  TabBarConfigurator.swift
//  Depo
//
//  Created by Andrei Novikau on 22.12.20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum TabScreenIndex: Int {
    case home = 0
    case gallery = 1
    case contactsSync = 2
    case documents = 3
    case discover = 4
}

enum TabBarItem: CaseIterable {
    case home
    case gallery
    case contacts
    case allFiles
    case discover
    
    var title: String {
        switch self {
        case .home:
            return TextConstants.tabBarItemHomeLabel
        case .gallery:
            return TextConstants.tabBarItemGalleryLabel
        case .contacts:
            return TextConstants.tabBarItemContactsLabel
        case .allFiles:
            return TextConstants.tabBarItemAllFilesLabel
        case .discover:
            return TextConstants.tabBarItemAllFilesLabel
        }
    }
    
    var image: UIImage? {
        switch self {
        case .home:
            return imageAsset(TabBarImages.forYou)
        case .gallery:
            return imageAsset(TabBarImages.gallery)
        case .contacts:
            return imageAsset(TabBarImages.contacts)
        case .allFiles:
            return imageAsset(TabBarImages.files)
        case .discover:
            return imageAsset(TabBarImages.discover)
        }
    }

    var selectedImage: UIImage? {
        switch self {
        case .home:
            return imageAsset(TabBarImages.forYouSelected)
        case .gallery:
            return imageAsset(TabBarImages.gallerySelected)
        case .contacts:
            return imageAsset(TabBarImages.contactsSelected)
        case .allFiles:
            return imageAsset(TabBarImages.filesSelected)
        case .discover:
            return imageAsset(TabBarImages.discoverSelected)
        }
    }
    
    var accessibilityLabel: String {
        switch self {
        case .home:
            return TextConstants.accessibilityHome
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
        
        let list = [router.homePageScreen,
                    router.segmentedMedia(),
                    syncContactsVC,
                    router.segmentedFiles,
                    UIViewController()]
        return list.compactMap { NavigationController(rootViewController: $0!) }
    }
}
