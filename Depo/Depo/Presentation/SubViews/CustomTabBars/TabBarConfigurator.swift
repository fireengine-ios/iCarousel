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
    case contactsSync = 3
    case documents = 4
}

enum TabBarItem: CaseIterable {
    case home
    case gallery
    case plus
    case contacts
    case allFiles
    
    var title: String {
        switch self {
        case .home:
            return TextConstants.tabBarItemHomeLabel
        case .gallery:
            return TextConstants.tabBarItemGalleryLabel
        case .plus:
            return ""
        case .contacts:
            return TextConstants.tabBarItemContactsLabel
        case .allFiles:
            return TextConstants.tabBarItemAllFilesLabel
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .home:
            return UIImage(named: "outlineHome")
        case .gallery:
            return UIImage(named: "outlinePhotosVideos")
        case .plus:
            return UIImage(named: "")
        case .contacts:
            return UIImage(named: "outlineContacts")
        case .allFiles:
            return UIImage(named: "outlineDocs")
        }
    }
    
    var accessibilityLabel: String {
        switch self {
        case .home:
            return TextConstants.accessibilityHome
        case .gallery:
            return TextConstants.accessibilityPhotosVideos
        case .plus:
            return ""
        case .contacts:
            return TextConstants.periodicContactsSync
        case .allFiles:
            return TextConstants.homeButtonAllFiles
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
                    router.segmentedFiles]
        return list.compactMap { NavigationController(rootViewController: $0!) }
    }
}
